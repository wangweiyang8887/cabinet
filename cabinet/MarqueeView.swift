// Copyright © 2021 evan. All rights reserved.

import UIKit

class MarqueeView: UIView {}

class MarqueeRow : BaseRow {
    override class var height: RowHeight { return .fixed(168) }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(uniform: 16) }
    
    override func initialize() {
        super.initialize()
        contentView.backgroundColor = .cabinetBlack
        contentView.cornerRadius = 16
        contentView.addShadow(radius: 16, yOffset: -1)
        contentView.addSubview(marqueeLabel, pinningEdges: .all, withInsets: UIEdgeInsets(vertical: 16))
        addTapGestureHandler {
            let delegate = PushTransitionDelegate()
            let vc = MarqueeVC()
            vc.transitioningDelegate = delegate
            UIViewController.current().present(vc, animated: true, completion: nil)
        }
    }
    
    private lazy var marqueeLabel: MarqueeLabel = {
        let result = MarqueeLabel(frame: .zero, scrollRate: .random(in: 25...60), fadeWidth: 0)
        result.text = "Taylor Swift Taylor Swift Taylor Swift Taylor Swift"
        result.font = .systemFont(ofSize: 96, weight: .bold)
        result.isMarqueeEnabled = true
        result.labelShouldAlwaysScroll = true
        result.textColor = .cabinetWhite
        result.textAlignment = .center
        return result
    }()
}
