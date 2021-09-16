// Copyright © 2021 evan. All rights reserved.

struct CurrentWeather : Codable, Identifiable {
    let id: Int
    let now: Now
    var address: String
    struct Now : Codable, Identifiable {
        let id: Int
        let obsTime: String // 数据观测时间
        let temp: String // 温度，默认单位：摄氏度
        let feelsLike: String // 体感温度，默认单位：摄氏度
        let icon: String // 天气状况和图标的代码，图标可通过天气状况和图标下载
        let text: String // 天气状况的文字描述，包括阴晴雨雪等天气状态的描述
        let wind360: String // 风向360角度
        let windDir: String // 风向
        let windScale: String // 风力等级
        let windSpeed: String // 风速，公里/小时
        let humidity: String // 相对湿度，百分比数值
        let precip: String // 当前小时累计降水量，默认单位：毫米
        let pressure: String // 大气压强，默认单位：百帕
        let vis: String // 能见度，默认单位：公里
        let cloud: String // 云量，百分比数值
        let dew: String // 露点温度
    }
}
