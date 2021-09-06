// Copyright © 2021 evan. All rights reserved.

final class CurrentDateRow : BaseRow {
    override class var height: RowHeight { return .fixed(168) }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(uniform: 16) }
    
    override func initialize() {
        super.initialize()
        let gradientView = TTGradientView(gradient: [ .nonStandardColor(withRGBHex: 0xABDCFF), .nonStandardColor(withRGBHex: 0x0396FF) ], direction: .leftToRight)
        contentView.addSubview(gradientView, pinningEdges: .all)
        cornerRadius = 16
        contentView.addSubview(titleLabel, pinningEdges: .all)
        TimerManager.shared.fire { [weak self] in
            self?.titleLabel.text = Date().cabinetTimeDateFormatted()
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
        result.numberOfLines = 0
        result.textAlignment = .center
        result.font = UIFont(name: "Helvetica Neue", size: 32)
        result.textColor = .nonStandardColor(withRGBHex: 0x333333)
        result.defaultTextShadow()
        return result
    }()
}
