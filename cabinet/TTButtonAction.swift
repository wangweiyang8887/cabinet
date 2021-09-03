// Copyright © 2021 evan. All rights reserved.

import Foundation
import UIKit

/// A convenient holder for an action closure together with the title and/or icon it should have when set on a button.
public class TTButtonAction : NSObject { // Should be a struct in pure swift
    @objc public var title: String?
    public var color: UIColor?
    @objc public var icon: UIImage?
    @objc public var block: ActionClosure?

    @objc public init(title: String? = nil, color: UIColor? = nil, icon: UIImage? = nil, block: ActionClosure? = nil) {
        (self.title, self.color, self.icon, self.block) = (title, color, icon, block)
        super.init()
    }
}

// Don't ask me why but this @objc tag was needed to fix compiler errors
@objc extension UIButton {
    public var action: TTButtonAction? {
        get { return getAssociatedValue(for: #selector(getter: UIButton.action).key) as! TTButtonAction? }
        set { setAction(newValue, animated: false) }
    }

    public func setAction(_ action: TTButtonAction?, animated: Bool) {
        setAssociatedValue(action, forKey: #selector(getter: UIButton.action).key)
        // UI Changes
        let changes = {
            self.setTitle(action?.title, for: .normal)
            self.setTitleColor(action?.color, for: .normal)
            self.setImage(action?.icon, for: .normal)
        }
        animated ? UIView.performWithoutAnimation { changes(); layoutIfNeeded() } : changes()
        addTarget(self, action: #selector(handleZLButtonAction), for: .touchUpInside)
    }

    public convenience init(type: ButtonType = .system, title: String? = nil, titleColor: UIColor? = nil, icon: UIImage? = nil, block: ActionClosure? = nil) {
        self.init(type: type, action: TTButtonAction(title: title, color: titleColor, icon: icon, block: block))
    }

    public convenience init(type: ButtonType = .system, action: TTButtonAction) {
        self.init(type: type)
        self.action = action
    }

    public convenience init(alertAction: TTButtonAction) {
        self.init(type: .system)
        self.action = alertAction
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    }

    private func handleZLButtonAction() {
        action?.block?()
    }
}

extension TTButton {
    public convenience init(type: ButtonType = .system, title: String? = nil, titleColor: UIColor? = nil, icon: UIImage? = nil, block: ActionClosure? = nil) {
        self.init(type: type, action: TTButtonAction(title: title, color: titleColor, icon: icon, block: block))
    }

    @objc public convenience init(type: ButtonType = .system, action: TTButtonAction) {
        self.init(type: type)
        self.action = action
    }
}
