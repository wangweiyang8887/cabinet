// Copyright © 2021 evan. All rights reserved.

import UIKit

class PushTransitionDelegate : NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let presentAnimator = PushAnimator()
        presentAnimator.isPresenting = true
        return presentAnimator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let dismissAnimator = PushAnimator()
        dismissAnimator.isPresenting = false
        return dismissAnimator
    }
}

class PushAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    var isPresenting = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        if isPresenting {
            guard
                let toVC = transitionContext.viewController(forKey: .to),
                let toView = transitionContext.view(forKey: .to)
                else { return }
            // set up some variables for the animation
            let containerFrame = containerView.frame
            var toViewStartFrame = transitionContext.initialFrame(for: toVC)
            _ = transitionContext.finalFrame(for: toVC)

            // set up the animation parameters
            toViewStartFrame.origin.x = containerFrame.size.width
            toViewStartFrame.size = containerFrame.size
            
            containerView.addSubview(toView)
            toView.frame = toViewStartFrame
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                toView.frame.origin.x = 0
            }) { _ in
                let success = !transitionContext.transitionWasCancelled
                if (self.isPresenting && !success) || (!self.isPresenting && !success) {
                    toView.removeFromSuperview()
                }
                transitionContext.completeTransition(success)
            }
        } else {
            guard
                let fromVC = transitionContext.viewController(forKey: .from),
                let toVC = transitionContext.viewController(forKey: .to),
                let fromView = transitionContext.view(forKey: .from),
                let toView = transitionContext.view(forKey: .to)
                else { return }

            // set up some variables for the animation
            let containerFrame = containerView.frame
            let toViewStartFrame = transitionContext.initialFrame(for: toVC)
            _ = transitionContext.finalFrame(for: toVC)
            var fromViewFinalFrame = transitionContext.finalFrame(for: fromVC)

            fromViewFinalFrame = CGRect(x: containerFrame.size.width, y: 0, width: toView.frame.size.width, height: toView.frame.size.height)
            containerView.insertSubview(toView, belowSubview: fromView)
            toView.frame = toViewStartFrame
            toView.frame = containerFrame
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                fromView.frame = fromViewFinalFrame
            }) { _ in
                let success = !transitionContext.transitionWasCancelled
                if (self.isPresenting && !success) || (!self.isPresenting && !success) {
                    toView.removeFromSuperview()
                }
                transitionContext.completeTransition(success)
            }
        }
    }
}

