// Copyright © 2021 evan. All rights reserved.

extension UINavigationController {
    public func popViewController(animated: Bool, completion: ActionClosure?) {
        popViewController(animated: animated)
        executeAfterTransition(function: completion, animated: animated)
    }

    public func popToViewController(_ viewController: UIViewController, animated: Bool, completion: ActionClosure?) {
        popToViewController(viewController, animated: animated)
        executeAfterTransition(function: completion, animated: animated)
    }

    public func pushViewController(_ viewController: UIViewController, animated: Bool, completion: ActionClosure?) {
        pushViewController(viewController, animated: animated)
        executeAfterTransition(function: completion, animated: animated)
    }

    // MARK: Transition Coordinator
    public func executeAfterTransition(function: ActionClosure?, animated: Bool) {
        guard let function = function else { return }
        if let transitionCoordinator = transitionCoordinator, animated {
            transitionCoordinator.animate(alongsideTransition: nil) { _ in
                function()
            }
        } else {
            function()
        }
    }
}
