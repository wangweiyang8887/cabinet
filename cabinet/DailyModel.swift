// Copyright © 2021 evan. All rights reserved.

struct DailyModel : Decodable {
    let constellation: String // 星座
    let lunar: String // 农历
    let red: [String] // 宜
    let green: [String] // 忌
    let daily: [String] // 每日一句 中文
    let sentence: [String] // 每日一句 英文
}

extension DailyModel {
    var monthAndWeek: String? {
        return lunar.components(separatedBy: .whitespaces).dropLast().joined(separator: " ")
    }
    
    var lunarDate: String? {
        return lunar.components(separatedBy: .whitespaces).last
    }
    
    var todayRed: String? {
        var random: Int = Int.random(in: 0..<red.count)
        if random == 0 { return red.first }
        if random == 1 { return red[ifPresent: random] }
        var value: String = red[ifPresent: random] ?? ""
        random = Int.random(in: 2..<red.count)
        value = value + " " + (red[ifPresent: random] ?? "")
        return value
    }
    
    var todayGreen: String? {
        var random: Int = Int.random(in: 0..<green.count)
        if random == 0 { return green.first }
        if random == 1 { return green[ifPresent: random] }
        var value: String = green[ifPresent: random] ?? ""
        random = Int.random(in: 2..<green.count)
        value = value + " " + (green[ifPresent: random] ?? "")
        return value
    }
}
