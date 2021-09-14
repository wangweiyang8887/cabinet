// Copyright © 2021 evan. All rights reserved.

final class DailyRow : BaseRow {
    @IBOutlet private var redLabel: UILabel!
    @IBOutlet private var redContentLabel: UILabel!
    @IBOutlet private var greenLabel: UILabel!
    @IBOutlet private var greenContentLabel: UILabel!
    
    override class var height: RowHeight { return .fixed(168) }
    override class var nibName: String? { return "DailyRow" }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(uniform: 16) }
    
    override func initialize() {
        super.initialize()
        backgroundColor = .clear
        let gradientView = TTGradientView(gradient: [ .nonStandardColor(withRGBHex: 0xABDCFF), .nonStandardColor(withRGBHex: 0x0396FF) ], direction: .topToBottom)
        contentView.addSubview(gradientView, pinningEdges: .all)
        contentView.sendSubviewToBack(gradientView)
        contentView.cornerRadius = 16
        redLabel.borderColor = .cabinetWhite
        redLabel.borderWidth = 2
        redLabel.cornerRadius = 22
        
        greenLabel.borderColor = .cabinetWhite
        greenLabel.borderWidth = 2
        greenLabel.cornerRadius = 22
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        redLabel.borderColor = .cabinetWhite
        greenLabel.borderColor = .cabinetWhite
    }
}
