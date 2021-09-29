// Copyright © 2021 evan. All rights reserved.

import UIKit

typealias ViewHandler = (UIView) -> Void

extension UIView {
    func viewIterator(_ viewHandler: ViewHandler) {
        subviews.forEach {
            viewHandler($0)
            $0.viewIterator(viewHandler)
            print($0)
        }
    }

    @IBInspectable public var autoAdjustsTintColor: Bool {
        get { return tintAdjustmentMode == .automatic }
        set {
            if newValue {
                tintAdjustmentMode = .automatic
            } else {
                if tintAdjustmentMode == .automatic { tintAdjustmentMode = .normal }
                // If non-automatic already, preserve current value (dimmed/normal)
            }
        }
    }

    public func convertBounds(to view: UIView?) -> CGRect {
        return convert(bounds, to: view)
    }

    public func setClipToCircle(_ clipToCircle: Bool) {
        if clipToCircle { layer.masksToBounds = true }
        layer.cornerRadius = clipToCircle ? min(frame.width, frame.height) / 2 : 0
    }
    /// Sets the corner radius to this view.
    /// - Note: if you call this method multiple times, only the last call will prevail, discarding the changes made by any previous call.
    public func setCornerRadius(_ cornerRadius: CornerRadius) {
        setCorner(cornerRadius.corners, radius: cornerRadius.radius)
    }

    /// Sets the corner radius to the given corners.
    /// - Parameters:
    ///   - corners: The corners to apply the radius for. Defaults to all corners.
    ///   - radius: The radius to apply on the given corners.
    /// - Note: if you call this method multiple times, only the last call will prevail, discarding the changes made by any previous call.
    public func setCorner(_ corners: UIRectCorner = .allCorners, radius: CGFloat) {
        setCorner(corners, radius: radius, boundsForCorner: bounds)
    }

    /// Sets the corner radius to the given corners.
    /// - Parameters:
    ///   - corners: The corners to apply the radius for. Defaults to all corners.
    ///   - radius: The radius to apply on the given corners.
    ///   - boundsForCorner: The shape layer's frame.
    /// - Note: if you call this method multiple times, only the last call will prevail, discarding the changes made by any previous call.
    public func setCorner(_ corners: UIRectCorner = .allCorners, radius: CGFloat, boundsForCorner: CGRect) {
        let maskPath = UIBezierPath(roundedRect: boundsForCorner, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = boundsForCorner
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }

    public convenience init(wrapping view: UIView, with insets: UIEdgeInsets = .zero) {
        self.init()
        addSubview(view, pinningEdges: .all, withInsets: insets)
    }

    /// Fix for an iOS bug: https://github.com/nkukushkin/StackView-Hiding-With-Animation-Bug-Example
    public var patched_isHidden: Bool {
        get { return isHidden }
        set { repeat { isHidden = newValue } while isHidden != newValue }
    }

    // MARK: Constraints
    /// - Note: this used to be an utility to help manage the bottom anchor for OS versions prior to iOS 11, but now it's equivalent to `safeAreaLayoutGuide.bottomAnchor`.
    public var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomAnchor
        }
    }

    /// - Note: this used to be an utility to help manage the top anchor for OS versions prior to iOS 11, but now it's equivalent to `safeAreaLayoutGuide.topAnchor`.
    public var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.topAnchor
        } else {
            return topAnchor
        }
    }

    @objc public func addSubview(_ subview: UIView, pinningEdges edges: UIRectEdge, withInsets insets: UIEdgeInsets = .zero) {
        addSubview(subview)
        subview.pinEdges(edges: edges, to: self, withInsets: insets, useSafeArea: false)
    }

    @objc public func addSubview(_ subview: UIView, pinningEdgesToSafeArea edges: UIRectEdge, withInsets insets: UIEdgeInsets = .zero) {
        addSubview(subview)
        subview.pinEdges(edges: edges, to: self, withInsets: insets, useSafeArea: true)
    }

    /// Adds the given subview to the receiver and constrains the given edges to its safe area.
    ///
    /// The constraints will be set up such that the insets merge with any additional margin due to the safe area, if applicable.
    @objc public func addSubview(_ subview: UIView, pinningEdgesToSafeArea edges: UIRectEdge, withCollapsingInsets insets: UIEdgeInsets) {
        addSubview(subview)
        subview.pinEdges(edges: edges, to: self, withInsets: insets, useSafeArea: true, collapseInsets: true)
    }

    @discardableResult public func pinEdges(edges: UIRectEdge = .all, to view: UIView, withInsets insets: UIEdgeInsets = .zero, useSafeArea: Bool = true, collapseInsets: Bool = false) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints: [NSLayoutConstraint] = []
        if edges.contains(.left) {
            constraints += leftAnchor.constraint(equalTo: view.leftAnchor, constant: insets.left)
        }
        if edges.contains(.right) {
            constraints += view.rightAnchor.constraint(equalTo: rightAnchor, constant: insets.right)
        }
        if edges.contains(.top) {
            if useSafeArea && collapseInsets {
                constraints += topAnchor.constraint(greaterThanOrEqualTo: view.safeTopAnchor)
                constraints += topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top).with(priority: .pseudoRequired)
            } else {
                let viewTopAnchor = useSafeArea ? view.safeTopAnchor : view.topAnchor
                constraints += topAnchor.constraint(equalTo: viewTopAnchor, constant: insets.top)
            }
        }
        if edges.contains(.bottom) {
            if useSafeArea && collapseInsets {
                constraints += view.safeBottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor)
                constraints += view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom).with(priority: .pseudoRequired)
            } else {
                let viewBottomAnchor = useSafeArea ? view.safeBottomAnchor : view.bottomAnchor
                constraints += viewBottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom)
            }
        }
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    // MARK: Decoration
    /// Adds separators to the given edges.
    /// - Parameters:
    ///   - edges: The edges where the separators will be added to.
    ///   - thickness: The thickness of the separator. Defaults to 1px (not 1pt).
    /// - Returns: an array containing only the separators that were requested to be added. The order of the views are: left, right, top and bottom.
    @discardableResult public func addSeparator(onEdges edges: UIRectEdge, thickness: CGFloat = 1 / UIScreen.main.scale, color: UIColor = .gray) -> [UIView] {
        var result: [UIView] = []
        if edges.contains(.left) { result += addSeparator(on: .minXEdge, thickness: thickness, color: color) }
        if edges.contains(.right) { result += addSeparator(on: .maxXEdge, thickness: thickness, color: color) }
        if edges.contains(.top) { result += addSeparator(on: .minYEdge, thickness: thickness, color: color) }
        if edges.contains(.bottom) { result += addSeparator(on: .maxYEdge, thickness: thickness, color: color) }
        return result
    }

    /// Removes separators added by the method `addSeparator(onEdges:thickness:)`.
    public func removeSeparators() {
        subviews.forEach { ($0 as? Separator)?.removeFromSuperview() }
    }

    private func addSeparator(on edge: CGRectEdge, thickness: CGFloat, color: UIColor = .cabinetSeparator) -> UIView {
        let separator = Separator()
        separator.backgroundColor = color
        switch edge {
        case .minXEdge, .maxXEdge:
            addSubview(separator, pinningEdgesToSafeArea: [ .top, .bottom, edge == .minXEdge ? .left : .right ])
            NSLayoutConstraint.activate([ separator.widthAnchor.constraint(equalToConstant: thickness) ])
        case .minYEdge, .maxYEdge:
            addSubview(separator, pinningEdgesToSafeArea: [ .left, .right, edge == .minYEdge ? .top : .bottom ])
            NSLayoutConstraint.activate([ separator.heightAnchor.constraint(equalToConstant: thickness) ])
        }
        return separator
    }

    private class Separator : UIView {}

    public func addBadge(withOffset offset: CGPoint = .zero) -> UIView {
        let badgeView = UIView()
        badgeView.backgroundColor = .red
        badgeView.cornerRadius = 8.0
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(badgeView)
        NSLayoutConstraint.activate([
            badgeView.heightAnchor.constraint(equalToConstant: 16),
            badgeView.widthAnchor.constraint(equalToConstant: 16),
            badgeView.centerXAnchor.constraint(equalTo: trailingAnchor, constant: offset.x),
            badgeView.centerYAnchor.constraint(equalTo: topAnchor, constant: offset.y),
        ])
        return badgeView
    }

    public func addDottedLine(strokeColor: UIColor, lineWidth: CGFloat) {
        backgroundColor = .clear

        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "DashedLine"
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = .round
        shapeLayer.lineDashPattern = [ 4, 4 ]

        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addRect(CGRect(origin: .zero, size: CGSize(width: frame.width, height: frame.height)))
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }

    /// - Note: In most cases, we should prefer a non-rasterized shadow in combination with a shadow path
    @objc public func addRasterizedShadow(ofSize radius: CGFloat, opacity: Float = 0.25, offset: CGSize = CGSize(width: 0, height: 1), color: UIColor = .black) {
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    public func addShadow(opacity: Float = 0.25, radius: CGFloat, yOffset: CGFloat, color: UIColor = .nonStandardColor(withRGBHex: 0xBBBBBB)) {
        layer.masksToBounds = false
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: 0, height: yOffset)
        layer.shadowColor = color.cgColor
    }

    public func removeShadow() {
        layer.shadowOpacity = 0
    }

    @objc public func getImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    public var firstResponder: UIView? {
        guard !isFirstResponder else { return self }
        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        return nil
    }

    public func addMissingRequiredFieldStyle() {
        borderColor = .red
        borderWidth = 1.0
    }

    public func removeMissingRequiredFieldStyle() {
        guard borderWidth != 0 else { return }
        borderColor = .clear
        borderWidth = 0.0
    }

    public func setHidden(_ hidden: Bool, animated: Bool) {
        guard animated else {
            isHidden = hidden
            alpha = hidden ? 0 : 1 // Keep consistency of the alpha value
            return
        }
        switch (isHidden, hidden) {
        case (true, true), (false, false):
            // The view is already in the state it should be, but we need to guarantee the alpha property.
            alpha = isHidden ? 0 : 1
        case (true, false):
            alpha = 0
            isHidden = false
            UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
                self.alpha = 1
            }, completion: nil)
        case (false, true):
            // Explicitly don't set the alpha outside the animation to avoid glitches
            UIView.animate(withDuration: 0.25, delay: 0, options: .beginFromCurrentState, animations: {
                self.alpha = 0
            }, completion: { [weak self] didComplete in
                guard didComplete else { return }
                self?.isHidden = true
            })
        }
    }
    @discardableResult
    public func addGradientLayer(start: CGPoint, end: CGPoint, colors: [CGColor]? = nil, locations: [NSNumber]? = nil, frame: CGRect? = nil) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame ?? self.bounds
        gradient.startPoint = start
        gradient.endPoint = end
        gradient.colors = colors
        gradient.locations = locations
        gradient.zPosition = -100
        gradient.cornerRadius = layer.cornerRadius
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
}


extension Array where Element == NSLayoutConstraint.Axis {
    static var all: [NSLayoutConstraint.Axis] { return [ .horizontal, .vertical ] }
}
