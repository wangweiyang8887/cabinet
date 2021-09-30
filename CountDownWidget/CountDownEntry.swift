// Copyright © 2021 evan. All rights reserved.

import WidgetKit
import UIKit

struct CountDownEntry : TimelineEntry {
    let date: Date
    let model: EventModel
}

struct EventModel {
    var name: String?
    var date: String?
    var hex: String?
    var image: UIImage?
    var foreground: String?
}
