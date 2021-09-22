// Copyright © 2021 evan. All rights reserved.

final class ColorSliderRow : BaseRow {
    private var red: CGFloat = 0.0
    private var green: CGFloat = 0.0
    private var blue: CGFloat = 0.0
    
    var valueChangedHandler: ValueChangedHandler<Float>?
    var value: Float = 0.0 { didSet { slider.value = value } }
    
    override class var margins: UIEdgeInsets { return UIEdgeInsets(uniform: 16) }
    
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.init()
        (self.red, self.green, self.blue) = (red, green, blue)
        setup(with: UIColor(red: red, green: green, blue: blue, alpha: 1))
    }
    
    private func setup(with color: UIColor) {
        backgroundColor = color;
        layer.borderColor = UIColor.cabinetMediumGray.cgColor
        layer.borderWidth = 1;
        layer.cornerRadius = 16
        
        layer.addSublayer(gradientLayer)
        addSubview(slider, pinningEdges: .all)
        slider.value = 0.5
        valueChanged(slider)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
    }
    
    @objc func valueChanged(_ slider: UISlider) {
        valueChangedHandler?(slider.value)
        if !red.isZero {
            updateColor(with: CGFloat(slider.value), green: 0, blue: 0)
        }
        if !green.isZero {
            updateColor(with: 0, green: CGFloat(slider.value), blue: 0)
        }
        if !blue.isZero {
            updateColor(with: 0, green: CGFloat(slider.value), blue: CGFloat(slider.value))
        }
    
    }
    
    private func updateColor(with red: CGFloat, green: CGFloat, blue: CGFloat) {
        gradientLayer.colors = [ UIColor(red: max(red, 0), green: max(green, 0), blue: max(blue, 0), alpha: 1).cgColor, UIColor(red: max(red, self.red), green: max(green, self.green), blue: max(blue, self.blue), alpha: 1).cgColor ]
        setNeedsDisplay()
    }
    
    private lazy var gradientLayer: CAGradientLayer = {
        let result = CAGradientLayer()
        result.colors = [ UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor, UIColor(red: red, green: green, blue: blue, alpha: 1).cgColor ]
        result.startPoint = .zero
        result.endPoint = CGPoint(x: 1, y: 0)
        result.cornerRadius = 16
        return result
    }()
    
    private lazy var slider: UISlider = {
        let result = UISlider()
        result.maximumValue = 1.0
        result.minimumValue = 0.0
        result.minimumTrackTintColor = .clear
        result.maximumTrackTintColor = .clear
        result.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        return result
    }()
}
