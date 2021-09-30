// Copyright © 2021 evan. All rights reserved.

final class LotteryView : UIView {
    @IBOutlet weak var ssqNumberLabel: UILabel!
    @IBOutlet weak var ssqDateLabel: UILabel!
    @IBOutlet weak var redBallLabel: UILabel!
    @IBOutlet weak var blueBallLabel: UILabel!
    @IBOutlet weak var dltNumberLabel: UILabel!
    @IBOutlet weak var dltDateLabel: UILabel!
    @IBOutlet weak var dltRedBallLabel: UILabel!
    @IBOutlet weak var dltBlueBallOneLabel: UILabel!
    @IBOutlet weak var dltBlueBallTwoLabel: UILabel!
    
    var ssqModel: LotteryModel? { didSet { handleSSQModelChanged() } }
    var dltModel: LotteryModel? { didSet { handleDLTModelChanged() } }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        [ redBallLabel, blueBallLabel, dltRedBallLabel, dltBlueBallOneLabel, dltBlueBallTwoLabel ].forEach { $0?.defaultTextShadow() }
    }
    
    private func handleSSQModelChanged() {
        guard let model = ssqModel else { return }
        ssqNumberLabel.text = model.lottery_no
        ssqDateLabel.text = model.lottery_date
        redBallLabel.text = model.ssqRedBall
        blueBallLabel.text = model.ssqBlueBall
    }
    
    private func handleDLTModelChanged() {
        guard let model = dltModel else { return }
        dltNumberLabel.text = model.lottery_no
        dltDateLabel.text = model.lottery_date
        dltRedBallLabel.text = model.dltRedBall
        dltBlueBallOneLabel.text = model.dltBlueBallOne
        dltBlueBallTwoLabel.text = model.dltBlueBallTwo
    }
}

final class LotteryRow : BaseRow, Palletable {
    
    override class var height: RowHeight { return .fixed(168) }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(uniform: 16) }
    
    var ssqModel: LotteryModel? { didSet { lotteryView.ssqModel = ssqModel } }
    var dltModel: LotteryModel? { didSet { lotteryView.dltModel = dltModel } }
    
    override func initialize() {
        super.initialize()
        backgroundColor = .clear
        addSubview(imageView, pinningEdges: .all)
        sendSubviewToBack(imageView)
        addSubview(gradientView, pinningEdges: .all)
        sendSubviewToBack(gradientView)
        imageView.cornerRadius = 16
        gradientView.cornerRadius = 16
        contentView.cornerRadius = 16
        contentView.addShadow(radius: 16, yOffset: -1)
        contentView.addSubview(lotteryView, pinningEdges: .all, withInsets: UIEdgeInsets(uniform: 16))
        getUserDefaultIfNeeded()
        let longPress = UILongPressGestureRecognizer()
        longPress.addTarget(self, action: #selector(longPress(_:)))
        lotteryView.addGestureRecognizer(longPress)
    }
        
    @objc private func longPress(_ longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .began:
            LotteryColorPickerVC.show(with: UIViewController.current(), ssqModel: ssqModel, dltModel: dltModel) { [unowned self] in
                self.getUserDefaultIfNeeded()
            }
        default: break
        }
    }
    
    func getUserDefaultIfNeeded() {
        if let data = UserDefaults.shared[.lotteryBackground] {
            if let image = UIImage(data: data) {
                self.image = image
            } else if let hex = String(data: data, encoding: .utf8) {
                gradient = TTGradient(components: hex.components(separatedBy: .whitespaces).map { UIColor(hex: $0) })
            }
        }
    }
    
    private lazy var lotteryView: LotteryView = LotteryView.loadFromNib()
    
    private lazy var gradientView: TTGradientView = {
        let result = TTGradientView(gradient: [ UIColor.red.withAlphaComponent(0.4), UIColor.blue.withAlphaComponent(0.4) ])
        return result
    }()
    
    private lazy var imageView: UIImageView = {
        let result = UIImageView()
        result.contentMode = .scaleAspectFill
        result.backgroundColor = .clear
        return result
    }()
    
    // MARK: Accessors
    var gradient: TTGradient {
        get { return gradientView.gradient }
        set { gradientView.gradient = newValue; imageView.image = nil }
    }

    var image: UIImage? {
        get { return imageView.image }
        set { imageView.image = newValue }
    }
    
    var foregroundColor: UIColor {
        get { return tintColor }
        set { tintColor = newValue }
    }
}

extension Server {
    static func fetchLottery(with id: String) -> Operation<LotteryModel> {
        return Server.fire(.get, .lottery, parameters: [ "lottery_id":id, "lottery_no":"", "key":"f7359c92478f397e465867fc24a550a2" ])
    }
}
