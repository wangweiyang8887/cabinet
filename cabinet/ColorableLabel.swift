// Copyright © 2021 evan. All rights reserved.

final class ColorableLabel : UILabel {
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        guard tintColor != .clear else { return }
        textColor = tintColor
    }
}
