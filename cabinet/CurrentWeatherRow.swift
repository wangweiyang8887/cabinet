// Copyright © 2021 evan. All rights reserved.

import Foundation

final class CurrentWeatherRow : BaseRow {
    private static let calculatedHeight: CGFloat = (UIScreen.main.bounds.width - 32 - 16) / 2
    
    override class var height: RowHeight { return .fixed(calculatedHeight) }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(horizontal: 16) }
    
    var weather: CurrentWeather? { didSet { currentWeatherView.currentWeather = weather } }
    var reminderHandler: ActionClosure?
    var eventModel: EventModel? { didSet { currentEventView.eventModel = eventModel } }
    
    override func initialize() {
        super.initialize()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        let stackView = UIStackView(axis: .horizontal, distribution: .fillEqually, alignment: .fill, spacing: 16, arrangedSubviews: [ currentWeatherView, currentEventView ])
        contentView.addSubview(stackView, pinningEdges: .all)
        currentEventView.addTapGestureHandler { [unowned self] in self.reminderHandler?() }
        let longPressWeather = UILongPressGestureRecognizer()
        longPressWeather.addTarget(self, action: #selector(longPressWeather(_:)))
        currentWeatherView.addGestureRecognizer(longPressWeather)
        let longPressEvent = UILongPressGestureRecognizer()
        longPressEvent.addTarget(self, action: #selector(longPressEvent(_:)))
        currentEventView.addGestureRecognizer(longPressEvent)
    }
    
    @objc private func longPressWeather(_ longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began:
            WeatherColorPickerVC.show(with: UIViewController.current(), currentWeather: self.weather) { [unowned self] in
                self.currentWeatherView.getUserDefaultIfNeeded()
            }
        default: break
        }
    }
    
    @objc private func longPressEvent(_ longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began: EventColorPickerVC.show(with: UIViewController.current(), event: self.eventModel)
        default: break
        }
    }
        
    private lazy var currentWeatherView = CurrentWeatherView.loadFromNib()
    private lazy var currentEventView = CurrentEventView.loadFromNib()
    
    // MARK: Components
    var city: String? {
        get { return currentWeatherView.address }
        set { currentWeatherView.address = newValue }
    }
}
