// Copyright © 2021 evan. All rights reserved.

extension UIViewController {
    
    @objc func dismissSelf() {
        guard let presentingViewController = presentingViewController else { return }
        presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc func popOrDismissSelf(animated: Bool = true, completion: (() -> Void)? = nil) {
        if let navigationController = navigationController, let index = navigationController.viewControllers.firstIndex(of: self), index > 0 {
            navigationController.popToViewController(navigationController.viewControllers[index - 1], animated: animated, completion: completion)
        } else {
            presentingViewController?.dismiss(animated: animated, completion: completion)
        }
        
    }
    
    @objc
    func navigate(to viewController: UIViewController, animated: Bool) {
        let window = UIApplication.shared.delegate!.window!!
        window.navigate(to: viewController, animated: animated)
    }

    @objc
    @discardableResult
    func navigateToFirstViewController(matching predicate: @escaping (UIViewController) -> Bool, animated: Bool) -> Bool {
        let window = UIApplication.shared.delegate!.window!!
        guard let vc = window.firstViewController(matching: { predicate($0!) }) else { return false }
        navigate(to: vc, animated: animated)
        return true
    }

    @objc
    static func navigate(to targetVCType: UIViewController.Type) {
        navigateToVC(where: { $0!.isKind(of: targetVCType) })
    }

    @objc
    static func navigateToVC(where isTargetVC: @escaping ETViewControllerPredicate) {
        let window = UIApplication.shared.delegate!.window!!
        if let targetVC = window.firstViewController(matching: isTargetVC) {
            window.navigate(to: targetVC, animated: true)
        }
    }
    
    func clearBackWay(with types: [AnyClass]) {
        types.forEach({ type in navigationController?.viewControllers.removeAll{ $0.isKind(of: type) } })
    }
}
