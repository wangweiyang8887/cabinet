// Copyright © 2021 evan. All rights reserved.

final class CalendarView : UIView, Palletable {
    @IBOutlet private var redLabel: ColorableLabel!
    @IBOutlet private var redContentLabel: ColorableLabel!
    @IBOutlet private var greenLabel: ColorableLabel!
    @IBOutlet private var greenContentLabel: ColorableLabel!
    @IBOutlet private var constellationLabel: ColorableLabel!
    @IBOutlet private var monthWeekLabel: ColorableLabel!
    @IBOutlet private var lunarLabel: ColorableLabel!
    @IBOutlet private var dayLabel: ColorableLabel!
    
    var daily: DailyModel? { didSet { handleDailyChanged() } }
    var chineseCalendar: ChineseCalendarModel? { didSet { handleChineseCalendarChanged() } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        redLabel.borderColor = .white
        redLabel.borderWidth = 2
        redLabel.cornerRadius = 22

        greenLabel.borderColor = .white
        greenLabel.borderWidth = 2
        greenLabel.cornerRadius = 22
        
        addSubview(imageView, pinningEdges: .all)
        sendSubviewToBack(imageView)
        addSubview(gradientView, pinningEdges: .all)
        sendSubviewToBack(gradientView)
        imageView.cornerRadius = 16
        gradientView.cornerRadius = 16
        cornerRadius = 16
        getUserDefaultIfNeeded()
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        guard tintColor != .clear else { return }
        viewIterator { $0.tintColor = tintColor }
        redLabel.borderColor = tintColor
        greenLabel.borderColor = tintColor
    }
    
    func getUserDefaultIfNeeded() {
        if let data = UserDefaults.shared[.calendarBackground] {
            if let image = UIImage(data: data) {
                self.image = image
            } else if let hex = String(data: data, encoding: .utf8) {
                gradient = TTGradient(components: hex.components(separatedBy: .whitespaces).map { UIColor(hex: $0) })
            }
        }
        if let data = UserDefaults.shared[.calendarForeground], let hex = String(data: data, encoding: .utf8) {
            foregroundColor = UIColor(hex: hex)
        } else {
            tintColor = .clear
        }
    }
    
    private func handleDailyChanged() {
        guard let daily = daily else { return }
        constellationLabel.text = daily.constellation
    }
    
    private func handleChineseCalendarChanged() {
        guard let calendar = chineseCalendar else { return }
        redContentLabel.text = calendar.todayYI.trimmedNilIfEmpty ?? "-"
        greenContentLabel.text = calendar.todayJI.trimmedNilIfEmpty ?? "-"
        dayLabel.text = String(format: "%ld", CalendarDate.today(in: .current).day)
        monthWeekLabel.text = String(format: "%@ %@", Calendar.currentMonth, Calendar.currentWeek)
        lunarLabel.text = String(format: "%@ %@", Calendar.lunarYear, Calendar.lunarMonthAndDay)
    }
    
    private lazy var gradientView: TTGradientView = {
        let result = TTGradientView(gradient: .denimToJava)
        return result
    }()
    
    private lazy var imageView: UIImageView = {
        let result = UIImageView()
        result.contentMode = .scaleAspectFill
        result.backgroundColor = .clear
        return result
    }()
    
    // MARK: Accessors
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

final class CalendarRow : BaseRow {
    override class var height: RowHeight { return .fixed(168) }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(uniform: 16) }
    
    var daily: DailyModel? { didSet { calendarView.daily = daily } }
    var chineseCalendar: ChineseCalendarModel? { didSet { calendarView.chineseCalendar = chineseCalendar } }
    
    override func initialize() {
        super.initialize()
        backgroundColor = .clear
        contentView.cornerRadius = 16
        contentView.addShadow(radius: 16, yOffset: -1)
        contentView.addSubview(calendarView, pinningEdges: .all)
        let longPress = UILongPressGestureRecognizer()
        longPress.addTarget(self, action: #selector(longPress(_:)))
        calendarView.addGestureRecognizer(longPress)
    }
        
    @objc private func longPress(_ longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began:
            CalendarColorPickerVC.show(with: UIViewController.current(), calendar: chineseCalendar) { [unowned self] in
                self.calendarView.getUserDefaultIfNeeded()
            }
        default: break
        }
    }
    
    private lazy var calendarView = CalendarView.loadFromNib()
}
