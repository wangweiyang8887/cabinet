// Copyright © 2021 evan. All rights reserved.

import UIKit

struct WidgetServer {
    static func getWeather(completion: @escaping (Result<CurrentWeather?, Error>) -> Void) {
        let coodinate = UserDefaults.shared[.userCoordinate] ?? ""
        let key = "2e977cafcd7243019922c2e87d1b5e28"
        let parameters = [ "location":coodinate, "key":key ]
        let urlstring = API.weather.rawValue.combinedUrlIfNeeded(with: parameters)
        let url = URL(string: urlstring)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            let result = weatherFromJson(fromData: data!)
            completion(.success(result))
        }
        task.resume()
    }
    
    static func weatherFromJson(fromData data:Data) -> CurrentWeather? {
        return CurrentWeather.decode(from: data)
    }
    
    static func getDailyReport(completion: @escaping (Result<DailyModel?, Error>) -> Void) {
        let url = URL(string: API.daily.rawValue)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            completion(.success(DailyModel.decode(from: data!)))
        }
        task.resume()
    }
}

extension String {
    public func combinedUrlIfNeeded(with parameters: [String:Any]) -> String {
        let result = parameters.map { return $0 + "=" + "\($1)" + "&" }.joined().dropLast()
        return result.isEmpty ? self : self + "?" + result
    }
}
