// Copyright © 2021 evan. All rights reserved.

struct CurrentWeather : Decodable {
    let id: String
    let city: String
    let update_time: String
    let date: String
    let list: [List]

    struct List : Decodable {
        let date: String
        let weather: String
        let icon1: String
        let icon2: String
        let temp: String
        let w: String
        let wind: String
    }
}
