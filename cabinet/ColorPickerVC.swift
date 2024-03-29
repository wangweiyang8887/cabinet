// Copyright © 2021 evan. All rights reserved.

import WidgetKit

protocol Palletable {
    var gradient: TTGradient { get set }
    var image: UIImage? { get set }
    var foregroundColor: UIColor { get set }
}

class ColorPickerVC : BaseBottomSheetVC {
    class var textColorEnabled: Bool { return true }
    var pallet: Palletable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.sections += BaseSection([ containerRow, gradientTitleRow, colorItemsRow, colorTitleRow, textColorItemsRow, SpacerRow(height: 60) ])
        colorTitleRow.isHidden = !Self.textColorEnabled
        textColorItemsRow.isHidden = !Self.textColorEnabled
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
            if vc.weatherView.foregroundColor != .clear, let data = vc.weatherView.foregroundColor.hexString?.data(using: .utf8) {
                UserDefaults.shared[.weatherForeground] = data
            }
            completion?()
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
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
            if vc.eventView.foregroundColor != .clear, let data = vc.eventView.foregroundColor.hexString?.data(using: .utf8) {
                UserDefaults.shared[.eventForeground] = data
            }
            completion?()
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
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
            if vc.calendarView.foregroundColor != .clear, let data = vc.calendarView.foregroundColor.hexString?.data(using: .utf8) {
                UserDefaults.shared[.calendarForeground] = data
            }
            completion?()
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
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
            if vc.dailyRow.foregroundColor != .clear, let data = vc.dailyRow.foregroundColor.hexString?.data(using: .utf8) {
                UserDefaults.shared[.dailyForeground] = data
            }
            completion?()
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
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
            if vc.clockRow.foregroundColor != .clear, let data = vc.clockRow.foregroundColor.hexString?.data(using: .utf8) {
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

final class LotteryColorPickerVC : ColorPickerVC {
    class override var textColorEnabled: Bool { return false }

    static func show(with viewController: UIViewController, ssqModel: LotteryModel?, dltModel: LotteryModel?, completion: ActionClosure? = nil) {
        let vc = LotteryColorPickerVC(style: .action(cancelRowStyle: .default, title: ""))
        vc.actionHandler = { [weak vc ] in
            guard let vc = vc else { return }
            if let image = vc.lotteryRow.image, let data = image.jpegData(compressionQuality: 1) {
                UserDefaults.shared[.lotteryBackground] = data
            } else {
                let result = vc.lotteryRow.gradient.components.compactMap { $0.hexString }.joined(separator: " ").data(using: .utf8)
                UserDefaults.shared[.lotteryBackground] = result
            }
            completion?()
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        vc.lotteryRow.ssqModel = ssqModel
        vc.lotteryRow.dltModel = dltModel
        viewController.presentPanModal(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lotteryRow.margin = .zero
        containerRow.addSubview(lotteryRow, pinningEdges: .all, withInsets: UIEdgeInsets(uniform: 16))
        pallet = lotteryRow
    }
    
    private lazy var lotteryRow = LotteryRow()
}

final class CountingColorPickerVC : ColorPickerVC {
    class override var textColorEnabled: Bool { return false }

    static func show(with viewController: UIViewController, completion: ActionClosure? = nil) {
        let vc = CountingColorPickerVC(style: .action(cancelRowStyle: .default, title: ""))
        vc.actionHandler = { [weak vc ] in
            guard let vc = vc else { return }
            if let image = vc.countingRow.image, let data = image.jpegData(compressionQuality: 1) {
                UserDefaults.shared[.countingBackground] = data
            } else {
                let result = vc.countingRow.gradient.components.compactMap { $0.hexString }.joined(separator: " ").data(using: .utf8)
                UserDefaults.shared[.countingBackground] = result
            }
            completion?()
        }
        viewController.presentPanModal(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countingRow.margin = .zero
        containerRow.addSubview(countingRow, pinningEdges: .all, withInsets: UIEdgeInsets(uniform: 16))
        pallet = countingRow
    }
    
    private lazy var countingRow = CountingRow()
}
