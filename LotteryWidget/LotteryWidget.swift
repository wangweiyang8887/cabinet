// Copyright © 2021 evan. All rights reserved.

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> LotteryEntry {
        LotteryEntry(date: Date(), models: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (LotteryEntry) -> ()) {
        let entry = LotteryEntry(date: Date(), models: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        
        /// widget will be refresh every hour
        let refreshTime = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!

        getLottery(with: "ssq") { result in
            var models: [LotteryModel] = []
            if case .success(let value) = result {
                models.append(value)
                getLottery(with: "dlt") { dlt in
                    if case .success(let value) = dlt {
                        models.append(value)
                    }
                    let entry = LotteryEntry(date: Date(), models: models)
                    let timeline = Timeline(entries: [entry], policy: .after(refreshTime))
                    completion(timeline)
                }
            } else {
                getDailyReport { result in
                    var daily: DailyModel?
                    if case .success(let value) = result {
                        daily = value
                    } else {
                        daily = nil
                    }
                    let entry = LotteryEntry(date: Date(), models: daily?.lottery ?? [])
                    let timeline = Timeline(entries: [entry], policy: .after(refreshTime))
                    completion(timeline)
                }
            }
        }
    }
    
    func getDailyReport(completion: @escaping (Result<DailyModel?, Error>) -> Void) {
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
    
    func getLottery(with id: String, completion: @escaping (Result<LotteryModel, Error>) -> Void) {
        let parameters = [ "lottery_id":id, "lottery_no":"", "key":"f7359c92478f397e465867fc24a550a2" ]
        let urlstring = API.lottery.rawValue.combinedUrlIfNeeded(with: parameters)
        let url = URL(string: urlstring)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            if let result = LotteryResult.decode(from: data!)?.result, result.lottery_id.trimmedNilIfEmpty != nil {
                completion(.success(result))
            } else {
                completion(.failure(NSError()))
            }
        }
        task.resume()
    }
}

extension String {
    func combinedUrlIfNeeded(with parameters: [String:Any]) -> String {
        let result = parameters.map { return $0 + "=" + "\($1)" + "&" }.joined().dropLast()
        return result.isEmpty ? self : self + "?" + result
    }
}

@main
struct LotteryWidget: Widget {
    let kind: String = "LotteryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LotteryView(entry: entry)
        }
        .configurationDisplayName("彩票")
        .description("祝你中大奖🎉🎉🎉")
        .supportedFamilies([ .systemMedium ])
    }
}
