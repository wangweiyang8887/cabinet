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
    
    private static let calculatedHeight: CGFloat = (UIScreen.main.bounds.width - 32 - 16) / 2
    
    override class var nibName: String? { return "CurrentWeatherRow" }
    override class var height: RowHeight { return .fixed(calculatedHeight) }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(horizontal: 16) }
    
    var weather: CurrentWeather? { didSet { handleWeatherChanged() } }
    
    override func initialize() {
        super.initialize()
        let gradientView = TTGradientView(gradient: [ .nonStandardColor(withRGBHex: 0xABDCFF), .nonStandardColor(withRGBHex: 0x0396FF) ], direction: .topLeftToBottomRight)
        weatherContainerView.addSubview(gradientView, pinningEdges: .all)
        weatherContainerView.sendSubviewToBack(gradientView)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        weatherContainerView.cornerRadius = 16
        stateImageView.tintColor = .cabinetWhite
        countDownContainerView.cornerRadius = 16
        let gradientViewV2 = TTGradientView(gradient: [ .nonStandardColor(withRGBHex: 0xABDCFF), .nonStandardColor(withRGBHex: 0x0396FF) ], direction: .topRightToBottomLeft)
        countDownContainerView.addSubview(gradientViewV2, pinningEdges: .all)
        countDownContainerView.sendSubviewToBack(gradientViewV2)
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
    
    private func startAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0, options: [ .autoreverse, .repeat, .allowUserInteraction ], animations: {
            self.stateImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: nil)
    }
    
    // MARK: Components
    var city: String? {
        get { return locationLabel.text }
        set { locationLabel.text = newValue }
    }
}
