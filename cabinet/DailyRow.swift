// Copyright © 2021 evan. All rights reserved.

final class DailyRow : BaseRow {
    override class var height: RowHeight { return .fixed(168) }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(uniform: 16) }
    
    override func initialize() {
        super.initialize()
        backgroundColor = .clear
        let gradientView = TTGradientView(gradient: [ UIColor.red.withAlphaComponent(0.4), UIColor.blue.withAlphaComponent(0.4) ])
        gradientView.cornerRadius = 16
        contentView.addSubview(gradientView, pinningEdges: .all)
        contentView.sendSubviewToBack(gradientView)
        contentView.cornerRadius = 16
        contentView.addShadow(radius: 16, yOffset: -1)
        contentView.addSubview(titleLabel, pinningEdges: .all, withInsets: UIEdgeInsets(uniform: 16))
        titleLabel.defaultTextShadow()
    }
    
    private lazy var titleLabel: UILabel = UILabel(text: "", font: .systemFont(ofSize: 15), color: .white, alignment: .center, lines: 0)
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
}
