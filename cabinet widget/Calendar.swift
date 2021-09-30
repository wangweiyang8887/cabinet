// Copyright © 2021 evan. All rights reserved.

import Foundation
import WidgetKit
import UIKit

struct CalendarModel : TimelineEntry {
    var date: Date
    var currentWeather: CurrentWeather?
    var theme: Theme?
}

extension CalendarModel {
    static var currentDate: CalendarModel {
        return CalendarModel(date: Date(), currentWeather: nil)
    }
}

struct Theme {
    var hex: String?
    var image: UIImage?
    var foreground: String?
}
