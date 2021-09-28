// Copyright © 2021 evan. All rights reserved.

final class PreviewColorRow : BaseRow {
    @IBOutlet private var topLeftContainerView: UIView!
    @IBOutlet private var topLeftColorView: UIView!
    @IBOutlet private var topLeftLabel: UILabel!
    
    @IBOutlet private var bottomRightContainerView: UIView!
    @IBOutlet private var bottomRightColorView: UIView!
    @IBOutlet private var bottomRightLabel: UILabel!
    
    override class var nibName: String? { return "PreviewColorRow" }
    override class var height: RowHeight { return .fixed(200) }
    
    var topLeftColor: UIColor = .white { didSet { topLeftColorView.backgroundColor = topLeftColor } }
    var bottomRightColor: UIColor = .white { didSet { bottomRightColorView.backgroundColor = bottomRightColor } }
    var topLeftValue: String = "#000000" { didSet { topLeftLabel.text = topLeftValue } }
    var bottomRightValue: String = "#000000" { didSet { bottomRightLabel.text = bottomRightValue } }
    var tapHandler: ActionClosure?
    
    override func initialize() {
        super.initialize()
        topLeftContainerView.cornerRadius = 8
        bottomRightContainerView.cornerRadius = 8
        topLeftContainerView.addMissingRequiredFieldStyle()
        topLeftContainerView.addTapGestureHandler { [unowned self] in
            self.topLeftContainerView.addMissingRequiredFieldStyle()
            self.bottomRightContainerView.removeMissingRequiredFieldStyle()
            self.tapHandler?()
        }
        bottomRightContainerView.addTapGestureHandler { [unowned self] in
            self.bottomRightContainerView.addMissingRequiredFieldStyle()
            self.topLeftContainerView.removeMissingRequiredFieldStyle()
            self.tapHandler?()
        }
    }
}
