// Copyright © 2022 evan. All rights reserved.

class GameOneVC : BaseCollectionViewController, SheetPresentable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "真心话大冒险"
    }
}

class GameModel {
    var title: String = ""
    var items: [String] = []
    var style: Style = .one { didSet { reset() } }
    
    enum Style { case one, two, three }
    
    private func reset() {
        switch style {
        case .one:
            title = "11111"
            items = [ "真心话", "大冒险", "Pass" ]
        default: break
        }
    }
}
