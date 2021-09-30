// Copyright © 2021 evan. All rights reserved.

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DailyEntry {
        DailyEntry(date: Date(), daily: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyEntry) -> ()) {
        let entry = DailyEntry(date: Date(), daily: nil)
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
            let data = UserDefaults.shared[.calendarBackground]
            let foreground = UserDefaults.shared[.calendarForeground]
            var entry = DailyEntry(date: Date(), daily: daily)
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

struct DailyWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        DailyView(entry: entry)
    }
}

@main
struct DailyWidget: Widget {
    let kind: String = "DailyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("老黄历")
        .description("一个简单的日历组建")
        .supportedFamilies([ .systemMedium ])
    }
}
