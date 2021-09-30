// Copyright © 2021 evan. All rights reserved.

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> InspireEntry {
        InspireEntry(date: Date(), daily: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (InspireEntry) -> ()) {
        let entry = InspireEntry(date: Date(), daily: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        /// widget will be refresh every minute
        let refreshTime = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!

        WidgetServer.getDailyReport { result in
            var daily: DailyModel?
            if case .success(let value) = result {
                daily = value
            } else {
                daily = nil
            }
            let data = UserDefaults.shared[.dailyBackground]
            let foreground = UserDefaults.shared[.dailyForeground]
            var entry = InspireEntry(date: Date(), daily: daily)
            var theme = Theme()
            if let data = data, let image = UIImage(data: data) {
                theme.image = image
            }
            if let data = data, let background = String(data: data, encoding: .utf8) {
                theme.background = background
            }
            if let data = foreground, let foreground = String(data: data, encoding: .utf8) {
                theme.foreground = foreground
            }
            entry.theme = theme
            let timeline = Timeline(entries: [entry], policy: .after(refreshTime))
            completion(timeline)
        }
    }
}

struct InspireWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        InspireView(entry: entry)
    }
}

@main
struct InspireWidget: Widget {
    let kind: String = "InspireWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            InspireWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Inspired")
        .description("Hope it is nice where you are.")
        .supportedFamilies([ .systemMedium ])
    }
}
