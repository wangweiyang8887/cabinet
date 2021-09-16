// Copyright © 2021 evan. All rights reserved.

import WidgetKit

struct CountDownEntry : TimelineEntry {
    let date: Date
    let model: EventModel
}

struct EventModel {
    var name: String?
    var date: String?
}
