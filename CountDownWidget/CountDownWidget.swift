// Copyright © 2021 evan. All rights reserved.

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CountDownEntry {
        CountDownEntry(date: Date(), model: EventModel())
    }

    func getSnapshot(in context: Context, completion: @escaping (CountDownEntry) -> ()) {
        let entry = CountDownEntry(date: Date(), model: EventModel())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let refreshTime = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        
        let name = UserDefaults.shared[.eventName]
        let eventDate = UserDefaults.shared[.eventDate]
        let data = UserDefaults.shared[.eventBackground]
        let foreground = UserDefaults.shared[.eventForeground]
        DispatchQueue.main.async {
            var model = EventModel(name: name, date: eventDate)
            if let data = data {
                if let hex = String(data: data, encoding: .utf8) {
                    model.hex = hex
                } else if let image = UIImage(data: data) {
                    model.image = image
                }
            }
            if let data = foreground, let hex = String(data: data, encoding: .utf8) {
                model.foreground = hex
            }
            let entry = CountDownEntry(date: Date(), model: model)
            let timeline = Timeline(entries: [entry], policy: .after(refreshTime))
            completion(timeline)
        }
    }
}

struct CountDownWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        CountDownView(entry: entry)
    }
}

@main
struct CountDownWidget: Widget {
    let kind: String = "CountDownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CountDownWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("倒数日")
        .description("选择一个过去或者现在的日期 - -")
        .supportedFamilies([ .systemSmall ])
    }
}
