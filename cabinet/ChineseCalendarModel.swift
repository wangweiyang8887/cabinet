// Copyright © 2021 evan. All rights reserved.

struct ChineseCalendarModel : Codable {
    let id: String
    let yangli: String
    let yinli: String
    let wuxing: String
    let chongsha: String
    let baiji: String
    let jishen: String
    let yi: String
    let xiongshen: String
    let ji: String
    /*
     "id":"4146",
     "yangli":"2021-09-23",
     "yinli":"辛丑(牛)年八月十七",
     "wuxing":"大溪水 执执位",
     "chongsha":"冲猴(戊申)煞北",
     "baiji":"甲不开仓财物耗散 寅不祭祀神鬼不尝",
     "jishen":"月空 解神 五合 青龙 鸣犬对",
     "yi":"沐浴 捕捉 入殓 除服 成服 破土 启钻 安葬",
     "xiongshen":"劫煞 小耗 四废 归忌 八专",
     "ji":"祭祀 嫁娶 安床 开市 入宅 探病 上梁"
     */
}

extension ChineseCalendarModel {
    var todayYI: String {
        return self.yi.components(separatedBy: .whitespaces).prefix(3).joined(separator: " ")
    }
    
    var todayJI: String {
        return self.ji.components(separatedBy: .whitespaces).prefix(3).joined(separator: " ")
    }
}

extension Server {
    static func fetchChieseCalendar(by date: String) -> Operation<ChineseCalendarModel> {
        return Server.fire(.get, .huangli, parameters: [ "date":date, "key":"09e77234067022f7fbaf12d1f266dc1b" ])
    }
}
