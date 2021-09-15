// Copyright © 2021 evan. All rights reserved.

final class ReminderRow : BaseRow {
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var numberLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    
    private static let calculatedHeight: CGFloat = (UIScreen.main.bounds.width - 32 - 16) / 2
    
    override class var nibName: String? { return "ReminderRow" }
    override class var height: RowHeight { return .fixed(calculatedHeight) }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(uniform: 16) }
    
    override func initialize() {
        super.initialize()
        backgroundColor = .clear
        let gradientViewV2 = TTGradientView(gradient: .heliotropeToCerulean)
        containerView.addSubview(gradientViewV2, pinningEdges: .all)
        containerView.sendSubviewToBack(gradientViewV2)
        containerView.cornerRadius = 16
        containerView.constrainWidth(to: Self.calculatedHeight)
    }
    
    // MARK: Accessors
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var day: String? {
        get { return numberLabel.text }
        set { numberLabel.text = newValue }
    }

    var date: String? {
        get { return dateLabel.text }
        set { dateLabel.text = newValue
            guard let dateString = newValue else { return }
            guard let date = DateFormatter(dateFormat: "YYYY.MM.dd").date(from: dateString) else { return }
            let date1 = CalendarDate.today(in: .current)
            let date2 = CalendarDate(date: date, timeZone: .current)
            let distant = CalendarDate.component(.day, from: date1, to: date2)
            numberLabel.text = "\(abs(distant))"
        }
    }
    
}
