// Copyright © 2021 evan. All rights reserved.

import Foundation

extension Calendar {
    static var chineseFormatter: DateFormatter {
        let calendar: Calendar = Calendar(identifier: .chinese)
        let formatter = DateFormatter(dateFormat: "")
        formatter.calendar = calendar
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }
    
    static var lunarYear: String {
        return String(chineseFormatter.string(from: Date()).filter { $0.isLetter }.prefix(3))
    }
    
    static var lunarMonthAndDay: String {
        return String(chineseFormatter.string(from: Date()).filter { $0.isLetter }.drop { lunarYear.contains($0) }).components(separatedBy: "星").first ?? ""
    }
    
    static var currentWeek: String { return DateFormatter(dateFormat: "EEEE").string(from: Date()) }
    static var currentMonth: String { return DateFormatter(dateFormat: "MMMM").string(from: Date()) }
}

extension DateFormatter {
    @objc public convenience init(dateFormat: String, identifier: String = "zh") {
        self.init()
        self.locale = Locale(identifier: identifier)
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
