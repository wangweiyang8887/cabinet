// Copyright © 2021 evan. All rights reserved.

import Foundation
import WidgetKit

struct CalendarModel : TimelineEntry {
    var date: Date
    var goodThings: String
    var badThings: String
}

extension CalendarModel {
    static var currentDate: CalendarModel {
        return CalendarModel(date: Date(), goodThings: "Goods", badThings: "Bad")
    }
}
