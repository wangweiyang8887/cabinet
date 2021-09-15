// Copyright © 2021 evan. All rights reserved.

final class DailyRow : BaseRow {
    @IBOutlet private var redLabel: UILabel!
    @IBOutlet private var redContentLabel: UILabel!
    @IBOutlet private var greenLabel: UILabel!
    @IBOutlet private var greenContentLabel: UILabel!
    @IBOutlet private var constellationLabel: UILabel!
    @IBOutlet private var monthWeekLabel: UILabel!
    @IBOutlet private var lunarLabel: UILabel!
    @IBOutlet private var dayLabel: UILabel!
    
    override class var height: RowHeight { return .fixed(168) }
    override class var nibName: String? { return "DailyRow" }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(uniform: 16) }
    
    var daily: DailyModel? { didSet { handleDailyChanged() } }
    
    override func initialize() {
        super.initialize()
        backgroundColor = .clear
        let gradientView = TTGradientView(gradient: .denimToJava)
        gradientView.cornerRadius = 16
        contentView.addSubview(gradientView, pinningEdges: .all)
        contentView.sendSubviewToBack(gradientView)
        contentView.cornerRadius = 16
        contentView.addShadow(radius: 16, yOffset: -1)
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
    
    private func handleDailyChanged() {
        guard let daily = daily else { return }
        redContentLabel.text = daily.todayRed
        greenContentLabel.text = daily.todayGreen
        constellationLabel.text = daily.constellation
        dayLabel.text = String(format: "%ld", CalendarDate.today(in: .current).day)
        monthWeekLabel.text = daily.monthAndWeek
        lunarLabel.text = daily.lunarDate
    }
}
