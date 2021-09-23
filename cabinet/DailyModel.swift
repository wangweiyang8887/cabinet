// Copyright © 2021 evan. All rights reserved.

class DailyModel : Codable {
    let constellation: String // 星座
    let lunar: String // 农历
    var red: [String] // 宜
    var green: [String] // 忌
    var daily: [String] // 每日一句 中文
    var sentence: [String] // 每日一句 英文
    var lottery: [LotteryModel]
}

extension DailyModel {
    var monthAndWeek: String? {
        return lunar.components(separatedBy: .whitespaces).dropLast().joined(separator: " ")
    }
    
    var lunarDate: String? {
        return lunar.components(separatedBy: .whitespaces).last
    }
    
    var todayRed: String? {
        print(red)
        if red.last == "诸事不宜" || red.last == "-" {
            return red.last
        }
        let result = red.filter { $0 != "诸事不宜" && $0 != "-" }
        return result.prefix(2).joined(separator: " ")
  
    }
    
    var todayGreen: String? {
        if green.last == "诸事不宜" || green.last == "-" {
            return green.last
        }
        let result = green.filter { $0 != "诸事不宜" && $0 != "-" }
        return result.prefix(2).joined(separator: " ")
    }
}
