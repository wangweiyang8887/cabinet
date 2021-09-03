// Copyright © 2021 evan. All rights reserved.

import CoreGraphics
import UIKit

// MARK: Point
public func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint { return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y) }
public func + (lhs: CGPoint, rhs: CGSize) -> CGPoint { return CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height) }
public func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint { return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }
public func - (lhs: CGPoint, rhs: CGSize) -> CGPoint { return CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height) }
public func / (lhs: CGPoint, rhs: CGPoint) -> CGPoint { return CGPoint(x: lhs.x / rhs.x, y: lhs.y / rhs.y) }
public func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint { return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs) }
public func * (lhs: CGPoint, rhs: CGPoint) -> CGPoint { return CGPoint(x: lhs.x * rhs.x, y: lhs.y * rhs.y) }
public func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint { return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs) }
public func += (lhs: inout CGPoint, rhs: CGPoint) { return lhs = lhs + rhs }
public func -= (lhs: inout CGPoint, rhs: CGPoint) { return lhs = lhs - rhs }
public func *= (lhs: inout CGPoint, rhs: CGPoint) { return lhs = lhs * rhs }
public func *= (lhs: inout CGPoint, rhs: CGFloat) { return lhs = lhs * rhs }
public func /= (lhs: inout CGPoint, rhs: CGPoint) { return lhs = lhs / rhs }
public func /= (lhs: inout CGPoint, rhs: CGFloat) { return lhs = lhs / rhs }
public prefix func - (p: CGPoint) -> CGPoint { return CGPoint(x: -p.x, y: -p.y) }

extension CGPoint {
    /// Return the Euclidian distance from `self` to `p`.
    public func distance(to p: CGPoint) -> CGFloat {
        let dx = p.x - x
        let dy = p.y - y
        return hypot(dx, dy)
    }

    /// Return the Euclidian distance from `self` to the closest point inside `rect`.
    public func distance(to rect: CGRect) -> CGFloat {
        return distance(to: self.constrained(to: rect))
    }

    /// The Euclidian distance between `self` and the point (0, 0).
    public var distanceToOrigin: CGFloat { return distance(to: CGPoint.zero) }

    public init(radius: CGFloat, angle: CGFloat) {
        self.init(x: cos(angle) * radius, y: sin(angle) * radius)
    }

    /// In the range `(-π, +π]`.
    public func direction(to other: CGPoint) -> CGFloat {
        let delta = other - self
        return atan2(delta.y, delta.x)
    }

    public init(angle: CGFloat, radius: CGFloat) {
        let x = cos(angle) * radius
        let y = sin(angle) * radius
        self.init(x: x, y: y)
    }

    /// Return a copy of `self` with both components constrained to `rect`.
    public func constrained(to rect: CGRect) -> CGPoint {
        var p = self
        p.x = p.x.constrained(to: rect.minX...rect.maxX)
        p.y = p.y.constrained(to: rect.minY...rect.maxY)
        return p
    }

    /// Constrain both components to `rect`.
    public mutating func constrain(rect: CGRect) {
        self = self.constrained(to: rect)
    }
}

// MARK: Size
extension CGSize {
    public init(uniform value: CGFloat) {
        self.init(width: value, height: value)
    }

    // MARK: Scaling
    public func scaling(to targetSize: CGSize, scaleMode: ScaleMode = .fill) -> CGSize {
        var scaling = targetSize / self
        // Adjust scale for aspect fit/fill
        switch scaleMode {
        case .aspectFit: scaling = CGSize(uniform: min(scaling.width, scaling.height))
        case .aspectFill: scaling = CGSize(uniform: max(scaling.width, scaling.height))
        case .fill: break
        }
        // New size
        return self * scaling
    }
}

public func + (lhs: CGSize, rhs: CGSize) -> CGSize { return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height) }
public func - (lhs: CGSize, rhs: CGSize) -> CGSize { return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height) }
public func * (lhs: CGSize, rhs: CGSize) -> CGSize { return CGSize(width: lhs.width * rhs.width, height: lhs.height * rhs.height) }
public func * (lhs: CGSize, rhs: CGFloat) -> CGSize { return CGSize(width: lhs.width * rhs, height: lhs.height * rhs) }
public func / (lhs: CGSize, rhs: CGSize) -> CGSize { return CGSize(width: lhs.width / rhs.width, height: lhs.height / rhs.height) }
public func / (lhs: CGSize, rhs: CGFloat) -> CGSize { return CGSize(width: lhs.width / rhs, height: lhs.height / rhs) }
public func += (lhs: inout CGSize, rhs: CGSize) { return lhs = lhs + rhs }
public func -= (lhs: inout CGSize, rhs: CGSize) { return lhs = lhs - rhs }
public func *= (lhs: inout CGSize, rhs: CGSize) { return lhs = lhs * rhs }
public func *= (lhs: inout CGSize, rhs: CGFloat) { return lhs = lhs * rhs }
public func /= (lhs: inout CGSize, rhs: CGSize) { return lhs = lhs / rhs }
public func /= (lhs: inout CGSize, rhs: CGFloat) { return lhs = lhs / rhs }

// MARK: Rect
extension CGRect {
//    public var x: CGFloat { get { return origin.x } set { origin.x = newValue } }
//    public var y: CGFloat { get { return origin.y } set { origin.y = newValue } }
//    public var width: CGFloat { get { return size.width } set { size.width = newValue } }
//    public var height: CGFloat { get { return size.height } set { size.height = newValue } }

    public var center: CGPoint { return CGPoint(x: midX, y: midY) }

    public init(center: CGPoint, size: CGSize) {
        self.init(origin: center - size / 2, size: size)
    }

    public func point(atFractionOfX xFraction: CGFloat, y yFraction: CGFloat) -> CGPoint {
        let x = xFraction.linearMap(from: 0...1, to: minX...maxX)
        let y = yFraction.linearMap(from: 0...1, to: minY...maxY)
        return CGPoint(x: x, y: y)
    }

    // MARK: Scaling
    public func scaling(to target: CGRect, scaleMode: ScaleMode = .fill) -> CGRect {
        // Compute new size & center
        let newSize = size.scaling(to: target.size, scaleMode: scaleMode)
        let newCenter = target.center
        return CGRect(center: newCenter, size: newSize)
    }
}

public enum ScaleMode {
    case fill, aspectFit, aspectFill

    public init?(_ contentMode: UIView.ContentMode) {
        switch contentMode {
        case .scaleToFill: self = .fill
        case .scaleAspectFit: self = .aspectFit
        case .scaleAspectFill: self = .aspectFill
        default: return nil
        }
    }
}

// MARK: Insets
extension UIEdgeInsets {
    public init(uniform value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }

    public init(horizontal horizontalInset: CGFloat = 0, vertical verticalInset: CGFloat = 0) {
        self.init(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
}

// MARK: Transform
extension CGAffineTransform {
    public init(rotationAngle: CGFloat, around center: CGPoint) {
        let (sn, cs) = (sin(rotationAngle), cos(rotationAngle))
        let (a, b, c, d) = (cs, sn, -sn, cs)
        let tx = (a * -center.x) + (c * -center.y) + center.x
        let ty = (b * -center.x) + (d * -center.y) + center.y
        self.init(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }

    public init(scaleX: CGFloat, y scaleY: CGFloat, around center: CGPoint) {
        let (a, b, c, d) = (scaleX, 0 as CGFloat, 0 as CGFloat, scaleY)
        let tx = center.x - (scaleX * center.x)
        let ty = center.y - (scaleY * center.y)
        self.init(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }
}


