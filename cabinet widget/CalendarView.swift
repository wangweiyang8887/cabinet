// Copyright © 2021 evan. All rights reserved.

import SwiftUI

struct CalendarView: View {
    var calendar: CalendarModel
    
    var body: some View {
        ZStack {
            DateView(calendar: calendar)
                .background(LinearGradient(gradient: Gradient(colors: [ Color(UIColor.nonStandardColor(withRGBHex: 0xABDCFF)), Color(UIColor.nonStandardColor(withRGBHex: 0x0396FF)) ]), startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}

private struct DateView : View {
    var calendar: CalendarModel
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack {
                    Text(calendar.date.cabinetWeedayFomatted())
                        .foregroundColor(Color(UIColor.nonStandardColor(withRGBHex: 0x623AA2)))
                        .font(.system(size: 17, weight: .medium))
                    Text(calendar.date.cabinetShortTimelessDateFormatted())
                        .foregroundColor(Color(UIColor.nonStandardColor(withRGBHex: 0xF8F8F8)))
                        .font(.system(size: 17, weight: .medium))
                }
                Spacer()
                Text("🌞")
            }
            Spacer(minLength: 8)
            HStack {
                Text("宜")
                    .foregroundColor(Color(UIColor.nonStandardColor(withRGBHex: 0xFF2442)))
                Text(calendar.goodThings)
                    .foregroundColor(Color(UIColor.nonStandardColor(withRGBHex: 0xF8F8F8)))
                    .font(.system(size: 17, weight: .medium))
                Spacer()
            }
            HStack {
                Text("忌")
                    .foregroundColor(Color(UIColor.nonStandardColor(withRGBHex: 0x368B85)))
                Text(calendar.badThings)
                    .foregroundColor(Color(UIColor.nonStandardColor(withRGBHex: 0xF8F8F8)))
                    .font(.system(size: 17, weight: .medium))
                Spacer()
            }
            Spacer()
            HStack {
                Text("幸运数字 ")
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.nonStandardColor(withRGBHex: 0x333333)))
                Text("七")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
                Spacer()
            }
            Spacer()
        }
        .padding()
    }
}
