// Copyright © 2021 evan. All rights reserved.

import UIKit
import Foundation

public func lazy<T>(_ variable: inout T?, construction: () throws -> T) rethrows -> T {
    if let value = variable {
        return value
    } else {
        let value = try construction()
        variable = value
        return value
    }
}

public class CalendarDate : NSObject {
    var year: Int!
    var month: Int!
    var day: Int!
}

extension CalendarDate : Comparable {
    // MARK: Nested Types
    public enum Component { case year, month, day }

    // MARK: Caching
    private static var gregorianCalendarCache: [TimeZone:Calendar] = [:]

    // MARK: Initialization/Conversion
    public convenience init(year: Int, month: Int, day: Int) {
        self.init()
        self.year = year
        self.month = month
        self.day = day
    }

    @objc public convenience init(date: Date, timeZone: TimeZone) {
        let calendar = lazy(&CalendarDate.gregorianCalendarCache[timeZone]) { Calendar(identifier: .gregorian, timeZone: timeZone) }
        let components = calendar.dateComponents([ .year, .month, .day ], from: date)
        self.init(year: components.year!, month: components.month!, day: components.day!)
    }

    @objc(dateInTimeZone:)
    public func date(in timeZone: TimeZone) -> Date {
        let calendar = lazy(&CalendarDate.gregorianCalendarCache[timeZone]) { Calendar(identifier: .gregorian, timeZone: timeZone) }
        let components = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: components)!
    }

    public static func today(in timeZone: TimeZone) -> CalendarDate {
        return CalendarDate(date: Date(), timeZone: timeZone)
    }

    /// The minimum representable calendar date.
    public static var distantPast: CalendarDate { return CalendarDate(year: .min, month: 1, day: 1) }
    /// The maximum representable calendar date.
    public static var distantFuture: CalendarDate { return CalendarDate(year: .max, month: 12, day: 31) }

    public static func converted(fromJSON json: Any) -> Any? {
        guard let string = json as? String else { return nil }
        let regex = try! NSRegularExpression(pattern: "^([0-9]{4})-([0-9]{2})-([0-9]{2})$")
        guard let match = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.count)).first else { return nil }
        func parseComponent(at index: Int) -> Int {
            let range = match.range(at: index)
            let componentAsString = (string as NSString).substring(with: range)
            return Int(componentAsString)!
        }
        let result = CalendarDate()
        (result.year, result.month, result.day) = (parseComponent(at: 1), parseComponent(at: 2), parseComponent(at: 3))
        return result
    }

    @objc public func toJSON() -> Any? { return description }

    open override var description: String { return String(format: "%04ld-%02ld-%02ld", year, month, day) }

    // MARK: Computation
    public var lastDayOfMonth: Int {
        let calendar = Calendar.localGregorian // Time zone does not matter here, as long as we convert both ways with the same one. Must be Gregorian though.
        let date = self.date(in: calendar.timeZone)
        return calendar.range(of: .day, in: .month, for: date)!.upperBound - 1
    }

    public var weekday: Int {
        let calendar = Calendar.localGregorian // Time zone does not matter here, as long as we convert both ways with the same one. Must be Gregorian though.
        let date = self.date(in: calendar.timeZone)
        return calendar.component(.weekday, from: date)
    }

    @objc public func adding(years: Int = 0, months: Int = 0, days: Int = 0) -> CalendarDate {
        let calendar = Calendar.localGregorian
        var result = self.date(in: calendar.timeZone)
        result = calendar.date(byAdding: .year, value: years, to: result)!
        result = calendar.date(byAdding: .month, value: months, to: result)!
        result = calendar.date(byAdding: .day, value: days, to: result)!
        return CalendarDate(date: result, timeZone: calendar.timeZone)
    }

    public func setting(year: Int? = nil, month: Int? = nil, day: Int? = nil) -> CalendarDate {
        if let month = month { precondition(1...12 ~= month) }
        if let day = day { precondition(1...31 ~= day) }
        let result = CalendarDate()
        result.year = year ?? self.year
        result.month = month ?? self.month
        result.day = 1 // Set to a valid value so `result.lastDayOfMonth` is correct
        result.day = day?.constrained(to: 1...result.lastDayOfMonth) ?? self.day
        return result
    }

    public static func component(_ component: Component, from date1: CalendarDate, to date2: CalendarDate) -> Int {
        let calendarComponent = Calendar.Component(component)
        return components([ component ], from: date1, to: date2).value(for: calendarComponent)!
    }

    public static func components(_ components: Set<Component>, from date1: CalendarDate, to date2: CalendarDate) -> DateComponents {
        let calendarComponents = Set(components.map { Calendar.Component($0) })
        return Calendar.localGregorian.dateComponents(calendarComponents, from: DateComponents(date1), to: DateComponents(date2))
    }

    public func isEqual(to other: CalendarDate, toGranularity granularity: Component) -> Bool {
        return compare(to: other, toGranularity: granularity) == .orderedSame
    }

    public func compare(to other: CalendarDate, toGranularity granularity: Component) -> ComparisonResult {
        let calendar = Calendar.localGregorian
        return calendar.compare(self.date(in: calendar.timeZone), to: other.date(in: calendar.timeZone), toGranularity: Calendar.Component(granularity))
    }

    public static func firstDay(inMonthOf date: CalendarDate) -> CalendarDate { return day(1, inMonthOf: date) }
    public static func lastDay(inMonthOf date: CalendarDate) -> CalendarDate { return day(31, inMonthOf: date) }

    /// Constrains to valid days that are valid for that month.
    public static func day(_ day: Int, inMonthOf calendarDate: CalendarDate) -> CalendarDate {
        return CalendarDate(year: calendarDate.year, month: calendarDate.month, day: day.constrained(to: 1...calendarDate.lastDayOfMonth))
    }

    // MARK: Hashable Conformance
    open override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CalendarDate else { return false }
        return (year, month, day) == (other.year, other.month, other.day)
    }

    open override var hash: Int { return year.hashValue ^ month.hashValue ^ day.hashValue }

    // MARK: Legacy
    @objc public func objc_isBeforeDate(_ other: CalendarDate) -> Bool {
        return self < other
    }
}

// MARK: Convenience
extension DateComponents {
    public init(_ date: CalendarDate) { self.init(year: date.year, month: date.month, day: date.day) }
}

private extension Calendar.Component {
    init(_ component: CalendarDate.Component) {
        switch component {
        case .year: self = .year
        case .month: self = .month
        case .day: self = .day
        }
    }
}

// MARK: Comparable Conformance
public func < (lhs: CalendarDate, rhs: CalendarDate) -> Bool { return (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day) }

