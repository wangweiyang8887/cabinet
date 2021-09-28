// Copyright © 2021 evan. All rights reserved.

import WidgetKit

struct LotteryEntry : TimelineEntry {
    var date: Date
    let models: [LotteryModel]
}

struct LotteryResult : Codable {
    var result: LotteryModel
}
