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
                }
                Spacer()
                Text("🌞")
            }
            Spacer()
            Text(calendar.date.cabinetTimeShortDateFormatted())
            Spacer()
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [ .orange, .green ]), startPoint: .leading, endPoint: .trailing))
    }
}
