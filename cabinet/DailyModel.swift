// Copyright © 2021 evan. All rights reserved.

struct DailyModel : Decodable {
    let constellation: String // 星座
    let lunar: String // 农历
    let red: String // 宜
    let green: String // 忌
    let daily: [String] // 每日一句 中文
    let sentence: [String] // 每日一句 英文
}
