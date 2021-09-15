// Copyright © 2021 evan. All rights reserved.

import UIKit

class CurrentDateVC : BaseViewController {
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var closeButton: UIButton!
    
    override class var isLandscape: Bool { return true }
    private var isTouching: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        timeLabel.textColor = .white
        dateLabel.textColor = .white
        timeLabel.defaultTextShadow()
        dateLabel.defaultTextShadow()
        closeButton.addTapHandler { [unowned self] in self.dismiss(animated: true, completion: nil) }
        getCurrentDateFormatter()
        TimerManager.shared.fire { [weak self] in self?.getCurrentDateFormatter() }
        perform(#selector(hide), with: self, afterDelay: 3, inModes: [ .common ])
    }
    
    @objc func hide() {
        guard !isTouching else { return }
        UIView.animate(withDuration: TTDuration.default) {
            self.dateLabel.alpha = 0
            self.closeButton.alpha = 0
        }
    }
    
    private func getCurrentDateFormatter() {
        let date = Date()
        timeLabel.text = date.cabinetTimeDateFormatted()
        dateLabel.text = date.cabinetWeedayFomatted() + date.cabinetShortTimelessDateFormatted()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: TTDuration.default) {
            self.dateLabel.alpha = 1
            self.closeButton.alpha = 1
        }
        isTouching = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isTouching = false
        perform(#selector(hide), with: self, afterDelay: 3, inModes: [ .common ])
    }
}
