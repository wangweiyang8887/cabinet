// Copyright © 2021 evan. All rights reserved.

import WidgetKit
import UIKit

struct DailyEntry : TimelineEntry {
    let date: Date
    let daily: DailyModel?
    var theme: Theme?
}

struct Theme {
    var foreground: String?
    var background: String?
    var image: UIImage?
}
