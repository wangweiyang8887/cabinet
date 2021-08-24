// Copyright © 2021 evan. All rights reserved.

import Foundation

extension DateFormatter {
    @objc public convenience init(dateFormat: String) {
        self.init()
        self.locale = Locale(identifier: "zh")
        self.dateFormat = dateFormat
    }

    public static let cabinetTimeDateFormatter = DateFormatter(dateFormat: "HH:mm:ss")
    public static let cabinetTimeShortDateFormatter = DateFormatter(dateFormat: "HH:mm")
    public static let cabinetShortDateFormatter = DateFormatter(dateFormat: "MM dd")
    public static let cabinetWeekday = DateFormatter(dateFormat: "EEEE")
    
}

extension Date {
    public func formatted(using formatter: DateFormatter) -> String {
        return formatter.string(from: self)
    }
    
    /// e.g. 07:23:23
    public func cabinetTimeDateFormatted() -> String {
        return formatted(using: .cabinetTimeDateFormatter)
    }
    
    /// e.g. 07:23
    public func cabinetTimeShortDateFormatted() -> String {
        return formatted(using: .cabinetTimeShortDateFormatter)
    }
    
    /// e.g. 12 22
    public func cabinetShortTimelessDateFormatted() -> String {
        return formatted(using: .cabinetShortDateFormatter)
    }
    
    public func cabinetWeedayFomatted() -> String {
        return formatted(using: .cabinetWeekday)
    }

    public enum AutoFormatStyle { case dateOrTime, dateAndTime, timeExcludingDateIfImplicit, timelessDate }


}
