// Copyright © 2021 evan. All rights reserved.

final class ColorableLabel : UILabel {
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        textColor = tintColor
    }
}
