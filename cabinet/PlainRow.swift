// Copyright © 2021 evan. All rights reserved.

class PlainRow : BaseRow {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override class var margins: UIEdgeInsets { return UIEdgeInsets(horizontal: 16) }
    override class var height: RowHeight { return .fixed(52) }
    override class var nibName: String? { return "PlainRow" }
    
    override func initialize() {
        super.initialize()
        
    }
    
    // MARK: Accessors
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var subtitle: String? {
        get { return subtitleLabel.text }
        set { subtitleLabel.text = newValue }
    }
}
