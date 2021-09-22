// Copyright © 2021 evan. All rights reserved.

import UIKit

class SettingTableViewCell : UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var toggleSwitch: UISwitch!
    
    var model: Setting? { didSet { updateContent() } }
    var tonggleHandler: ValueChangedHandler<Bool>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        toggleSwitch.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
    }
    
    @objc private func valueChanged(_ view: UISwitch) {
        tonggleHandler?(view.isOn)
    }
    
    private func updateContent() {
        guard let model = model else { return }
        titleLabel.text = model.title
        toggleSwitch.isOn = model.isEnabled
    }
}
