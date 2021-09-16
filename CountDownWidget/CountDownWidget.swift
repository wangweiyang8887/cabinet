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
        var entries: [CountDownEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let name = UserDefaults.shared[.eventName]
            let eventDate = UserDefaults.shared[.eventDate]
            let model = EventModel(name: name, date: eventDate)
            let entry = CountDownEntry(date: entryDate, model: model)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
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
