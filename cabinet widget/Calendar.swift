// Copyright © 2021 evan. All rights reserved.

import Foundation
import WidgetKit

struct CalendarModel : TimelineEntry {
    var date: Date
    var currentWeather: CurrentWeather?
}

extension CalendarModel {
    static var currentDate: CalendarModel {
        return CalendarModel(date: Date(), currentWeather: nil)
    }
}
