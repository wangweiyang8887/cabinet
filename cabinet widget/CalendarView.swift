// Copyright © 2021 evan. All rights reserved.

import SwiftUI

struct CalendarView: View {
    var calendar: CalendarModel
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack {
                    Text(calendar.date.cabinetWeedayFomatted())
                        .foregroundColor(Color(UIColor.nonStandardColor(withRGBHex: 0x913BAE)))
                    Text(calendar.date.cabinetShortTimelessDateFormatted())
                        .font(.headline)
                }
                Spacer()
                Text("🌞")
            }
            Spacer(minLength: 8)
            HStack {
                Text("宜")
                    .foregroundColor(.red)
                Text(calendar.goodThings)
                    .font(.headline)
                Spacer()
            }
            HStack {
                Text("忌")
                    .foregroundColor(.green)
                Text(calendar.badThings)
                    .font(.headline)
                Spacer()
            }
            Spacer()
            HStack {
                Text("幸运数字")
                    .font(.subheadline)
                    .foregroundColor(Color(UIColor.nonStandardColor(withRGBHex: 0x53D9AE)))
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
