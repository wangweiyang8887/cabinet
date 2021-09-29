// Copyright © 2021 evan. All rights reserved.

final class ClockRow : BaseRow, Palletable {
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
        contentView.addSubview(dateLabel, pinningEdges: .all)
        contentView.addSubview(titleLabel, pinningEdges: [ .left, .top, .right ], withInsets: UIEdgeInsets(uniform: 16))
        titleLabel.defaultTextShadow()
        getUserDefaultIfNeeded()
        let longPress = UILongPressGestureRecognizer()
        longPress.addTarget(self, action: #selector(longPress(_:)))
        addGestureRecognizer(longPress)
        addTapGestureHandler {
            let delegate = PushTransitionDelegate()
            let vc = CurrentDateVC()
            vc.transitioningDelegate = delegate
            UIViewController.current().present(vc, animated: true, completion: nil)
        }
        TimerManager.shared.fire { [weak self] in
            self?.dateLabel.text = Date().cabinetTimeDateFormatted()
        }
    }
        
    @objc private func longPress(_ longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began:
            ClockColorPickerVC.show(with: UIViewController.current()) { [unowned self] in
                self.getUserDefaultIfNeeded()
            }
        default: break
        }
    }
    
    func getUserDefaultIfNeeded() {
        if let data = UserDefaults.shared[.clockBackground] {
            if let image = UIImage(data: data) {
                self.image = image
            } else if let hex = String(data: data, encoding: .utf8) {
                gradient = TTGradient(components: hex.components(separatedBy: .whitespaces).map { UIColor(hex: $0) })
            }
        }
        if let data = UserDefaults.shared[.clockForeground], let hex = String(data: data, encoding: .utf8) {
            foregroundColor = UIColor(hex: hex)
        } else {
            tintColor = .clear
        }
    }
    
    private lazy var titleLabel: ColorableLabel = {
        let result = ColorableLabel()
        result.text = "Clock 时钟"
        result.textColor = .white
        result.font = .systemFont(ofSize: 17, weight: .medium)
        return result
    }()
    
    private lazy var dateLabel: ColorableLabel = {
        let result = ColorableLabel()
        result.numberOfLines = 0
        result.textAlignment = .center
        result.font = UIFont(name: "Helvetica Neue", size: 48)
        result.textColor = .white
        result.defaultTextShadow()
        return result
    }()
        
    private lazy var gradientView: TTGradientView = {
        let result = TTGradientView(gradient: [ UIColor.red.withAlphaComponent(0.2), UIColor.purple.withAlphaComponent(0.2) ])
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

