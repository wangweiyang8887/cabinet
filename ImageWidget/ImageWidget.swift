// Copyright © 2021 evan. All rights reserved.

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), image: UIImage(named: "taylor")!)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), image: UIImage(named: "taylor")!)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let image: UIImage = {
            if let data = UserDefaults.shared[.userImage], let image = UIImage(data: data) {
                return image
            } else {
                return UIImage(named: "taylor")!
            }
        }()
        let entry = SimpleEntry(date: Date(), image: image)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let image: UIImage
}

@main
struct ImageWidget: Widget {
    let kind: String = "ImageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ImageEntryView(entry: entry)
        }
        .configurationDisplayName("自定义图片")
        .description("选择你喜欢的图片展示到桌面.")
    }
}

struct ImageWidget_Previews: PreviewProvider {
    static var previews: some View {
        ImageEntryView(entry: SimpleEntry(date: Date(), image: UIImage(named: "taylor")!))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
