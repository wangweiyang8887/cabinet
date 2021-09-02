// Copyright © 2021 evan. All rights reserved.

import UIKit

class BaseViewController : UIViewController {
    
    class var isLandscape: Bool { return false }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cabinet"
        view.backgroundColor = .cabinetWhite
    }
    
    deinit {
        print("\(Self.self) deinit")
    }
        
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if Self.isLandscape {
            return .landscape
        } else {
            return .portrait
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if Self.isLandscape {
            return .landscapeRight
        } else {
            return .portrait
        }
    }
    
    override var shouldAutorotate: Bool { return true }
}
