// Copyright © 2021 evan. All rights reserved.

extension UIButton {
    public var title: String? {
        get { return title(for: .normal) }
        set { setTitle(newValue, for: .normal) }
    }
}
