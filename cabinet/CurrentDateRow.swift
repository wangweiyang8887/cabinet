// Copyright © 2021 evan. All rights reserved.

final class CurrentDateRow : BaseRow {
    override class var height: RowHeight { return .fixed(168) }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(uniform: 16) }
    
    override func initialize() {
        super.initialize()
        let gradientView = TTGradientView(gradient: [ UIColor.red.withAlphaComponent(0.2), UIColor.purple.withAlphaComponent(0.2) ])
        gradientView.cornerRadius = 16
        contentView.addSubview(gradientView, pinningEdges: .all)
        contentView.cornerRadius = 16
        contentView.addShadow(radius: 16, yOffset: -1)
        contentView.addSubview(dateLabel, pinningEdges: .all)
        contentView.addSubview(titleLabel, pinningEdges: [ .left, .top, .right ], withInsets: UIEdgeInsets(uniform: 16))
        TimerManager.shared.fire { [weak self] in
            self?.dateLabel.text = Date().cabinetTimeDateFormatted()
        }
    }
    
    override func handleDidSelect() {
        super.handleDidSelect()
        let delegate = PushTransitionDelegate()
        let vc = CurrentDateVC()
        vc.transitioningDelegate = delegate
        UIViewController.current().present(vc, animated: true, completion: nil)
    }
    
    private lazy var titleLabel: UILabel = {
        let result = UILabel()
        result.text = "Clock 时钟"
        result.textColor = .white
        result.font = .systemFont(ofSize: 17, weight: .medium)
        return result
    }()
    
    private lazy var dateLabel: UILabel = {
        let result = UILabel()
        result.numberOfLines = 0
        result.textAlignment = .center
        result.font = UIFont(name: "Helvetica Neue", size: 48)
        result.textColor = .white
        result.defaultTextShadow()
        return result
    }()
}
