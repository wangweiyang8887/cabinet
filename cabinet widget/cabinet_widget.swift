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

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 60 {
            let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset, to: currentDate)!
            let entry = CalendarModel(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct cabinet_widgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            CalendarView(calendar: entry)
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
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct cabinet_widget_Previews: PreviewProvider {
    static var previews: some View {
        cabinet_widgetEntryView(entry: CalendarModel(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
