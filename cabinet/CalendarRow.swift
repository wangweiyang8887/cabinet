// Copyright © 2021 evan. All rights reserved.

final class CalendarRow : BaseRow {
    @IBOutlet private var redLabel: UILabel!
    @IBOutlet private var redContentLabel: UILabel!
    @IBOutlet private var greenLabel: UILabel!
    @IBOutlet private var greenContentLabel: UILabel!
    @IBOutlet private var constellationLabel: UILabel!
    @IBOutlet private var monthWeekLabel: UILabel!
    @IBOutlet private var lunarLabel: UILabel!
    @IBOutlet private var dayLabel: UILabel!
    
    override class var height: RowHeight { return .fixed(168) }
    override class var nibName: String? { return "CalendarRow" }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(uniform: 16) }
    
    var daily: DailyModel? { didSet { handleDailyChanged() } }
    var chineseCalendar: ChineseCalendarModel? { didSet { handleChineseCalendarChanged() } }
    
    override func initialize() {
        super.initialize()
        backgroundColor = .clear
        let gradientView = TTGradientView(gradient: .denimToJava)
        gradientView.cornerRadius = 16
        contentView.addSubview(gradientView, pinningEdges: .all)
        contentView.sendSubviewToBack(gradientView)
        contentView.cornerRadius = 16
        contentView.addShadow(radius: 16, yOffset: -1)
        redLabel.borderColor = .white
        redLabel.borderWidth = 2
        redLabel.cornerRadius = 22
        
        greenLabel.borderColor = .white
        greenLabel.borderWidth = 2
        greenLabel.cornerRadius = 22
    }
    
    private func handleDailyChanged() {
        guard let daily = daily else { return }
        constellationLabel.text = daily.constellation
    }
    
    private func handleChineseCalendarChanged() {
        guard let calendar = chineseCalendar else { return }
        redContentLabel.text = calendar.todayYI
        greenContentLabel.text = calendar.todayJI
        dayLabel.text = String(format: "%ld", CalendarDate.today(in: .current).day)
        monthWeekLabel.text = String(format: "%@ %@", Calendar.currentMonth, Calendar.currentWeek)
        lunarLabel.text = String(format: "%@ %@", Calendar.lunarYear, Calendar.lunarMonthAndDay)
    }
}
