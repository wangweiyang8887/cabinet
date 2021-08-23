// Copyright © 2021 evan. All rights reserved.

import UIKit

class CurrentDateVC : BaseViewController {
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cabinetWhite
        timeLabel.textColor = .cabinetBlack
        dateLabel.textColor = .cabinetBlack
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        closeButton.addTapHandler { [unowned self] in self.navigationController?.popViewController(animated: true) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        navigationController?.navigationBar.isHidden = false
    }
    
    override var shouldAutorotate: Bool { return false }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
}
