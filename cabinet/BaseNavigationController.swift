// Copyright © 2021 evan. All rights reserved.

import UIKit

class BaseNavigationController: UINavigationController {
    var navBarStyle: NavigationBarStyle = .white { didSet { handleNavBarStyleChanged() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
        delegate = self

        let navBar = navigationBar
        if #available(iOS 13.0, *) {
            // Do nothing, set up is done in handleNavBarStyleChanged()
        } else {
            navBar.insertSubview(backgroundView, at: 2)
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.layer.zPosition = -1
            let navBarHeight: CGFloat = UIDevice.navigationHeight
            NSLayoutConstraint.activate([
                backgroundView.heightAnchor.constraint(equalToConstant: navBarHeight),
                backgroundView.leftAnchor.constraint(equalTo: navBar.leftAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: navBar.bottomAnchor),
                backgroundView.rightAnchor.constraint(equalTo: navBar.rightAnchor),
            ])
        }
        navBar.setBackgroundImage(UIImage(), for: .default)
        // Shadow
        navBar.addSubview(shadowView, pinningEdges: [ .left, .bottom, .right ])
        navBar.shadowImage = UIImage()
    }
    
    override func viewDidLayoutSubviews() {
        if #available(iOS 13.0, *) {
            // Do nothing
        } else {
            navigationBar.sendSubviewToBack(backgroundView) // Required for iOS 12
        }
    }

    // MARK: Updating
    private func handleNavBarStyleChanged() {
        let navBar = navigationBar
        let titleTextAttributes: [NSAttributedString.Key:Any] = [
            .foregroundColor : navBarStyle.titleColor,
            .font : navBarStyle.font,
        ]
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            var alphaComponent: CGFloat = 0
            if navBarStyle.backgroundColor.getRed(nil, green: nil, blue: nil, alpha: &alphaComponent) {
                // Getting RGB components from a color requires the color to be defined in an "RGB-compatible" colorspace (such as RGB, HSB or GrayScale).
                if alphaComponent < 1.0 {
                    navigationBar.isTranslucent = true
                    navBarAppearance.configureWithTransparentBackground()
                } else {
                    navigationBar.isTranslucent = false
                    navBarAppearance.configureWithOpaqueBackground()
                }
            } else {
                // This doesn't happen if the color was created from a CIColor, for example.
                navBarAppearance.configureWithOpaqueBackground()
            }
            navBarAppearance.shadowColor = nil // Do not set the shadowColor, it makes our shadow not follow our design and doesn't update in runtime.
            navBarAppearance.shadowImage = UIImage()
            let buttonTextAttributes: [NSAttributedString.Key:Any] = [
                // Do not set the .foregroundColor : navBarStyle.buttonColor here as it causes glitches on iOS 13
                // The navBar.tintColor takes care of this (set below)
                .font : navBarStyle.font,
            ]
            let buttonAppearance = UIBarButtonItemAppearance(style: .done)
            buttonAppearance.normal.titleTextAttributes = buttonTextAttributes
            buttonAppearance.disabled.titleTextAttributes = buttonTextAttributes
            buttonAppearance.highlighted.titleTextAttributes = buttonTextAttributes
            buttonAppearance.focused.titleTextAttributes = buttonTextAttributes
            navBarAppearance.doneButtonAppearance = buttonAppearance
            navBarAppearance.largeTitleTextAttributes = titleTextAttributes
            navBarAppearance.titleTextAttributes = titleTextAttributes
            navBarAppearance.backgroundColor = navBarStyle.backgroundColor
            navBar.standardAppearance = navBarAppearance
        } else {
            // Background
            let backgroundColor = navBarStyle.backgroundColor
            var alphaComponent: CGFloat = 0
            if navBarStyle.backgroundColor.getRed(nil, green: nil, blue: nil, alpha: &alphaComponent) {
                navigationBar.isTranslucent = alphaComponent < 1.0
            }
            animateAlongsideTransitionIfNeeded { [backgroundView] in
                backgroundView.backgroundColor = backgroundColor
            }
        }
        // Shadow
        let shadowColor: UIColor = {
            return navBarStyle.hasShadow ? UIColor(white: 0, alpha: 0.125) : .clear
        }()
        animateAlongsideTransitionIfNeeded { [shadowView] in
            shadowView.backgroundColor = shadowColor
        }
        // Title
        navBar.titleTextAttributes = titleTextAttributes
        // Buttons
        let buttonColor = navBarStyle.buttonColor
        animateAlongsideTransitionIfNeeded {
            navBar.tintColor = buttonColor
        }
    }

    // MARK: Convenience
    private func animateAlongsideTransitionIfNeeded(_ animation: @escaping () -> Void) {
        let navBar = navigationBar
        if let transitionCoordinator = transitionCoordinator, presentingViewController == nil {
            let didQueue = transitionCoordinator.animateAlongsideTransition(in: navBar, animation: { _ in animation() }, completion: nil)
            if !didQueue { // This happens when doing an interactive pop, but you don't go through with it
                animation()
            }
        } else {
            animation()
        }
    }
    
    // MARK: Components
    private lazy var backgroundView = UIView()

    private lazy var shadowView: UIView = {
        let result = UIView()
        result.constrainHeight(to: 1.0 / UIScreen.main.scale)
        return result
    }()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? .all
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }

    override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? false
    }
    
}

extension BaseNavigationController : UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer && viewControllers.count < 2 {
            return false
        }
        return true
    }
}
