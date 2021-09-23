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
        
        /// widget will be refresh every minute
        let refreshTime = Calendar.current.date(byAdding: .second, value: 1, to: currentDate)!
        let entry = LotteryEntry(date: Date(), models: [])
        let timeline = Timeline(entries: [entry], policy: .after(refreshTime))
        completion(timeline)

        getLottery(with: "ssq") { result in
            var models: [LotteryModel] = []
            if case .success(let value) = result {
                models.append(value)
            }
            getLottery(with: "dlt") { dlt in
                if case .success(let value) = dlt {
                    models.append(value)
                }
                let entry = LotteryEntry(date: Date(), models: models)
                let timeline = Timeline(entries: [entry], policy: .after(refreshTime))
                completion(timeline)
            }
        }
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
            completion(.success(LotteryResult.decode(from: data!)!.result))
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
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([ .systemMedium ])
    }
}
