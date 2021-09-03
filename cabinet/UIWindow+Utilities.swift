// Copyright © 2021 evan. All rights reserved.

extension UIWindow {
    @objc public var visibleViewController: UIViewController? {
        return UIWindow.getVisibleViewController(from: rootViewController)
    }
    
    @objc public static func getVisibleViewController(from viewController: UIViewController?) -> UIViewController? {
        if let vc = viewController as? UINavigationController {
            return UIWindow.getVisibleViewController(from: vc.visibleViewController)
        } else if let vc = viewController as? UITabBarController {
            return UIWindow.getVisibleViewController(from: vc.selectedViewController)
        } else {
            guard let vc = viewController?.presentedViewController else { return viewController }
            return UIWindow.getVisibleViewController(from: vc)
        }
    }
}
