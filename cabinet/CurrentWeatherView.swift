// Copyright © 2021 evan. All rights reserved.

final class CurrentWeatherView : UIView, Palletable {
    @IBOutlet private var locationImageView: UIImageView!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var stateLabel: UILabel!
    @IBOutlet private var stateImageView: UIImageView!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var windLabel: UILabel!
    
    var currentWeather: CurrentWeather? {
        didSet {
            updateContent()
        }
    }
    
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
    
    private func updateContent() {
        guard let now = currentWeather?.now else { return }
        stateLabel.text = now.text
        temperatureLabel.text = now.temp + "°C"
        windLabel.text = now.windDir + " " + now.windScale + "级"
        stateImageView.image = UIImage(named: now.icon)?.withRenderingMode(.alwaysTemplate)
    }
    
    private func startAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0, options: [ .beginFromCurrentState, .autoreverse, .repeat ], animations: {
            self.stateImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: nil)
    }

    
    private lazy var gradientView: TTGradientView = {
        let result = TTGradientView(gradient: .goldenrodToMandyToVividViolet)
        return result
    }()
    
    private lazy var imageView: UIImageView = {
        let result = UIImageView()
        result.contentMode = .scaleAspectFill
        result.backgroundColor = .clear
        return result
    }()
    
    // MARK: Accessors
    var address: String? {
        get { return addressLabel.text }
        set { addressLabel.text = newValue }
    }
    
    var gradient: TTGradient {
        get { return gradientView.gradient }
        set { gradientView.gradient = newValue; imageView.image = nil }
    }

    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
}
