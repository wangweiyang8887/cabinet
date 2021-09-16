// Copyright © 2021 evan. All rights reserved.

import UIKit
import MapKit

public enum HorizontalDirection { case left, right }
public enum VerticalDirection { case up, down }
public enum DepthDirection { case forward, backward }

@objc public enum VerticalSide : Int { case top, bottom }

public protocol AnyOptional {
    static var any_none: Any { get }
}

extension Swift.Optional : AnyOptional {
    public static var any_none: Any { return self.none as Any }

    public mutating func take() -> Wrapped? {
        guard let value = self else { return nil }
        self = nil
        return value
    }
}

public var 🔥: Never { preconditionFailure() }

/// A generic informationless error.
public struct GenericError : Error {
    public init() {}
}

public struct CancelledError : Error {
    public init() {}
}

extension UILabel {
    public func addTransition(withDuration duration: TimeInterval = TTDuration.default) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        layer.add(transition, forKey: nil)
    }
}

// Common Closures
public typealias SortingClosure<T> = (T, T) -> Bool
public typealias ActionClosure = () -> Void
public typealias ObjectClosure<Value> = (Value) -> Void
typealias AsyncActionClosure = () -> Operation<Void>
typealias FetchClosure<Value> = () -> Operation<Value>
public typealias ValueChangedHandler<Value> = (Value) -> Void
public typealias FormatterClosure<Value> = (Value) -> String
public typealias PredicateClosure<Value> = (Value) -> Bool
public typealias FilterClosure<Value> = PredicateClosure<Value>
public typealias SelectionHandler<Value> = (Value) -> Void
public typealias ObjCCompletionHandler<Value> = (Value?, Error?) -> Void

/// Workaround for https://bugs.swift.org/browse/SR-6025
public func downcast<T>(_ value: Any, to _: T.Type) -> T? { return value as? T }

public func ~= <S : Sequence>(lhs: S, rhs: S.Element) -> Bool where S.Element : Equatable { return lhs.contains(rhs) }

extension Int {
    public var nilIfZero: Int? { return self == 0 ? nil : self }
}

extension Decimal {
    public var nilIfZero: Decimal? { return self == 0 ? nil : self }
}

extension Bool {
    public var localizedYesOrNo: String { return self ? NSLocalizedString("Yes", comment: "") : NSLocalizedString("No", comment: "") }
}

public typealias Distance = Measurement<UnitLength>
public typealias Duration = Measurement<UnitDuration>

extension Measurement where UnitType == UnitDuration {
    public var timeInterval: TimeInterval { return converted(to: .seconds).value }

    /// Converts a duration of a given unit to a dictionary of units and values that contains the duration units from the largest (hours) up to the components specified.
    ///
    ///     let components: [UnitDuration:Int] = Measurement.convert(9002, .seconds, toDurationComponentsUpTo: .seconds) // [ 2, 30, 2 ]
    ///     print("\(durationComponents[.hours]!) hours, \(durationComponents[.minutes]!) minutes, \(durationComponents[.seconds]!) seconds") // 2 hours, 30 minutes, 2 seconds
    ///     durationComponents[.milliseconds] == nil // true
    ///
    /// - Parameters:
    ///   - durationValue: the duration being converted.
    ///   - durationUnit: the unit of the given value.
    ///   - smallestDurationUnit: the smallest duration unit in the result.
    public static func convert<MeasurementType : BinaryInteger>(_ durationValue: Double, _ durationUnit: UnitDuration, toDurationComponentsUpTo smallestDurationUnit: UnitDuration) -> [UnitDuration:MeasurementType] {
        let basicDurationUnits: [UnitDuration] = [ .hours, .minutes, .seconds ]
        let additionalDurationUnits: [UnitDuration]
        if #available(iOS 13.0, *) {
            additionalDurationUnits = [ .milliseconds, .microseconds, .nanoseconds, .picoseconds ]
        } else {
            additionalDurationUnits = []
        }
        let allDurationUnits = basicDurationUnits + additionalDurationUnits
        let components: [MeasurementType] = sequence(first: (Measurement.convert(Measurement(value: durationValue, unit: durationUnit).converted(to: smallestDurationUnit).value, allDurationUnits[0], to: smallestDurationUnit), 0)) {
            if allDurationUnits[$0.1] == smallestDurationUnit || allDurationUnits.count <= $0.1 + 1 {
                return nil
            } else {
                return (Measurement.convert($0.0.1, allDurationUnits[$0.1 + 1], to: smallestDurationUnit), $0.1 + 1)
            }
        }.compactMap { $0.0.0 }
        var result: [UnitDuration:MeasurementType] = [:]
        result[.hours] = components[ifPresent: 0]
        result[.minutes] = components[ifPresent: 1]
        result[.seconds] = components[ifPresent: 2]
        if #available(iOS 13.0, *) {
            result[.milliseconds] = components[ifPresent: 3]
            result[.microseconds] = components[ifPresent: 4]
            result[.nanoseconds] = components[ifPresent: 5]
            result[.picoseconds] = components[ifPresent: 6]
        }
        return result
    }

    /// Converts a measurement value of a defined unit to another (smaller) unit.
    ///
    /// - Parameters:
    ///   - durationValue: the measurement being converted.
    ///   - durationUnit: the unit of the given value.
    ///   - targetDurationUnit: the smallest duration unit in the result.
    /// - Precondition: the `targetDurationUnit` has to be a unit smaller than or equal to the `durationUnit`.
    /// - Returns: a tuple containing the value converted to the target unit, as well as the value remaining till the next integer unit (aka the "rest" of the division).
    private static func convert<MeasurementType : BinaryInteger>(_ durationValue: Double, _ durationUnit: UnitDuration, to targetDurationUnit: UnitDuration) -> (MeasurementType, Double) {
        let measurementSmallest = Measurement(value: durationValue, unit: targetDurationUnit)
        let measurementSmallestValue = MeasurementType(measurementSmallest.converted(to: durationUnit).value)
        let measurementCurrentUnit = Measurement(value: Double(measurementSmallestValue), unit: durationUnit)
        let currentUnitCount = measurementCurrentUnit.converted(to: targetDurationUnit).value
        return (measurementSmallestValue, durationValue - currentUnitCount)
    }
}

extension Measurement where UnitType == UnitLength {
    public var locationDistance: CLLocationDistance { return converted(to: .meters).value }
}

extension Measurement {
    public init(_ value: Double, _ unit: UnitType) { self.init(value: value, unit: unit) }
}

extension Sequence where Element : Comparable {
    /// Returns the range `min ... max`, or `nil` if the sequence is empty.
    public func elementRange() -> ClosedRange<Element>? {
        var iterator = makeIterator()
        guard let first = iterator.next() else { return nil }
        var (min, max) = (first, first)
        while let element = iterator.next() {
            if element < min { min = element }
            else if element >= max { max = element } // >= to match stdlib behavior of max
        }
        return min...max
    }
}

extension ClosedRange {
    public func union(_ other: ClosedRange<Bound>) -> ClosedRange<Bound> {
        return Swift.min(lowerBound, other.lowerBound)...Swift.max(upperBound, other.upperBound)
    }

    public func union(_ other: Bound) -> ClosedRange<Bound> {
        return Swift.min(lowerBound, other)...Swift.max(upperBound, other)
    }

    public init(value: Bound) {
        self = value...value
    }
}

extension ClosedRange where Bound : Numeric {
    public var length: Bound { return upperBound - lowerBound }
}

extension Collection {
    /// Returns `self[index]` if `index` is a valid index, or `nil` otherwise.
    public subscript(ifValid index: Index) -> Iterator.Element? {
        return (index >= startIndex && index < endIndex) ? self[index] : nil
    }

    /// Given the collection contains only exactly one element, returns it; otherwise returns `nil`.
    public var onlyElement: Element? { return count == 1 ? first : nil }

    public var nilIfEmpty: Self? { return isEmpty ? nil : self }
}

/// A no-op that prevents the passed argument from being optimized away by the compiler.
@inline(never)
public func touch(_ x: Any?) {}

precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

public func fatalError<T>(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> T {
    Swift.fatalError(message(), file: file, line: line)
}

public func preconditionFailure<T>(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> T {
    Swift.preconditionFailure(message(), file: file, line: line)
}

public func notImplemented(function: String = #function, file: String = #file, line: Int = #line) -> Never {
    preconditionFailure("Function not implemented: \(function) in \"\(file)\" line #\(line).")
}

public func abstract(function: String = #function, file: String = #file, line: Int = #line) -> Never {
    preconditionFailure("Abstract method not implemented: \(function) in \"\(file)\" line #\(line).")
}

protocol Rangeable : Comparable {
    var asDouble: Double { get }
    static func from(_ double: Double) -> Any
}

extension Decimal : Rangeable {
    var asDouble: Double { return Double(truncating: self as NSNumber) }
    static func from(_ double: Double) -> Any { return Decimal(double) }
}

extension Double : Rangeable {
    var asDouble: Double { return self }
    static func from(_ double: Double) -> Any { return double }
}

extension Int : Rangeable {
    var asDouble: Double { return Double(self) }
    static func from(_ double: Double) -> Any { return Int(double) }
}
