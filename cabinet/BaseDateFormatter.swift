// Copyright © 2021 evan. All rights reserved.

import Foundation

extension DateFormatter {
    @objc public convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
        // Make locale US invariant. Needed because even with an explicit date format string iOS partially localizes it,
        // in particular it can replace 12-hour clock by 24-hour clock formatting.
//        self.locale = Locale(identifier: "en_US_POSIX")
//        self.calendar = .localGregorian
    }

    public static let cabinetTimeDateFormatter = DateFormatter(dateFormat: "hh : mm : ss")
    public static let cabinetShortTimelessDateFormatter = DateFormatter(dateFormat: "yyyy MM dd")
    
    public static let peogooMidumDateAndTimeFormatter = DateFormatter(dateFormat: "yyyy.MM.dd hh:mm")
    public static let peogooShortTimelessDateFormatterExcludingYear = DateFormatter(dateFormat: "MM-dd")
    public static let peogooShortDateAndTimeFormatter = DateFormatter(dateFormat: "MM/dd/yy h:mm a")
    public static let peogooShortDateAndTimeFormatterExcludingYear = DateFormatter(dateFormat: "MM/dd h:mm a")
    public static let peogooShortDatelessTimeFormatter = DateFormatter(dateFormat: "h:mm a")
    public static let peogooShortDayOfWeekAndTimeFormatter = DateFormatter(dateFormat: "EEE, h:mm a")
    public static let peogooMediumTimelessDateFormatter = DateFormatter(dateFormat: "MMM d, yyyy")
    public static let peogooMediumTimelessDateFormatterExcludingDay = DateFormatter(dateFormat: "MMM yyyy")
    public static let peogooMediumTimelessDateFormatterExcludingYear = DateFormatter(dateFormat: "d MMM")
    public static let peogooMediumDateAndTimeFormatter = DateFormatter(dateFormat: "MMM d, yyyy h:mm a")
    public static let peogooMediumTimelessDayOfWeekFormatter = DateFormatter(dateFormat: "EEEE")
    public static let peogooMediumDayOfWeekAndTimeFormatter = DateFormatter(dateFormat: "EEEE h:mm a")
    public static let peogooMediumMonthNameFormatter = DateFormatter(dateFormat: "MMM")
    public static let peogooLongMonthNameFormatter = DateFormatter(dateFormat: "MMMM")
    public static let peogooLongDateAndTimeFormatter = DateFormatter(dateFormat: "EEE, MMM d, yyyy, h:mm a")
    public static let peogooLongDateAndTimeFormatterExcludingYear = DateFormatter(dateFormat: "EEE, MMM d, h:mm a")

    public static let peogooLongYearFormatter = DateFormatter(dateFormat: "YYYY")
    public static let peogooLongDateAndTimeIdentifier = DateFormatter(dateFormat: "h:mm:ssEEEMMMdyyyy")
    public static let peogooWeekday = DateFormatter(dateFormat: "EEEE")
}

extension Date {
    public func formatted(using formatter: DateFormatter) -> String {
        return formatter.string(from: self)
    }
    
    /// A short timeless date format, e.g. 07:23:23.
    public func cabinetTimeDateFormatted() -> String {
        return formatted(using: .cabinetTimeDateFormatter)
    }

    /// A short timeless date format, e.g. 2020 12 22.
    public func cabinetShortTimelessDateFormatted() -> String {
        return formatted(using: .cabinetShortTimelessDateFormatter)
    }

    public func peogooMidumDateAndTimeFormatter() -> String {
        return formatted(using: .peogooMidumDateAndTimeFormatter)
    }

    /// A short timeless date format without the year, e.g. 01-31.
    public func peogooShortTimelessDateFormattedExcludingYear() -> String {
        return formatted(using: .peogooShortTimelessDateFormatterExcludingYear)
    }

    /// A short date and time format, e.g. 01/31/17 3:52 PM.
    public func peogooShortDateAndTimeFormatted() -> String {
        return formatted(using: .peogooShortDateAndTimeFormatter)
    }

    /// A short time format, e.g. 3:52 PM.
    public func peogooShortDatelessTimeFormatted() -> String {
        return formatted(using: .peogooShortDatelessTimeFormatter)
    }

    /// A medium timeless date format, e.g. Jan 31, 2017.
    public func peogooMediumTimelessDateFormatted() -> String {
        return formatted(using: .peogooMediumTimelessDateFormatter)
    }

    /// A medium timeless date format without the day, e.g. Jan 2017.
    public func peogooMediumTimelessDateFormattedExcludingDay() -> String {
        return formatted(using: .peogooMediumTimelessDateFormatterExcludingDay)
    }

    public func peogooMediumTimelessDateFormattedExcludingYear() -> String {
        return formatted(using: .peogooMediumTimelessDateFormatterExcludingYear)
    }

    /// A medium date and time format, e.g. Jan 31, 2017 3:52 PM.
    public func peogooMediumDateAndTimeFormatted() -> String {
        return formatted(using: .peogooMediumDateAndTimeFormatter)
    }

    /// A long date and time format, seconds included. Used as a human-friendly identifier string
    public func peogooLongDateAndTimeIdentifier() -> String {
        return formatted(using: .peogooLongDateAndTimeIdentifier)
    }

    public enum AutoFormatStyle { case dateOrTime, dateAndTime, timeExcludingDateIfImplicit, timelessDate }


}
