// Copyright © 2021 evan. All rights reserved.

import UIKit

extension UIView {
    // MARK: Size
    @discardableResult @objc public func constrainWidth(to constant: CGFloat, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let constraint = widthAnchor.constraint(equalToConstant: constant).with(priority: priority)
        NSLayoutConstraint.activate([ constraint ])
        return constraint
    }

    @discardableResult @objc public func constrainHeight(to constant: CGFloat, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        let constraint = heightAnchor.constraint(equalToConstant: constant).with(priority: priority)
        NSLayoutConstraint.activate([ constraint ])
        return constraint
    }

    @discardableResult public func constrainSize(to size: CGSize, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        let constraints: [NSLayoutConstraint] = [
            widthAnchor.constraint(equalToConstant: size.width).with(priority: priority),
            heightAnchor.constraint(equalToConstant: size.height).with(priority: priority),
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    // MARK: Legacy
    @discardableResult @objc public func objc_constrainHeight(to constant: CGFloat, priority: Float = 1000) -> NSLayoutConstraint {
        return constrainHeight(to: constant, priority: UILayoutPriority(rawValue: priority))
    }

    /// DEPRECATED: Use `pinEdges(to:with:)` instead.
    @objc public func pinToHorizontalEdges(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        pinView(view.leftAnchor, to: leftAnchor)
        pinView(view.rightAnchor, to: rightAnchor)
    }

    /// DEPRECATED: Use `pinEdges(to:with:)` instead.
    @discardableResult @objc public func pinToBottom(_ view: UIView, constant: CGFloat = 0, useSafeAnchor: Bool = true) -> NSLayoutConstraint {
        view.translatesAutoresizingMaskIntoConstraints = false
        return pinView(useSafeAnchor ? safeBottomAnchor : bottomAnchor, to: view.bottomAnchor, constant: constant)
    }

    /// DEPRECATED: Use `pinEdges(to:with:)` instead.
    @discardableResult @objc public func pinToTop(_ view: UIView, constant: CGFloat = 0, useSafeAnchor: Bool = true) -> NSLayoutConstraint {
        view.translatesAutoresizingMaskIntoConstraints = false
        return pinView(useSafeAnchor ? safeTopAnchor : topAnchor, to: view.topAnchor, constant: constant)
    }

    /// DEPRECATED: Use `pinEdges(to:with:)` instead.
    @discardableResult private func pinView<T>(_ anchor: NSLayoutAnchor<T>, to anotherAnchor: NSLayoutAnchor<T>, constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = anchor.constraint(equalTo: anotherAnchor, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult @objc public func pinToCenterX(_ view: UIView, constant: CGFloat = 0, useSafeAnchor: Bool = true) -> NSLayoutConstraint {
        view.translatesAutoresizingMaskIntoConstraints = false
        return pinView(centerXAnchor, to: view.centerXAnchor, constant: constant)
    }
    
    @discardableResult @objc public func pinToCenterY(_ view: UIView, constant: CGFloat = 0, useSafeAnchor: Bool = true) -> NSLayoutConstraint {
        view.translatesAutoresizingMaskIntoConstraints = false
        return pinView(centerYAnchor, to: view.centerYAnchor, constant: constant)
    }
}

