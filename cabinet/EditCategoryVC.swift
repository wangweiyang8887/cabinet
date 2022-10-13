// Copyright © 2022 evan. All rights reserved.

import Foundation

class EditCategoryVC : BaseCollectionViewController, SheetPresentable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "edit"
        collectionView.sections += BaseSection([ textRow ])
    }
    
    private lazy var textRow: TextRow = {
        let result = TextRow()
        result.text = "真心话 & 大冒险"
        result.constrainHeight(to: 80)
        result.backgroundColor = .orange
        result.selectionHandler = {
            let nav = BaseNavigationController(rootViewController: GameOneVC())
            UIViewController.current().present(nav, animated: true, completion: nil)
        }
        return result
    }()
}
