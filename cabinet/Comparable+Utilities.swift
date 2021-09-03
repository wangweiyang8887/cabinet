// Copyright © 2021 evan. All rights reserved.

import Foundation

extension Comparable {
    public func constrained(to range: ClosedRange<Self>) -> Self {
        if self > range.upperBound { return range.upperBound }
        if self < range.lowerBound { return range.lowerBound }
        return self
    }

    public func constrained(toAtLeast min: Self) -> Self {
        if self < min { return min }
        return self
    }

    public func constrained(toAtMost max: Self) -> Self {
        if self > max { return max }
        return self
    }

    public func constrained(toMin min: Self) -> Self { return constrained(toAtLeast: min) }
    public func constrained(toMax max: Self) -> Self { return constrained(toAtMost: max) }

    public mutating func constrain(to range: ClosedRange<Self>) { self = self.constrained(to: range) }
    public mutating func constrain(toMin min: Self) { self = self.constrained(toMin: min) }
    public mutating func constrain(toMax max: Self) { self = self.constrained(toMax: max) }
    public mutating func constrain(toAtLeast min: Self) { self = self.constrained(toAtLeast: min) }
    public mutating func constrain(toAtMost max: Self) { self = self.constrained(toAtMost: max) }
}
