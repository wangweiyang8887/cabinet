// Copyright © 2021 evan. All rights reserved.

extension UILabel {
    public convenience init(text: String? = nil, font: UIFont? = nil, color: UIColor? = nil, alignment: NSTextAlignment = .left, lines: Int = 1) {
        self.init()
        (self.text, self.font, self.textColor, self.textAlignment, self.numberOfLines) = (text, font, color, alignment, lines)
    }
    
    @objc static func label(with text: String? = nil, font: UIFont? = nil, color: UIColor? = nil) -> UILabel {
        return UILabel(text: text, font: font, color: color, alignment: .left, lines: 1)
    }
    
    func defaultTextShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
    }
}
