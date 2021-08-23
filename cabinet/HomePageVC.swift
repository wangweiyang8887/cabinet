// Copyright © 2021 evan. All rights reserved.

import UIKit

class HomePageVC : BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let vc = CurrentDateVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}
