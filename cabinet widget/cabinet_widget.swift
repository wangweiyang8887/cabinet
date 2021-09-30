// Copyright © 2021 evan. All rights reserved.

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarModel {
        CalendarModel(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarModel) -> ()) {
        let entry = CalendarModel(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let refreshTime = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        
        WidgetServer.getWeather { result in
            var currentWeather: CurrentWeather?
            if case .success(let value) = result {
                currentWeather = value
                currentWeather?.address = UserDefaults.shared[.userAddress] ?? ""
            } else {
                currentWeather = nil
            }
            var entry = CalendarModel(date: Date(), currentWeather: currentWeather)
            var theme = Theme()
            let data = UserDefaults.shared[.weatherBackground]
            let foreground = UserDefaults.shared[.weatherForeground]
            if let data = data {
                if let hex = String(data: data, encoding: .utf8) {
                    theme.hex = hex
                } else if let image = UIImage(data: data) {
                    theme.image = image
                }
            }
            if let data = foreground, let hex = String(data: data, encoding: .utf8) {
                theme.foreground = hex
            }
            entry.theme = theme
            let timeline = Timeline(entries: [entry], policy: .after(refreshTime))
            completion(timeline)
        }
    }
}

struct cabinet_widgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall: CalendarView(calendar: entry)
        default: Text("")
        }
    }
}

@main
struct cabinet_widget: Widget {
    let kind: String = "cabinet_widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            cabinet_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("天气☀️")
        .description("希望每天都是好天气.")
        .supportedFamilies([ .systemSmall ])
    }
}

struct cabinet_widget_Previews: PreviewProvider {
    static var previews: some View {
        cabinet_widgetEntryView(entry: CalendarModel(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
