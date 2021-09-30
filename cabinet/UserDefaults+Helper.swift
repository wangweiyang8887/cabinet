// Copyright © 2021 evan. All rights reserved.

import UIKit

/// Returns `f(x)` if `x` is non-`nil`; otherwise returns `nil`.
@discardableResult public func given<T, U>(_ x: T?, _ f: (T) throws -> U?) rethrows -> U? {
    guard let x = x else { return nil }
    return try f(x)
}

/// Returns `f(x!, y!)` if `x != nil && y != nil`; otherwise returns `nil`.
@discardableResult public func given<T, U, V>(_ x: T?, _ y: U?, _ f: (T, U) throws -> V?) rethrows -> V? {
    guard let x = x, let y = y else { return nil }
    return try f(x, y)
}

extension UserDefaults {
    public static let shared: UserDefaults = { UserDefaults(suiteName: "group.com.evan.cabinet")! }()
    
    public struct Property<Value> {
        public let keyName: String
        public let isUserSpecific: Bool

        // Declaring this redundant initializer is required to fix an issue where the initializer wasn't being made public, even though the properties are declared as public.
        public init(keyName: String, isUserSpecific: Bool) {
            self.keyName = keyName
            self.isUserSpecific = isUserSpecific
        }

        /// Can be `nil` for user specific keys when not logged in.
        fileprivate var key: String? {
            return keyName
        }
    }
    
    public subscript(property: Property<String>) -> String? {
        get { return given(property.key) { object(forKey: $0) as? String } }
        set { set(newValue, forKey: property.key!) }
    }

    public subscript(property: Property<Int>) -> Int? {
        get { return given(property.key) { integer(forKey: $0) } }
        set { set(newValue, forKey: property.key!) }
    }

    public subscript(property: Property<Bool>) -> Bool? {
        get { return given(property.key) { bool(forKey: $0) } }
        set { set(newValue, forKey: property.key!) }
    }
    
    public subscript(property: Property<Data>) -> Data? {
        get { return given(property.key) { data(forKey: $0) } }
        set {set(newValue, forKey: property.key!) }
    }

    public subscript(property: Property<Date>) -> Date? {
        get { return given(property.key) { object(forKey: $0) as? Date } }
        set { set(newValue, forKey: property.key!) }
    }

    /// - Requires: `T` must be a property list object type: `Data`, `String`, `Date`, `Array`, `Dictionary` or convertible to `NSNumber`.
    public subscript<T>(property: Property<[T]>) -> [T]? {
        get { return given(property.key) { array(forKey: $0) as? [T] } }
        set { set(newValue, forKey: property.key!) }
    }

    public subscript<T : RawRepresentable>(property: Property<T>) -> T? where T.RawValue == String {
        get {
            guard let key = property.key, let rawValue = object(forKey: key) as? String, let value = T(rawValue: rawValue) else { return nil }
            return value
        }
        set { set(newValue?.rawValue, forKey: property.key!) }
    }
}

// MARK: - Keys
extension UserDefaults.Property {
    public static var deviceID: UserDefaults.Property<String> { return .init(keyName: "DeviceID", isUserSpecific: false) }
    public static var authToken: UserDefaults.Property<String> { return .init(keyName: "authToken", isUserSpecific: false) }
    
    public static var eventName: UserDefaults.Property<String> { return .init(keyName: "eventName", isUserSpecific: false) }
    public static var eventDate: UserDefaults.Property<String> { return .init(keyName: "eventDate", isUserSpecific: false) }
    public static var shuffledDay: UserDefaults.Property<Int> { return .init(keyName: "shuffledDay", isUserSpecific: false) }
    public static var userCoordinate: UserDefaults.Property<String> { return .init(keyName: "userCoordinate", isUserSpecific: false) }
    public static var userAddress: UserDefaults.Property<String> { return .init(keyName: "userAddress", isUserSpecific: false) }
    public static var todayYI: UserDefaults.Property<String> { return .init(keyName: "todayYI", isUserSpecific: false) }
    public static var todayJI: UserDefaults.Property<String> { return .init(keyName: "todayJI", isUserSpecific: false) }
    public static var userImage: UserDefaults.Property<Data> { return .init(keyName: "userImage", isUserSpecific: false) }
}

extension UserDefaults.Property {
    // Weather View
    public static var weatherForeground: UserDefaults.Property<Data> { return .init(keyName: "weatherForeground", isUserSpecific: false) }
    public static var weatherBackground: UserDefaults.Property<Data> { return .init(keyName: "weatherBackground", isUserSpecific: false) }
    // Event View
    public static var eventForeground: UserDefaults.Property<Data> { return .init(keyName: "eventForeground", isUserSpecific: false) }
    public static var eventBackground: UserDefaults.Property<Data> { return .init(keyName: "eventBackground", isUserSpecific: false) }
    // Calendar View
    public static var calendarForeground: UserDefaults.Property<Data> { return .init(keyName: "calendarForeground", isUserSpecific: false) }
    public static var calendarBackground: UserDefaults.Property<Data> { return .init(keyName: "calendarBackground", isUserSpecific: false) }
    // Daily View
    public static var dailyForeground: UserDefaults.Property<Data> { return .init(keyName: "dailyForeground", isUserSpecific: false) }
    public static var dailyBackground: UserDefaults.Property<Data> { return .init(keyName: "dailyBackground", isUserSpecific: false) }
    // Clock View
    public static var clockForeground: UserDefaults.Property<Data> { return .init(keyName: "clockForeground", isUserSpecific: false) }
    public static var clockBackground: UserDefaults.Property<Data> { return .init(keyName: "clockBackground", isUserSpecific: false) }
    // Lottery View
    public static var lotteryForeground: UserDefaults.Property<Data> { return .init(keyName: "lotteryForeground", isUserSpecific: false) }
    public static var lotteryBackground: UserDefaults.Property<Data> { return .init(keyName: "lotteryBackground", isUserSpecific: false) }
    // Counting View
    public static var countingForeground: UserDefaults.Property<Data> { return .init(keyName: "countingForeground", isUserSpecific: false) }
    public static var countingBackground: UserDefaults.Property<Data> { return .init(keyName: "countingBackground", isUserSpecific: false) }
}
