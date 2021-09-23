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
        redBallLabel.text = model.lottery_res.components(separatedBy: ",").prefix(6).joined(separator: " ")
        blueBallLabel.text = model.lottery_res.components(separatedBy: ",").last
    }
    
    private func handleDLTModelChanged() {
        guard let model = dltModel else { return }
        dltNumberLabel.text = model.lottery_no
        dltDateLabel.text = model.lottery_date
        dltRedBallLabel.text = model.lottery_res.components(separatedBy: ",").prefix(5).joined(separator: " ")
        dltBlueBallOneLabel.text = model.lottery_res.components(separatedBy: ",").suffix(from: 5).first
        dltBlueBallTwoLabel.text = model.lottery_res.components(separatedBy: ",").suffix(from: 5).last
    }
}

final class LotteryRow : BaseRow {
    override class var height: RowHeight { return .fixed(168) }
    override class var margins: UIEdgeInsets { return UIEdgeInsets(uniform: 16) }
    
    var ssqModel: LotteryModel? { didSet { lotteryView.ssqModel = ssqModel } }
    var dltModel: LotteryModel? { didSet { lotteryView.dltModel = dltModel } }
    
    override func initialize() {
        super.initialize()
        backgroundColor = .clear
        let gradientView = TTGradientView(gradient: [ UIColor.red.withAlphaComponent(0.4), UIColor.blue.withAlphaComponent(0.4) ])
        gradientView.cornerRadius = 16
        contentView.addSubview(gradientView, pinningEdges: .all)
        contentView.sendSubviewToBack(gradientView)
        contentView.cornerRadius = 16
        contentView.addShadow(radius: 16, yOffset: -1)
        contentView.addSubview(lotteryView, pinningEdges: .all, withInsets: UIEdgeInsets(uniform: 16))
    }
    
    private lazy var lotteryView: LotteryView = LotteryView.loadFromNib()
}
