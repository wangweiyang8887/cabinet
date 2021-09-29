// Copyright © 2021 evan. All rights reserved.

final class DailyRow : BaseRow, Palletable {
    override class var height: RowHeight { return .fixed(168) }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(uniform: 16) }
    
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
        contentView.addSubview(titleLabel, pinningEdges: .all, withInsets: UIEdgeInsets(uniform: 16))
        titleLabel.defaultTextShadow()
        getUserDefaultIfNeeded()
        let longPress = UILongPressGestureRecognizer()
        longPress.addTarget(self, action: #selector(longPress(_:)))
        addGestureRecognizer(longPress)
    }
        
    @objc private func longPress(_ longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began:
            DailyColorPickerVC.show(with: UIViewController.current(), text: title) { [unowned self] in
                self.getUserDefaultIfNeeded()
            }
        default: break
        }
    }
    
    func getUserDefaultIfNeeded() {
        if let data = UserDefaults.shared[.dailyBackground] {
            if let image = UIImage(data: data) {
                self.image = image
            } else if let hex = String(data: data, encoding: .utf8) {
                gradient = TTGradient(components: hex.components(separatedBy: .whitespaces).map { UIColor(hex: $0) })
            }
        }
        if let data = UserDefaults.shared[.dailyForeground], let hex = String(data: data, encoding: .utf8) {
            foregroundColor = UIColor(hex: hex)
        } else {
            tintColor = .clear
        }
    }
    
    private lazy var titleLabel: ColorableLabel = ColorableLabel(text: "", font: .systemFont(ofSize: 17, weight: .medium), color: .white, alignment: .center, lines: 0)
    
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
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
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
