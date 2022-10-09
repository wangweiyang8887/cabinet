// Copyright © 2021 evan. All rights reserved.

import QuartzCore

final class MarqueeLabel : UILabel {
    /// The scroll speed defined by a rate of motion, in points per second.
    var scrollRate: CGFloat = 60
    /// If set to `true` it will scroll from left to right, otherwise from right to left
    var reverseScrolling: Bool = false
    var isMarqueeEnabled: Bool = false { didSet { if isMarqueeEnabled != oldValue { updateAndScroll() } } }
    var isPaused: Bool { return scrollLabel.layer.speed == 0.0 }
    /// The length of delay in seconds that the label pauses at the completion of a scroll.
    var animationDelay: CGFloat = 0.0
    /// The width of transparency fade at the left and right edges of the frame.
    var fadeWidth: CGFloat = 16.0 {
        didSet {
            guard fadeWidth != oldValue else { return }
            applyGradientMask(fadeWidth, animated: true)
            updateAndScroll()
        }
    }

    /// If `isMarqueeEnabled = true`, we need scroll effect when text displayed completely.
    var labelShouldAlwaysScroll: Bool = false { didSet { if labelShouldAlwaysScroll != oldValue { updateAndScroll() } } }
    var rightMargin: CGFloat = 16.0 { didSet { if rightMargin != oldValue { updateAndScroll() } } }
    var leftMargin: CGFloat = 16.0 { didSet { if leftMargin != oldValue { updateAndScroll() } } }

    private let observers = ObserverCollection()
    private var scrollLabel = UILabel()
    private var originalLabelFrame: CGRect = .zero
    private var scrollLabelOffset: CGFloat = 0.0
    private var scrollCompletionBlock: ObjectClosure<Bool>?
    private var replicatorLayer: CAReplicatorLayer? { return layer as? CAReplicatorLayer }
    private var maskLayer: CAGradientLayer? { return layer.mask as! CAGradientLayer? }
    override class var layerClass: AnyClass { return CAReplicatorLayer.self }

    // Convenience
    var isInOriginalPosition: Bool { return given(scrollLabel.layer.presentation()) { ($0.position.x == originalLabelFrame.origin.x) } ?? false }
    var animationDuration: CGFloat { return CGFloat(abs(scrollLabelOffset) / scrollRate) }

    private var scrollLabelSize: CGSize {
        let maximumLabelSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        var expectedLabelSize = scrollLabel.sizeThatFits(maximumLabelSize)
        expectedLabelSize.width = expectedLabelSize.width.constrained(toMax: 5461.0) // largest width a UILabel will draw on an iPhone Plus
        expectedLabelSize.height = bounds.size.height
        return expectedLabelSize
    }

    private var labelShouldScroll: Bool {
        guard !(scrollLabel.text?.isEmpty ?? true) else { return false }
        let labelTooLarge = (scrollLabelSize.width + leftMargin) > bounds.size.width + .ulpOfOne
        let animationHasDuration = scrollRate > 0.0
        return isMarqueeEnabled && (labelTooLarge || labelShouldAlwaysScroll) && animationHasDuration
    }

    private var labelReadyForScroll: Bool {
        guard superview != nil && window != nil else { return false }
        return given(viewController) { $0.isViewLoaded } ?? true
    }

    // MARK: Lifecycle
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        // Drawing is handled by scrollLabel and CAReplicatorLayer layer class, super call avoided to prevent superclass from drawing
        guard let bgColor = backgroundColor else { return }
        ctx.setFillColor(bgColor.cgColor)
        ctx.fill(layer.bounds)
    }

    deinit { observers.removeAll() }

    init(frame: CGRect, scrollRate: CGFloat, fadeWidth fade: CGFloat) {
        self.scrollRate = scrollRate
        fadeWidth = CGFloat(min(fade, frame.size.width / 2.0))
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // Scrolling label
        scrollLabel = UILabel(frame: bounds)
        scrollLabel.layer.anchorPoint = .zero
        addSubview(scrollLabel)

        clipsToBounds = true
        numberOfLines = 1

        observers.addObserver(forName: UIApplication.didBecomeActiveNotification, handler: { [weak self] _ in self?.restart() })
        observers.addObserver(forName: UIApplication.didEnterBackgroundNotification, handler: { [weak self] _ in self?.stop() })
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        scrollLabel.text = super.text
        scrollLabel.font = super.font
        scrollLabel.textColor = super.textColor
        scrollLabel.backgroundColor = super.backgroundColor ?? .clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateAndScroll()
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil { stop() }
    }

    override func didMoveToWindow() {
        window == nil ? stop() : updateAndScroll()
    }

    // MARK: Updating
    private func resetLabel() {
        scrollLabel.textAlignment = super.textAlignment
        scrollLabel.lineBreakMode = super.lineBreakMode

        let labelFrame: CGRect
        if reverseScrolling {
            labelFrame = bounds.divided(atDistance: leftMargin, from: CGRectEdge.maxXEdge).remainder.integral
        } else {
            labelFrame = CGRect(x: leftMargin, y: 0.0, width: bounds.size.width - leftMargin, height: bounds.size.height).integral
        }

        originalLabelFrame = labelFrame
        scrollLabelOffset = 0.0
        replicatorLayer?.instanceCount = 1 // Remove an additional scrollLabels
        scrollLabel.frame = labelFrame
        removeGradientMask()
    }

    private func moveLabelToStartPosition() {
        maskLayer?.removeAllAnimations()
        scrollLabel.layer.removeAllAnimations()
        scrollCompletionBlock = nil
    }

    private func updateAndScroll() {
        guard labelReadyForScroll else { return }

        let expectedLabelSize = scrollLabelSize
        invalidateIntrinsicContentSize()
        moveLabelToStartPosition()

        guard labelShouldScroll else { return resetLabel() }

        let minTrailing = max(max(leftMargin, rightMargin), fadeWidth)

        if reverseScrolling {
            originalLabelFrame = CGRect(x: bounds.size.width - (expectedLabelSize.width + leftMargin), y: 0.0, width: expectedLabelSize.width, height: bounds.size.height).integral
            scrollLabelOffset = (originalLabelFrame.size.width + minTrailing)
        } else {
            originalLabelFrame = CGRect(x: leftMargin, y: 0.0, width: expectedLabelSize.width, height: bounds.size.height).integral
            scrollLabelOffset = -(originalLabelFrame.size.width + minTrailing)
        }

        let offsetDistance = scrollLabelOffset
        let offscreenAmount = originalLabelFrame.size.width
        let startFadeFraction = abs(offscreenAmount / offsetDistance)
        let startFadeTime = startFadeFraction * animationDuration

        let sequence: [AnimationStep] = [
            ScrollStep(timeStep: 0.0, position: .start, edgeFades: .trailing), // Starting at the origin point with trailing fade
            ScrollStep(timeStep: animationDelay, position: .start, edgeFades: .trailing), // Delay at origin point, maintaining fade state
            FadeStep(timeStep: 0.2, edgeFades: .both), // Fade leading edge in as well after 0.2sec
            FadeStep(timeStep: startFadeTime - animationDuration, edgeFades: .both), // Maintain fade state until just before reaching end of scroll animation
            ScrollStep(timeStep: animationDuration, position: .end, edgeFades: .trailing), // Ending point (back at starting point) with trailing fade
        ]

        scrollLabel.frame = originalLabelFrame

        replicatorLayer?.instanceCount = 2
        replicatorLayer?.instanceTransform = CATransform3DMakeTranslation(-scrollLabelOffset, 0.0, 0.0)

        applyGradientMask(fadeWidth, animated: isMarqueeEnabled)
        let (scrollAnimation, scrollAnimationDuration) = generateScrollAnimation(sequence)
        let fadeAnimation = generateGradientAnimation(sequence, totalDuration: scrollAnimationDuration)
        scroll(scrollAnimation, duration: scrollAnimationDuration, fadeAnimation: fadeAnimation)
    }

    // MARK: State Interaction
    func start() {
        guard labelShouldScroll && !isInOriginalPosition else { return }
        updateAndScroll()
    }

    func restart() {
        stop()
        guard labelShouldScroll else { return }
        updateAndScroll()
    }

    func stop() {
        moveLabelToStartPosition()
        applyGradientMask(fadeWidth, animated: false)
    }

    // MARK: Overriden properties
    override func forBaselineLayout() -> UIView { return scrollLabel }
    override var forLastBaselineLayout: UIView { return scrollLabel }

    override var baselineAdjustment: UIBaselineAdjustment {
        get { return scrollLabel.baselineAdjustment }
        set {
            scrollLabel.baselineAdjustment = newValue
            super.baselineAdjustment = newValue
        }
    }

    override var numberOfLines: Int {
        get { return super.numberOfLines }
        set { super.numberOfLines = 1; _ = newValue } // Marquee label should only have 1 line by design
    }

    override var adjustsFontSizeToFitWidth: Bool {
        get { return super.adjustsFontSizeToFitWidth }
        set { super.adjustsFontSizeToFitWidth = false; _ = newValue } // Marquee label should not adjust size
    }

    override var text: String? {
        get { return scrollLabel.text }
        set {
            if scrollLabel.text == newValue { return }
            scrollLabel.text = newValue
            updateAndScroll()
            super.text = text
        }
    }

    override var attributedText: NSAttributedString? {
        get { return scrollLabel.attributedText }
        set {
            if scrollLabel.attributedText == newValue { return }
            scrollLabel.attributedText = newValue
            updateAndScroll()
            super.attributedText = attributedText
        }
    }

    override var font: UIFont! {
        get { return scrollLabel.font }
        set {
            if scrollLabel.font == newValue { return }
            scrollLabel.font = newValue
            super.font = newValue
            updateAndScroll()
        }
    }

    override var textColor: UIColor! {
        get { return scrollLabel.textColor }
        set {
            scrollLabel.textColor = newValue
            super.textColor = newValue
        }
    }

    override var backgroundColor: UIColor? {
        get { return scrollLabel.backgroundColor }
        set {
            scrollLabel.backgroundColor = newValue
            super.backgroundColor = newValue
        }
    }

    override var intrinsicContentSize: CGSize {
        var content = scrollLabel.intrinsicContentSize
        content.width += leftMargin
        return content
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var fitSize = scrollLabel.sizeThatFits(size)
        fitSize.width += leftMargin
        return fitSize
    }
}

// MARK: Animation
extension MarqueeLabel : CAAnimationDelegate {
    func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
        guard let setupAnimation = animation as? CABasicAnimation else { scrollCompletionBlock?(flag); return }

        given(setupAnimation.toValue as? [CGColor]) { maskLayer?.colors = $0 }
        maskLayer?.removeAnimation(forKey: "setupFade")
    }

    private func scroll(_ scrollAnimation: CAKeyframeAnimation, duration: TimeInterval, fadeAnimation: CAKeyframeAnimation?) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)

        if fadeWidth > 0.0 {
            if let setupAnim = maskLayer?.animation(forKey: "setupFade") as? CABasicAnimation, let finalColors = setupAnim.toValue as? [CGColor] {
                maskLayer?.colors = finalColors
            }
            maskLayer?.removeAnimation(forKey: "setupFade")
            given(fadeAnimation) { maskLayer?.add($0, forKey: "gradient") }
        }

        scrollCompletionBlock = { [weak self] finished in
            guard let strongSelf = self else { return }
            guard strongSelf.window != nil else { return }
            guard strongSelf.scrollLabel.layer.animation(forKey: #keyPath(CALayer.position)) == nil else { return }
            guard finished else { return }
            guard strongSelf.labelShouldScroll else { return }
            strongSelf.scroll(scrollAnimation, duration: duration, fadeAnimation: fadeAnimation)
        }

        scrollAnimation.delegate = self
        scrollLabel.layer.add(scrollAnimation, forKey: #keyPath(CALayer.position))

        CATransaction.commit()
    }

    private func generateScrollAnimation(_ sequence: [AnimationStep]) -> (CAKeyframeAnimation, TimeInterval) {
        let startOrigin = originalLabelFrame.origin
        var endOrigin = originalLabelFrame.origin
        endOrigin.x += scrollLabelOffset

        let scrollSteps = sequence.compactMap { $0 as? ScrollStep }
        let totalDuration = scrollSteps.reduce(0.0) { $0 + $1.timeStep }

        var totalTime: CGFloat = 0.0
        var scrollKeyTimes: [NSNumber] = []
        var scrollKeyValues: [Any] = []

        for step in scrollSteps {
            totalTime += step.timeStep
            scrollKeyTimes.append(NSNumber(value: Float(totalTime / totalDuration)))

            let scrollPosition: CGPoint
            switch step.position {
            case .start: scrollPosition = startOrigin
            case .end: scrollPosition = endOrigin
            case .partial(let frac):
                var newOrigin = startOrigin
                newOrigin.x += scrollLabelOffset * frac
                scrollPosition = newOrigin
            }
            scrollKeyValues.append(scrollPosition)
        }

        let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        animation.keyTimes = scrollKeyTimes
        animation.values = scrollKeyValues

        return (animation, TimeInterval(totalDuration))
    }

    private func generateGradientAnimation(_ sequence: [AnimationStep], totalDuration: TimeInterval) -> CAKeyframeAnimation {
        var totalTime: CGFloat = 0.0
        var stepTime: CGFloat = 0.0
        var fadeKeyTimes: [NSNumber] = []
        var fadeKeyValues: [Any] = []
        let transparent = UIColor.clear.cgColor
        let opaque = UIColor.black.cgColor

        let fadeSteps = sequence.enumerated().filter { offset, element in
            if element is ScrollStep { return true }
            // Include all Fade Steps that have a directly preceding or subsequent Scroll Step
            // Fade Step cannot be first step
            if offset == 0 { return false }
            // Subsequent step if 1) positive/zero time step and 2) follows a Scroll Step
            let subsequent = element.timeStep >= 0 && (sequence[max(0, offset - 1)] is ScrollStep)
            // Precedent step if 1) negative time step and 2) precedes a Scroll Step
            let precedent = element.timeStep < 0 && (sequence[min(sequence.count - 1, offset + 1)] is ScrollStep)

            return (precedent || subsequent)
        }

        for (offset, step) in fadeSteps {
            if step is ScrollStep {
                totalTime += step.timeStep
                stepTime = totalTime
            } else {
                if step.timeStep >= 0 {
                    stepTime = totalTime + step.timeStep // Is a Subsequent
                } else {
                    stepTime = totalTime + fadeSteps[offset + 1].element.timeStep + step.timeStep // Is a Precedent, grab next step
                }
            }
            let keyTime = Float(stepTime) / Float(totalDuration)
            fadeKeyTimes.append(NSNumber(value: keyTime))

            let values: [CGColor]
            let leading = step.edgeFades.hasLeading ? transparent : opaque
            let trailing = step.edgeFades.hasTrailing ? transparent : opaque
            if reverseScrolling {
                values = [trailing, opaque, opaque, leading]
            } else {
                values = [leading, opaque, opaque, trailing]
            }
            fadeKeyValues.append(values)
        }

        let animation = CAKeyframeAnimation(keyPath: "colors")
        animation.values = fadeKeyValues
        animation.keyTimes = fadeKeyTimes
        return animation
    }

    private func applyGradientMask(_ fadeWidth: CGFloat, animated: Bool, firstStep: AnimationStep? = nil) {
        maskLayer?.removeAllAnimations()

        guard fadeWidth > 0.0 else { return removeGradientMask() }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let gradientMask: CAGradientLayer
        if let currentMask = maskLayer {
            gradientMask = currentMask
        } else {
            gradientMask = CAGradientLayer()
            gradientMask.shouldRasterize = true
            gradientMask.rasterizationScale = UIScreen.main.scale
            gradientMask.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientMask.endPoint = CGPoint(x: 1.0, y: 0.5)
        }

        if gradientMask.bounds != layer.bounds {
            let leftFadeStop = fadeWidth / bounds.size.width
            let rightFadeStop = 1.0 - fadeWidth / bounds.size.width
            gradientMask.locations = [ 0.0, leftFadeStop, rightFadeStop, 1.0 ].map { NSNumber(value: Float($0)) }
        }

        gradientMask.bounds = layer.bounds
        gradientMask.position = CGPoint(x: bounds.midX, y: bounds.midY)

        let transparent = UIColor.clear.cgColor
        let opaque = UIColor.black.cgColor

        layer.mask = gradientMask

        let adjustedColors: [CGColor]
        let trailingFadeNeeded = labelShouldScroll

        if reverseScrolling {
            adjustedColors = [ trailingFadeNeeded ? transparent : opaque, opaque, opaque, opaque ]
        } else {
            adjustedColors = [ opaque, opaque, opaque, trailingFadeNeeded ? transparent : opaque ]
        }

        if animated {
            CATransaction.commit()
            let colorAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.colors))
            colorAnimation.fromValue = gradientMask.colors
            colorAnimation.toValue = adjustedColors
            colorAnimation.fillMode = .forwards
            colorAnimation.isRemovedOnCompletion = false
            colorAnimation.delegate = self
            gradientMask.add(colorAnimation, forKey: "setupFade")
        } else {
            gradientMask.colors = adjustedColors
            CATransaction.commit()
        }
    }

    private func removeGradientMask() { layer.mask = nil }
}

// MARK: Types
private protocol AnimationStep {
    var timeStep: CGFloat { get }
    var edgeFades: MarqueeLabel.Edge { get }
}

extension MarqueeLabel {
    enum Edge {
        case leading, trailing, both

        var hasLeading: Bool { return self != .trailing }
        var hasTrailing: Bool { return self != .leading }
    }

    struct ScrollStep : AnimationStep {
        enum Position {
            case start
            case end
            case partial(CGFloat)
        }

        let timeStep: CGFloat
        let position: Position
        let edgeFades: Edge

        public init(timeStep: CGFloat, position: Position, edgeFades: Edge) {
            self.timeStep = timeStep
            self.position = position
            self.edgeFades = edgeFades
        }
    }

    struct FadeStep : AnimationStep {
        let timeStep: CGFloat
        let edgeFades: Edge

        public init(timeStep: CGFloat, edgeFades: Edge) {
            self.timeStep = timeStep
            self.edgeFades = edgeFades
        }
    }
}
