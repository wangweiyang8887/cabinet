// Copyright © 2021 evan. All rights reserved.

extension UserDefaults {
    public static let shared: UserDefaults = { return UserDefaults.standard }()
    
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
}
