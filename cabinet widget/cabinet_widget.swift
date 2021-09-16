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
        var entries: [CalendarModel] = []
        let currentDate = Date()
        
        /// widget will be refresh every minute
        
        let refreshTime = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        
        for hoursOffset in 0..<24 {
            
            guard let entryDate = Calendar.current.date(byAdding: .hour, value: hoursOffset, to: currentDate) else {
                return
            }
            let entry = CalendarModel(date: entryDate, currentWeather: nil)
            entries.append(entry)
        }
        WidgetServer.getWeather { result in
            var currentWeather: CurrentWeather?
            if case .success(let value) = result {
                currentWeather = value
                currentWeather?.address = UserDefaults.shared[.userAddress] ?? ""
            } else {
                currentWeather = nil
            }
            let entry = CalendarModel(date: Date(), currentWeather: currentWeather)
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
        .configurationDisplayName("Cabinet Widget")
        .description("This is your widget.")
    }
}

struct cabinet_widget_Previews: PreviewProvider {
    static var previews: some View {
        cabinet_widgetEntryView(entry: CalendarModel(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
