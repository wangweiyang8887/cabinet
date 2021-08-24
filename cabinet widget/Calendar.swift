// Copyright © 2021 evan. All rights reserved.

import Foundation
import WidgetKit

struct CalendarModel : TimelineEntry {
    var date: Date
    var goodThings: String = "结婚 搬家"
    var badThings: String = "开光 针灸"
}

extension CalendarModel {
    static var currentDate: CalendarModel {
        return CalendarModel(date: Date(), goodThings: "Goods", badThings: "Bad")
    }
}
