// Copyright © 2021 evan. All rights reserved.


final class ColorPickerVC : BaseBottomSheetVC {
    enum Position {
        case topLeft, bottomRight
    }
    private var red: CGFloat = 0.0 { didSet { updateColors() } }
    private var green: CGFloat = 0.0 { didSet { updateColors() } }
    private var blue: CGFloat = 0.0 { didSet { updateColors() } }
    private var topLeftPallet: Pallet?
    private var bottomRightPaller: Pallet?
    
    static func show(with viewController: UIViewController) {
        let vc = ColorPickerVC(style: .explanation(title: ""))
        viewController.presentPanModal(vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.sections += BaseSection([ weatherRow, colorItemsRow, redSliderRow, greenSliderRow, blueSliderRow ])
    }
    
    private func updateColors() {
        let currentColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        if previewRow.position == .topLeft {
            previewRow.topLeftColor = currentColor
            previewRow.topLeftValue = String(format: "#%02x%02x%02x", Int(red * 255), Int(green * 255), Int(blue * 255))
            weatherView.gradient = [ currentColor, previewRow.bottomRightColor ]
            topLeftPallet = Pallet(red: red, green: green, blue: blue)
        } else {
            previewRow.bottomRightColor = currentColor
            previewRow.bottomRightValue = String(format: "#%02x%02x%02x", Int(red * 255), Int(green * 255), Int(blue * 255))
            weatherView.gradient = [ previewRow.topLeftColor, currentColor ]
            bottomRightPaller = Pallet(red: red, green: green, blue: blue)
        }
    }
    
    private lazy var weatherView = CurrentWeatherView.loadFromNib()
    private lazy var weatherRow: BaseRow = {
        class Row : BaseRow { override class var height: RowHeight { .fixed((UIScreen.main.bounds.width - 32 - 16) / 2) } }
        let result = Row()
        weatherView.constrainSize(to: CGSize(uniform: (UIScreen.main.bounds.width - 32 - 16) / 2))
        result.addSubview(weatherView, constrainedToCenterWithOffset: .zero)
        return result
    }()
    
    private lazy var colorItemsRow: ColorItemsRow = {
        let result = ColorItemsRow()
        result.gradientHandler = { [unowned self] in self.weatherView.gradient = $0 }
        return result
    }()
    
    private lazy var previewRow: PreviewColorRow = {
        let result = PreviewColorRow()
        result.tapHandler = { [unowned self] in
            if self.previewRow.position == .topLeft, let pallet = self.topLeftPallet {
                self.redSliderRow.value = Float(pallet.red)
                self.greenSliderRow.value = Float(pallet.green)
                self.blueSliderRow.value = Float(pallet.blue)
            }
            if self.previewRow.position == .bottomRight, let pallet = self.bottomRightPaller {
                self.redSliderRow.value = Float(pallet.red)
                self.greenSliderRow.value = Float(pallet.green)
                self.blueSliderRow.value = Float(pallet.blue)
            }
        }
        return result
    }()
    
    private lazy var redSliderRow: ColorSliderRow = {
        let result = ColorSliderRow(red: 1, green: 0, blue: 0)
        result.valueChangedHandler = { [unowned self] in self.red = CGFloat($0) }
        return result
    }()
    
    private lazy var greenSliderRow: ColorSliderRow = {
        let result = ColorSliderRow(red: 0, green: 1, blue: 0)
        result.valueChangedHandler = { [unowned self] in self.green = CGFloat($0) }
        return result
    }()
    
    private lazy var blueSliderRow: ColorSliderRow = {
        let result = ColorSliderRow(red: 0, green: 0, blue: 1)
        result.valueChangedHandler = { [unowned self] in self.blue = CGFloat($0) }
        return result
    }()
}

private struct Pallet {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
}
