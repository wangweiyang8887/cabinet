// Copyright © 2021 evan. All rights reserved.

import EFCountingLabel

final class CountingRow : BaseRow, Palletable {
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var randomButton: UIButton!
    @IBOutlet weak var oneLabel: CountingLabel!
    @IBOutlet weak var twoLabel: CountingLabel!
    @IBOutlet weak var threeLabel: CountingLabel!
    @IBOutlet weak var fourLabel: CountingLabel!
    @IBOutlet weak var fiveLabel: CountingLabel!
    @IBOutlet weak var sixLabel: CountingLabel!
    @IBOutlet weak var sevenLabel: CountingLabel!
        
    override class var height: RowHeight { return .fixed(168) }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(uniform: 16) }
    override class var nibName: String? { return "CountingRow" }
    
    enum Kind { case ssq, dlt }
    
    private var kind: Kind = .ssq
    private lazy var ssqReds: [Int] = (1...maximumRedValue).map { $0 }
    private lazy var ssqBlues: [Int] = (1...maximumBlueValue).map { $0 }
    private var redLables: [CountingLabel] { return [ oneLabel, twoLabel, threeLabel, fourLabel, fiveLabel ] + (kind == .ssq ? [ sixLabel ] : []) }
    private var blueLabels: [CountingLabel] { return kind == .ssq ? [ sevenLabel ] : [ sixLabel, sevenLabel ] }
    private var maximumRedValue: Int { return kind == .ssq ? 33 : 35 }
    private var maximumBlueValue: Int { return kind == .ssq ? 16 : 12  }
    
    override func initialize() {
        super.initialize()
        backgroundColor = .clear
        addSubview(imageView, pinningEdges: .all)
        sendSubviewToBack(imageView)
        addSubview(gradientView, pinningEdges: .all)
        sendSubviewToBack(gradientView)
        imageView.cornerRadius = 16
        gradientView.cornerRadius = 16
        contentView.cornerRadius = 16
        contentView.addShadow(radius: 16, yOffset: -1)
        (redLables + blueLabels).forEach { $0.defaultTextShadow() }
        typeLabel.borderWidth = 2
        typeLabel.borderColor = .white
        typeLabel.cornerRadius = 8
        randomButton.borderWidth = 2
        randomButton.borderColor = .white
        randomButton.cornerRadius = 8
        typeLabel.addTapGestureHandler { [unowned self] in
            if self.kind == .ssq {
                self.kind = .dlt
                self.typeLabel.text = "  超级大乐透  "
                self.sixLabel.textColor = .cabinetYellowV3
            } else {
                self.kind = .ssq
                self.typeLabel.text = "  双色球  "
                self.sixLabel.textColor = .white
            }
            self.fire()
        }
        randomButton.addTapHandler { [unowned self] in self.fire() }
        getUserDefaultIfNeeded()
        let longPress = UILongPressGestureRecognizer()
        longPress.addTarget(self, action: #selector(longPress(_:)))
        addGestureRecognizer(longPress)
    }
        
    @objc private func longPress(_ longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began:
            CountingColorPickerVC.show(with: UIViewController.current()) { [unowned self] in
                self.getUserDefaultIfNeeded()
            }
        default: break
        }
    }
    
    func getUserDefaultIfNeeded() {
        if let data = UserDefaults.shared[.countingBackground] {
            if let image = UIImage(data: data) {
                self.image = image
            } else if let hex = String(data: data, encoding: .utf8) {
                gradient = TTGradient(components: hex.components(separatedBy: .whitespaces).map { UIColor(hex: $0) })
            }
        }
    }
    
    private func fire() {
        ssqReds = (1...maximumRedValue).map { $0 }
        redLables.forEach { label in
            label.reset()
            label.count(from: 0, to: maximumRedValue, animated: true) { [unowned self] in
                label.text = String(format: "%02d", randomValue(&self.ssqReds))
                label.textColor = .white
            }
        }
        ssqBlues = (1...maximumBlueValue).map { $0 }
        blueLabels.forEach { label in
            label.reset()
            label.count(from: 0, to: maximumBlueValue, animated: true) { [unowned self] in
                label.text = String(format: "%02d", randomValue(&self.ssqBlues))
                label.textColor = .cabinetYellowV3
            }
        }
    }
    
    private func randomValue(_ items: inout [Int]) -> Int {
        let lock = NSLock()
        lock.lock()
        let value = items[Int.random(in: 0..<items.count)]
        items.remove(at: items.firstIndex(of: value) ?? 0)
        lock.unlock()
        return value
    }
    
    private lazy var gradientView: TTGradientView = {
        let result = TTGradientView(gradient: [ UIColor.red.withAlphaComponent(0.4), UIColor.blue.withAlphaComponent(0.4) ])
        return result
    }()
    
    private lazy var imageView: UIImageView = {
        let result = UIImageView()
        result.contentMode = .scaleAspectFill
        result.backgroundColor = .clear
        return result
    }()
    
    // MARK: Accessors
    var gradient: TTGradient {
        get { return gradientView.gradient }
        set { gradientView.gradient = newValue; imageView.image = nil }
    }

    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    var foregroundColor: UIColor {
        get { return tintColor }
        set { tintColor = newValue }
    }
}

final class CountingLabel : EFCountingLabel {
    private var lastValue: Int = 0
    private var isAnimating = false

    var gradient: TTGradient? {
        didSet {
            updateGradient()
        }
    }

    func count(from startValue: Int? = nil, to endValue: Int, duration: TimeInterval = 1, animated: Bool = true, completion: ActionClosure? = nil) {
        guard endValue != lastValue else { return }
        lastValue = endValue
        let totalDuration: TimeInterval = animated ? duration : 0
        if !isAnimating, let startValue = startValue {
            countFrom(CGFloat(startValue), to: CGFloat(endValue), withDuration: totalDuration)
        } else {
            countFromCurrentValueTo(CGFloat(endValue), withDuration: totalDuration)
        }
        setCompletionBlock { _ in
            completion?()
        }
        isAnimating = true
    }

    func update(_ updating: @escaping ((Decimal, EFCountingLabel) -> Void)) {
        setCompletionBlock { [weak self] _ in
            self?.isAnimating = false
        }
        setUpdateBlock { [weak self] value, label in
            updating(Decimal(Double(value)), label)
            self?.updateGradient()
        }
    }

    func reset() {
        lastValue = 0
        isAnimating = false
    }

    private func updateGradient() {
        guard let gradient = gradient else { return }
        sizeToFit()
        guard bounds != .zero else { return }
        textColor = UIColor(gradient: gradient, bounds: bounds)
    }
}
