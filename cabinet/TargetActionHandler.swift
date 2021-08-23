// Copyright © 2021 evan. All rights reserved.

import UIKit

@objc public class TargetActionHandler : NSObject {
    private let action: () -> Void
    fileprivate var removeAction: (() -> Void)?

    fileprivate init(_ action: @escaping () -> Void) { self.action = action }

    @objc fileprivate func invoke() { action() }
    public func remove() { removeAction?() }
}

extension UIGestureRecognizer {
    @discardableResult
    @objc public func addHandler(_ handler: @escaping () -> Void) -> TargetActionHandler {
        let target = TargetActionHandler(handler)
        target.removeAction = { [weak self, unowned target] in self?.removeTarget(target, action: nil) }
        addTarget(target, action: #selector(TargetActionHandler.invoke))
        setAssociatedValue(target, forKey: unsafeBitCast(target, to: UnsafeRawPointer.self)) // Retain for lifetime of receiver
        return target
    }

    @objc public convenience init(handler: @escaping () -> Void) {
        self.init()
        addHandler(handler)
    }
}

extension UIControl {
    @discardableResult
    @objc public func addHandler(for events: UIControl.Event, handler: @escaping () -> Void) -> TargetActionHandler {
        let target = TargetActionHandler(handler)
        target.removeAction = { [weak self, unowned target] in self?.removeTarget(target, action: nil, for: .allEvents) }
        addTarget(target, action: #selector(TargetActionHandler.invoke), for: events)
        setAssociatedValue(target, forKey: unsafeBitCast(target, to: UnsafeRawPointer.self)) // Retain for lifetime of receiver
        return target
    }
}

extension UIButton {
    @discardableResult
    @objc public func addTapHandler(_ handler: @escaping () -> Void) -> TargetActionHandler {
        return addHandler(for: .touchUpInside, handler: handler)
    }
}

extension UIBarButtonItem {
    @objc public convenience init(title: String, style: UIBarButtonItem.Style, handler: @escaping () -> Void) {
        let target = TargetActionHandler(handler)
        self.init(title: title, style: style, target: target, action: #selector(TargetActionHandler.invoke))
        setAssociatedValue(target, forKey: unsafeBitCast(target, to: UnsafeRawPointer.self)) // Retain for lifetime of receiver
    }
}

extension UIView {
    @objc public func addTapGestureHandler(_ handler: @escaping () -> Void) {
        if !isUserInteractionEnabled {
            isUserInteractionEnabled = true
        }
        let tap = UITapGestureRecognizer.init {
            handler()
        }
        self.addGestureRecognizer(tap)
    }
}
