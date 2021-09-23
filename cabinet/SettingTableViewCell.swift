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
        selectionStyle = .none
        toggleSwitch.onTintColor = .nonStandardColor(withRGBHex: 0x1770f3)
        toggleSwitch.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        contentView.addSubview(lineView, pinningEdges: [ .left, .right, .bottom ], withInsets: UIEdgeInsets(horizontal: 16))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        lineView.backgroundColor = previousTraitCollection?.userInterfaceStyle == .light ? .cabinetDarkestGray : .nonStandardColor(withRGBHex: 0xEBEBEB)
    }
    
    @objc private func valueChanged(_ view: UISwitch) {
        tonggleHandler?(view.isOn)
    }
    
    private func updateContent() {
        guard let model = model else { return }
        titleLabel.text = model.title
        toggleSwitch.isOn = model.isEnabled
    }
    
    private lazy var lineView: UIView = {
        let result = UIView()
        result.constrainHeight(to: 0.5)
        if #available(iOS 13.0, *) {
            result.backgroundColor = UITraitCollection.current.userInterfaceStyle == .dark ?.cabinetDarkestGray : .nonStandardColor(withRGBHex: 0xEBEBEB)
        } else {
            result.backgroundColor = .nonStandardColor(withRGBHex: 0xEBEBEB)
        }
        return result
    }()
}
