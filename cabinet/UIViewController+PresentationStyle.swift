// Copyright © 2021 evan. All rights reserved.

/// A protocol that defines view controllers that can be presented using iOS 13 native modal sheet presentation style.
protocol SheetPresentable {}

extension BaseViewController {
    open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent.customizingModalPresentationStyleIfNeeded(), animated: flag, completion: completion)
    }
}

extension UINavigationController {
    open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent.customizingModalPresentationStyleIfNeeded(), animated: flag, completion: completion)
    }
}

extension UITabBarController {
    open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        super.present(viewControllerToPresent.customizingModalPresentationStyleIfNeeded(), animated: flag, completion: completion)
    }
}

private extension UIViewController {
    func customizingModalPresentationStyleIfNeeded() -> UIViewController {
        if #available(iOS 13.0, *), modalPresentationStyle == .pageSheet {
            if self is SheetPresentable || (self as? UINavigationController)?.viewControllers.first is SheetPresentable {
                // Do nothing, we allow SheetPresentable screens to be presented using iOS 13 native modal sheet presentation style.
            } else {
                // This is a temporary solution to disable the new default presentation style on iOS 13, and set it to `fullScreen` to remain the original style as iOS 12.
                modalPresentationStyle = .fullScreen
            }
        }
        return self
    }
}
