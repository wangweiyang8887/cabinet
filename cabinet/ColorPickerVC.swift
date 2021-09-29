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
        class Row : BaseRow { override class var height: RowHeight { .fixed((UIScreen.main.bounds.width - 32 - 16) / 2) } }
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
        let vc = WeatherColorPickerVC.self.init(style: .action(cancelRowStyle: .default, title: ""))
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
    
    static func show(with viewController: UIViewController, event: EventModel?) {
        let vc = EventColorPickerVC.self.init(style: .action(cancelRowStyle: .default, title: ""))
        vc.actionHandler = { print("aaaaaaa") }
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
