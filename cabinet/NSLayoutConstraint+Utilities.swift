// Copyright © 2021 evan. All rights reserved.

import UIKit

extension NSLayoutConstraint {
    @discardableResult public func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

extension UILayoutPriority {
    public static var pseudoRequired: UILayoutPriority { return UILayoutPriority(rawValue: 999) }
    public static var lowCompressionResistance: UILayoutPriority { return UILayoutPriority(rawValue: 740) }
    public static var defaultCompressionResistance: UILayoutPriority { return UILayoutPriority(rawValue: 750) }
    public static var highCompressionResistance: UILayoutPriority { return UILayoutPriority(rawValue: 760) }
    public static var medium: UILayoutPriority { return UILayoutPriority(rawValue: 500) }
    public static var lowHuggingPriority: UILayoutPriority { return UILayoutPriority(rawValue: 240) }
    public static var defaultHuggingPriority: UILayoutPriority { return UILayoutPriority(rawValue: 250) }
    public static var highHuggingPriority: UILayoutPriority { return UILayoutPriority(rawValue: 260) }
}
