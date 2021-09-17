// Copyright © 2021 evan. All rights reserved.

import Foundation

final class CurrentWeatherRow : BaseRow {
    @IBOutlet weak var weatherContainerView: UIView!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherStateLabel: UILabel!
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var countDownContainerView: UIView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventDayLabel: UILabel!
    
    private static let calculatedHeight: CGFloat = (UIScreen.main.bounds.width - 32 - 16) / 2
    
    override class var nibName: String? { return "CurrentWeatherRow" }
    override class var height: RowHeight { return .fixed(calculatedHeight) }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(horizontal: 16) }
    
    var weather: CurrentWeather? { didSet { handleWeatherChanged() } }
    var reminderHandler: ActionClosure?
    var eventModel: EventModel? { didSet { handleEventModelChanged() } }
    
    override func initialize() {
        super.initialize()
        let gradientView = TTGradientView(gradient: .goldenrodToMandyToVividViolet)
        gradientView.cornerRadius = 16
        weatherContainerView.addSubview(gradientView, pinningEdges: .all)
        weatherContainerView.sendSubviewToBack(gradientView)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        stateImageView.tintColor = .white
        let gradientViewV2 = TTGradientView(gradient: .heliotropeToCerulean)
        countDownContainerView.addSubview(gradientViewV2, pinningEdges: .all)
        countDownContainerView.sendSubviewToBack(gradientViewV2)
        gradientViewV2.cornerRadius = 16
        let tap = UITapGestureRecognizer { [unowned self] in self.reminderHandler?() }
        countDownContainerView.addGestureRecognizer(tap)
        weatherContainerView.cornerRadius = 16
        weatherContainerView.addShadow(radius: 16, yOffset: -1)
        countDownContainerView.cornerRadius = 16
        countDownContainerView.addShadow(radius: 16, yOffset: -1)
    }
    
    private func handleWeatherChanged() {
        guard let now = weather?.now else { return }
        weatherStateLabel.text = now.text
        temperatureLabel.text = now.temp + "°C"
        windLabel.text = now.windDir + " " + now.windScale + "级"
        stateImageView.image = UIImage(named: now.icon)?.withRenderingMode(.alwaysTemplate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.startAnimation()
        }
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
    
    private func startAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0, options: [ .beginFromCurrentState, .autoreverse, .repeat ], animations: {
            self.stateImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: nil)
    }
    
    // MARK: Components
    var city: String? {
        get { return locationLabel.text }
        set { locationLabel.text = newValue }
    }
}
