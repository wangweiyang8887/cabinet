// Copyright © 2021 evan. All rights reserved.

class TTGradientView : UIView {
    private let gradientAnimationKey = "arbitrary-gradient-animation-key"

    private var gradientIndex = 0
    private var finalGradient: TTGradient?
    private var shouldStopAnimating: Bool = false
    private(set) var isAnimating: Bool = false

    var gradient: TTGradient = .color(.white) { didSet { update() } }
    var direction: TTGradient.Direction = .topLeftToBottomRight { didSet { update() } }
    var animationDuration: TimeInterval = 5
    var animatedDirection: Bool = false

    // MARK: Settings
    override class var layerClass: AnyClass { return CAGradientLayer.self }
    override var layer: CAGradientLayer { return super.layer as! CAGradientLayer }

    // MARK: Lifecycle
    convenience init(gradient: TTGradient, direction: TTGradient.Direction = .topLeftToBottomRight) {
        self.init()
        self.gradient = gradient
        self.direction = direction
        update()
    }

    override init(frame: CGRect) { super.init(frame: frame); update() }
    required init?(coder: NSCoder) { super.init(coder: coder); update() }

    // MARK: Updating
    private func update() {
        gradient.apply(to: layer, direction: direction)
    }

    // MARK: Interactions
    func animate(fromStart: Bool = true, using customGradients: [TTGradient]? = nil, forcing customToGradient: TTGradient? = nil) {
        guard !isAnimating else { return }
        isAnimating = true
        let fromGradient: TTGradient
        let toGradient: TTGradient
        let gradients = customGradients ?? [ .color(.white) ]
        if fromStart {
            layer.removeAllAnimations()
            gradientIndex = 0
            fromGradient = gradients[gradientIndex]
            toGradient = customToGradient ?? gradients[gradientIndex + 1]
        } else {
            if let gradient = gradients[ifPresent: gradientIndex + 2] {
                toGradient = customToGradient ?? gradient
                gradientIndex += 1
                fromGradient = gradients[gradientIndex]
            } else {
                fromGradient = gradients[gradientIndex + 1]
                gradientIndex = 0
                toGradient = customToGradient ?? gradients[gradientIndex]
            }
        }
        let direction: [TTGradient.Direction] = [ .topLeftToBottomRight, .leftToRight, .bottomToTop, .bottomRightToTopLeft, .rightToLeft, .topRightToBottomLeft, .topToBottom ]
        toGradient.apply(to: layer, direction: animatedDirection ? direction[gradientIndex % direction.count] : .topLeftToBottomRight)
        let oldColors: [CGColor] = fromGradient.components.map { $0.cgColor }
        let newColors: [CGColor] = toGradient.components.map { $0.cgColor }
        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.colors))
        animation.duration = animationDuration
        animation.fromValue = oldColors
        animation.toValue = newColors
        animation.fillMode = .forwards
        animation.delegate = self
        layer.add(animation, forKey: gradientAnimationKey)
    }

    func stopAnimation(finalGradient: TTGradient) {
        shouldStopAnimating = true
        self.finalGradient = finalGradient
    }
}

extension TTGradientView : CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        isAnimating = false
        if shouldStopAnimating {
            if let finalGradient = finalGradient {
                animate(fromStart: false, forcing: finalGradient)
                self.finalGradient = nil
            } else {
                shouldStopAnimating = false
            }
        } else {
            if animatedDirection {
                animate(fromStart: false, using: Array(repeating: gradient, count: 7))
            } else {
                animate(fromStart: false)
            }
        }
    }
}
