// Copyright © 2021 evan. All rights reserved.

final class CurrentWeatherView : UIView {
    @IBOutlet private var locationImageView: UIImageView!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var stateLabel: UILabel!
    @IBOutlet private var stateImageView: UIImageView!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var windLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(gradientView, pinningEdges: .all)
        sendSubviewToBack(gradientView)
        cornerRadius = 16
        gradientView.cornerRadius = 16
    }
    
    private lazy var gradientView: TTGradientView = {
        let result = TTGradientView(gradient: [ .black ])
        return result
    }()
    
    // MARK: Accessors
    var gradient: TTGradient {
        get { return gradientView.gradient }
        set { gradientView.gradient = newValue }
    }
}
