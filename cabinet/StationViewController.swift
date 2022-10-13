// Copyright © 2022 evan. All rights reserved.

import Foundation

class StationViewController : BaseCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "station"
        collectionView.sections += BaseSection([ decisionRow, chooseRow ])
    }
    
    private lazy var decisionRow: TextRow = {
        let result = TextRow()
        result.constrainHeight(to: 50)
        result.backgroundColor = .red
        result.selectionHandler = {
            let nav = BaseNavigationController(rootViewController: RandomNumberVC())
            UIViewController.current().present(nav, animated: true, completion: nil)
        }
        result.text = "7"
        return result
    }()
    
    private lazy var chooseRow: TextRow = {
        let result = TextRow()
        result.constrainHeight(to: 50)
        result.backgroundColor = .orange
        result.selectionHandler = {
            let nav = BaseNavigationController(rootViewController: RandomChooseVC())
            UIViewController.current().present(nav, animated: true, completion: nil)
        }
        result.text = "8"
        return result
    }()
}
