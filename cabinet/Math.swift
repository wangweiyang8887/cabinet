// Copyright © 2021 evan. All rights reserved.

import Foundation

extension FloatingPoint {
    /// Maps `self` from its relative position in `source` to the equivalent in `target`.
    /// - parameter constrained: If `true`, constrains the result to be within `target`.
    public func linearMap(from source: ClosedRange<Self>, to target: ClosedRange<Self>, constrained: Bool = true) -> Self {
        return linearMap(from: (source.lowerBound, source.upperBound), to: (target.lowerBound, target.upperBound), constrained: constrained)
    }

    /// Maps `self` from its relative position between `source.a` and `source.b` to the equivalent between `target.a` and `target.b`.
    ///
    /// Allows `b < a` (which inverts the relative position) as well as `self` being outside of `source`.
    /// - parameter constrained: If `true`, constrains the result to be between `target.a` and `target.b`.
    public func linearMap(from source: (a: Self, b: Self), to target: (a: Self, b: Self), constrained: Bool = true) -> Self {
        // Map value, multiplying before division because Self could be an integer type.
        // Use intermediate because otherwise expression is too complex for the compiler
        let intermediate = (self - source.a) * (target.b - target.a)
        let result = intermediate / (source.b - source.a) + target.a
        // Return, constrained if needed
        if constrained {
            let targetMin = min(target.a, target.b)
            let targetMax = max(target.a, target.b)
            return result.constrained(to: targetMin...targetMax)
        } else {
            return result
        }
    }

    public func signum() -> Int {
        if self > 0 { return 1 }
        if self < 0 { return -1 }
        return 0
    }
}

extension BinaryInteger {
    public func divide(by divisor: Self, roundingUp: Void) -> Self {
        return (self + (divisor - 1)) / divisor
    }
}

infix operator ** : ExponentiationPrecedence

public func ** <T : BinaryInteger>(lhs: T, rhs: T) -> T {
    precondition(rhs >= 0)
    var result: T = 1
    var count: T = 0
    while count < rhs {
        result *= lhs
        count += 1
    }
    return result
}

extension Sequence where Element : Numeric {
    public func sum() -> Element { return reduce(0, +) }
}

