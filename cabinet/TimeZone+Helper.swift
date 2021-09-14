// Copyright © 2021 evan. All rights reserved.

import Foundation

extension TimeZone {
    public static let californiaTimeZone = TimeZone(identifier: "America/Los_Angeles")!
    public static let utc = TimeZone(identifier: "GMT")!
}

extension Calendar {
    public init(identifier: Identifier, timeZone: TimeZone) {
        self.init(identifier: identifier)
        self.timeZone = timeZone
    }
    
    /// A Gregorian calendar in the local (system) time zone.
    public static let localGregorian = Calendar(identifier: .gregorian)

    /// A Gregorian calendar in the UTC+0 time zone.
    public static let utcGregorianCalendar = Calendar(identifier: .gregorian, timeZone: .utc)
}
