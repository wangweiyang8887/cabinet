// Copyright © 2021 evan. All rights reserved.

protocol Palletable {
    var gradient: TTGradient { get set }
    var image: UIImage? { get set }
    var foregroundColor: UIColor { get set }
}

class ColorPickerVC : BaseBottomSheetVC {
    var pallet: Palletable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.sections += BaseSection([ containerRow, colorTitleRow, colorItemsRow, gradientTitleRow, textColorItemsRow, SpacerRow(height: 60) ])
    }

    lazy var containerRow: BaseRow = {
        class Row : BaseRow { override class var height: RowHeight { .auto(estimate: (UIScreen.main.bounds.width - 32 - 16) / 2) } }
        let result = Row()
        return result
    }()
    
    private lazy var colorTitleRow: TextRow = {
        let result = TextRow()
        result.text = "文字"
        result.textColor = .cabinetBlack
        result.font = .systemFont(ofSize: 17, weight: .medium)
        result.edgeInsets = UIEdgeInsets(uniform: 24)
        return result
    }()
    
    private lazy var textColorItemsRow: ColorItemsRow = {
        let result = ColorItemsRow()
        result.colorHandler = { [unowned self] in self.pallet?.foregroundColor = $0 }
        return result
    }()
    
    private lazy var gradientTitleRow: TextRow = {
        let result = TextRow()
        result.text = "背景"
        result.textColor = .cabinetBlack
        result.font = .systemFont(ofSize: 17, weight: .medium)
        result.edgeInsets = UIEdgeInsets(uniform: 24)
        return result
    }()
    
    private lazy var colorItemsRow: ColorItemsRow = {
        let result = ColorItemsRow()
        result.kind = .gradient
        result.gradientHandler = { [unowned self] in self.pallet?.gradient = $0 }
        result.imageHandler = { [unowned self] in self.pallet?.image = $0 }
        return result
    }()
}

final class WeatherColorPickerVC : ColorPickerVC {
    private var currentWeather: CurrentWeather?
    
    static func show(with viewController: UIViewController, currentWeather: CurrentWeather?, completion: ActionClosure? = nil) {
        let vc = WeatherColorPickerVC(style: .action(cancelRowStyle: .default, title: ""))
        vc.actionHandler = { [weak vc] in
            guard let vc = vc else { return }
            if let image = vc.weatherView.image, let data = image.jpegData(compressionQuality: 1) {
                UserDefaults.shared[.weatherBackground] = data
            } else {
                let result = vc.weatherView.gradient.components.compactMap { $0.hexString }.joined(separator: " ").data(using: .utf8)
                UserDefaults.shared[.weatherBackground] = result
            }
            if let data = vc.weatherView.foregroundColor.hexString?.data(using: .utf8) {
                UserDefaults.shared[.weatherForeground] = data
            }
            completion?()
        }
        vc.currentWeather = currentWeather
        viewController.presentPanModal(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherView.constrainSize(to: CGSize(uniform: (UIScreen.main.bounds.width - 32 - 16) / 2))
        containerRow.addSubview(weatherView, constrainedToCenterWithOffset: .zero)
        pallet = weatherView
        weatherView.currentWeather = currentWeather
    }
    
    private lazy var weatherView = CurrentWeatherView.loadFromNib()
}

final class EventColorPickerVC : ColorPickerVC {
    private var event: EventModel?
    
    static func show(with viewController: UIViewController, event: EventModel?, completion: ActionClosure? = nil) {
        let vc = EventColorPickerVC(style: .action(cancelRowStyle: .default, title: ""))
        vc.actionHandler = { [weak vc ] in
            guard let vc = vc else { return }
            if let image = vc.eventView.image, let data = image.jpegData(compressionQuality: 1) {
                UserDefaults.shared[.eventBackground] = data
            } else {
                let result = vc.eventView.gradient.components.compactMap { $0.hexString }.joined(separator: " ").data(using: .utf8)
                UserDefaults.shared[.eventBackground] = result
            }
            if let data = vc.eventView.foregroundColor.hexString?.data(using: .utf8) {
                UserDefaults.shared[.eventForeground] = data
            }
            completion?()
        }
        vc.event = event
        viewController.presentPanModal(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventView.constrainSize(to: CGSize(uniform: (UIScreen.main.bounds.width - 32 - 16) / 2))
        containerRow.addSubview(eventView, constrainedToCenterWithOffset: .zero)
        pallet = eventView
        eventView.eventModel = event
    }
    
    private lazy var eventView = CurrentEventView.loadFromNib()
}

final class CalendarColorPickerVC : ColorPickerVC {
    private var calendar: ChineseCalendarModel?
    
    static func show(with viewController: UIViewController, calendar: ChineseCalendarModel?, completion: ActionClosure? = nil) {
        let vc = CalendarColorPickerVC(style: .action(cancelRowStyle: .default, title: ""))
        vc.actionHandler = { [weak vc ] in
            guard let vc = vc else { return }
            if let image = vc.calendarView.image, let data = image.jpegData(compressionQuality: 1) {
                UserDefaults.shared[.calendarBackground] = data
            } else {
                let result = vc.calendarView.gradient.components.compactMap { $0.hexString }.joined(separator: " ").data(using: .utf8)
                UserDefaults.shared[.calendarBackground] = result
            }
            if let data = vc.calendarView.foregroundColor.hexString?.data(using: .utf8) {
                UserDefaults.shared[.calendarForeground] = data
            }
            completion?()
        }
        vc.calendar = calendar
        viewController.presentPanModal(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerRow.addSubview(calendarView, pinningEdges: .all, withInsets: UIEdgeInsets(uniform: 16))
        calendarView.constrainHeight(to: 168)
        pallet = calendarView
        calendarView.chineseCalendar = calendar
    }
    
    private lazy var calendarView = CalendarView.loadFromNib()
}

final class DailyColorPickerVC : ColorPickerVC {
    static func show(with viewController: UIViewController, text: String?, completion: ActionClosure? = nil) {
        let vc = DailyColorPickerVC(style: .action(cancelRowStyle: .default, title: ""))
        vc.actionHandler = { [weak vc ] in
            guard let vc = vc else { return }
            if let image = vc.dailyRow.image, let data = image.jpegData(compressionQuality: 1) {
                UserDefaults.shared[.dailyBackground] = data
            } else {
                let result = vc.dailyRow.gradient.components.compactMap { $0.hexString }.joined(separator: " ").data(using: .utf8)
                UserDefaults.shared[.dailyBackground] = result
            }
            if let data = vc.dailyRow.foregroundColor.hexString?.data(using: .utf8) {
                UserDefaults.shared[.dailyForeground] = data
            }
            completion?()
        }
        vc.dailyRow.title = text
        viewController.presentPanModal(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dailyRow.margin = .zero
        containerRow.addSubview(dailyRow, pinningEdges: .all, withInsets: UIEdgeInsets(uniform: 16))
        pallet = dailyRow
    }
    
    private lazy var dailyRow = DailyRow()
}

final class ClockColorPickerVC : ColorPickerVC {
    static func show(with viewController: UIViewController, completion: ActionClosure? = nil) {
        let vc = ClockColorPickerVC(style: .action(cancelRowStyle: .default, title: ""))
        vc.actionHandler = { [weak vc ] in
            guard let vc = vc else { return }
            if let image = vc.clockRow.image, let data = image.jpegData(compressionQuality: 1) {
                UserDefaults.shared[.clockBackground] = data
            } else {
                let result = vc.clockRow.gradient.components.compactMap { $0.hexString }.joined(separator: " ").data(using: .utf8)
                UserDefaults.shared[.clockBackground] = result
            }
            if let data = vc.clockRow.foregroundColor.hexString?.data(using: .utf8) {
                UserDefaults.shared[.clockForeground] = data
            }
            completion?()
        }
        viewController.presentPanModal(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clockRow.margin = .zero
        containerRow.addSubview(clockRow, pinningEdges: .all, withInsets: UIEdgeInsets(uniform: 16))
        pallet = clockRow
    }
    
    private lazy var clockRow = ClockRow()
}
