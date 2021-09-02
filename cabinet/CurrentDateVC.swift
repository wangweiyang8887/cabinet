// Copyright © 2021 evan. All rights reserved.

import UIKit

class CurrentDateVC : BaseViewController {
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var closeButton: UIButton!
    
    override class var isLandscape: Bool { return true }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cabinetWhite
        timeLabel.textColor = .cabinetBlack
        dateLabel.textColor = .cabinetBlack
        closeButton.addTapHandler { [unowned self] in self.dismiss(animated: true, completion: nil) }
        getCurrentDateFormatter()
        TimerManager.shared.fire { [weak self] in self?.getCurrentDateFormatter() }
    }
    
    private func getCurrentDateFormatter() {
        let date = Date()
        timeLabel.text = date.cabinetTimeDateFormatted()
        dateLabel.text = date.cabinetWeedayFomatted() + date.cabinetShortTimelessDateFormatted()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}
