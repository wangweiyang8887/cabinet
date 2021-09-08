// Copyright © 2021 evan. All rights reserved.

final class DailyRow : BaseRow {
    @IBOutlet private var redLabel: UILabel!
    @IBOutlet private var redContentLabel: UILabel!
    @IBOutlet private var greenLabel: UILabel!
    @IBOutlet private var greenContentLabel: UILabel!
    
    override class var height: RowHeight { return .fixed(168) }
    override class var nibName: String? { return "DailyRow" }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(horizontal: 16) }
    
    override func initialize() {
        super.initialize()
        backgroundColor = .clear
        let gradientView = TTGradientView(gradient: [ .nonStandardColor(withRGBHex: 0xABDCFF), .nonStandardColor(withRGBHex: 0x0396FF) ], direction: .leftToRight)
        contentView.addSubview(gradientView, pinningEdges: .all)
        contentView.sendSubviewToBack(gradientView)
        contentView.cornerRadius = 16
        redLabel.borderColor = .red
        redLabel.borderWidth = 2
        redLabel.cornerRadius = 22
        
        greenLabel.borderColor = .green
        greenLabel.borderWidth = 2
        greenLabel.cornerRadius = 22
    }
}
