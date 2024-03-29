// Copyright © 2021 evan. All rights reserved.

import SwiftUI
import UIKit

struct CountDownView: View {
    var entry: CountDownEntry
    
    var body: some View {
        if let image = entry.model.image {
            HStack {
                ContentView(model: entry.model)
            }
            .background(
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            )
        } else if let hex = entry.model.hex {
            HStack {
                ContentView(model: entry.model)
            }
            .background(LinearGradient(gradient: Gradient(colors: hex.components(separatedBy: .whitespaces).map { Color(UIColor(hex: $0)) }), startPoint: .leading, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/))
        } else {
            HStack {
                ContentView(model: entry.model)
            }
            .background(LinearGradient(gradient: Gradient(colors: [ Color(UIColor.cabinetHeliotrope), Color(UIColor.cabinetCerulean) ]), startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}

private struct ContentView : View {
    var model: EventModel
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(model.name ?? "春节")
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
            }
            Spacer(minLength: 12)
            HStack(alignment: .center) {
                DayText(text: "  \(getDay())")
                VStack(alignment: .leading) {
                    Text("天\n")
                        .font(.system(size: 11, weight: .medium))
                        .lineLimit(nil)
                }
            }
            Spacer()
            Text(model.date ?? "2022.02.01")
                .font(.system(size: 15, weight: .medium))
        }
        .foregroundColor(getForegroundColor())
        .padding(16)
    }
    
    private func getDay() -> String {
        guard let dateString = model.date else { return "1" }
        guard let date = DateFormatter(dateFormat: "YYYY.MM.dd").date(from: dateString) else { return "1" }
        let date1 = CalendarDate.today(in: .current)
        let date2 = CalendarDate(date: date, timeZone: .current)
        let distant = CalendarDate.component(.day, from: date1, to: date2)
        return "\(abs(distant))"
    }
    
    private func getForegroundColor() -> Color {
        if let hex = model.foreground {
            return Color(UIColor(hex: hex))
        } else {
            return .white
        }
    }
}

struct DayText : View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: getSize(), weight: .heavy))
    }
    
    private func getSize() -> CGFloat {
        let text = text.trimmingCharacters(in: .whitespaces)
        if text.count > 3 { return 32.0 }
        if text.count == 3 { return 44 }
        if text.count == 2 { return 48 }
        if text.count == 1 { return 48 }
        return 24
    }
}

extension Text {
    init(attributedString: NSAttributedString) {
        self.init(attributedString.string)
    }
}
