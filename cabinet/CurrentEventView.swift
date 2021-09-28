// Copyright © 2021 evan. All rights reserved.

class CurrentEventView : UIView, Palletable {
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventDayLabel: UILabel!
    
    var eventModel: EventModel? { didSet { handleEventModelChanged() } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(imageView, pinningEdges: .all)
        sendSubviewToBack(imageView)
        addSubview(gradientView, pinningEdges: .all)
        sendSubviewToBack(gradientView)
        imageView.cornerRadius = 16
        gradientView.cornerRadius = 16
        cornerRadius = 16
        addShadow(radius: 16, yOffset: -1)
    }
    
    private func handleEventModelChanged() {
        guard let model = eventModel else { return }
        eventNameLabel.text = model.name
        eventDateLabel.text = model.date
        guard let dateString = model.date else { return }
        guard let date = DateFormatter(dateFormat: "YYYY.MM.dd").date(from: dateString) else { return }
        let date1 = CalendarDate.today(in: .current)
        let date2 = CalendarDate(date: date, timeZone: .current)
        let distant = CalendarDate.component(.day, from: date1, to: date2)
        eventDayLabel.text = "\(abs(distant))"
    }
    
    private lazy var gradientView: TTGradientView = {
        let result = TTGradientView(gradient: .heliotropeToCerulean)
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
}
