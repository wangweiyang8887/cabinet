// Copyright © 2021 evan. All rights reserved.

import WidgetKit
import UIKit

struct LotteryEntry : TimelineEntry {
    var date: Date
    let models: [LotteryModel]
    var theme: Theme?
}

struct LotteryResult : Codable {
    var result: LotteryModel
}

struct Theme {
    var background: String?
    var image: UIImage?
}
