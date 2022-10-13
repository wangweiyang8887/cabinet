// Copyright © 2021 evan. All rights reserved.

public extension UIBarButtonItem {
    // MARK: Initializers
    @objc convenience init(image: UIImage?, tintColor: UIColor? = .blue, action: @escaping ActionClosure) {
        self.init(customView: UIBarButtonItem.button(with: image, tintColor: tintColor, actionBlock: action, target: nil, actionSelector: nil))
    }
    
    // MARK: Convenience
    private static func button(with image: UIImage?, tintColor: UIColor?, actionBlock: ActionClosure?, target: AnyObject?, actionSelector: Selector?) -> TTButton {
        let button = TTButton(frame: CGRect(x: 0, y: 0, width: 32.0, height: 32.0)) // This is the necessary button frame to make the icon fit in the nav bar with the desired spacing between them, according to the design.
        button.setImage(image, for: .normal)
        button.contentMode = .center
        button.tintColor = tintColor
        if let actionBlock = actionBlock {
            button.addTapHandler(actionBlock)
        }
        if let selector = actionSelector, target?.responds(to: selector) ?? false {
            button.addTarget(target, action: selector, for: .touchUpInside)
        }
        return button
    }
    
    // MARK: Helpers
    static func textButtonItem(with text: String, action: @escaping ActionClosure) -> UIBarButtonItem {
        let button = TTButton(type: .custom, title: text, titleColor: .cabinetDarkestGray, block: action)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return UIBarButtonItem(customView: button)
    }
    static func cancelButtonItem(action: @escaping ActionClosure) -> UIBarButtonItem {
        let button = TTButton(type: .custom, title: "取消", titleColor: .cabinetDarkestGray, block: action)
        button.tintColor = .cabinetDarkestGray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return UIBarButtonItem(customView: button)
    }
    
    static func settingButtonItem(_ completion: ActionClosure?) -> UIBarButtonItem {
        let button = TTButton(type: .custom, icon: #imageLiteral(resourceName: "64-setting").tinted(with: .cabinetBlack).withRenderingMode(.alwaysTemplate)) { UIViewController.current().showSetting(completion) }
        button.constrainSize(to: CGSize(uniform: 30))
        button.contentHorizontalAlignment = .right
        return UIBarButtonItem(customView: button)
    }
    
    static func supportButtonItem() -> UIBarButtonItem {
        let button = TTButton(type: .custom, icon: #imageLiteral(resourceName: "handshake").tinted(with: .cabinetBlack).withRenderingMode(.alwaysTemplate)) { UIViewController.current().showSupporting() }
        button.constrainSize(to: CGSize(uniform: 30))
        button.contentHorizontalAlignment = .right
        return UIBarButtonItem(customView: button)
    }
}
