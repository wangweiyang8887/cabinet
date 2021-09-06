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
    
    private static let calculatedHeight: CGFloat = (UIScreen.main.bounds.width - 32 - 16) / 2
    
    override class var nibName: String? { return "CurrentWeatherRow" }
    override class var height: RowHeight { return .fixed(calculatedHeight) }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(horizontal: 16) }
    
    var weather: CurrentWeather? { didSet { handleWeatherChanged() } }
    
    override func initialize() {
        super.initialize()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        weatherContainerView.backgroundColor = .orange
        weatherContainerView.cornerRadius = 16
    }
    
    private func handleWeatherChanged() {
        guard let weather = weather else { return }
        weatherStateLabel.text = weather.list.first?.weather
        temperatureLabel.text = weather.list.first?.temp
        windLabel.text = weather.list.first?.wind
    }
    
    // MARK: Components
    var city: String? {
        get { return locationLabel.text }
        set { locationLabel.text = newValue }
    }
}
