// Copyright © 2021 evan. All rights reserved.

import UIKit

class HomePageVC : BaseCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.sections += BaseSection([ dateRow ])
    }
    
    private lazy var dateRow = CurrentDateRow()
}
