// Copyright © 2021 evan. All rights reserved.

import SwiftUI

struct CalendarView: View {
    var calendar: CalendarModel
    
    var body: some View {
        ZStack {
            if let image = calendar.theme?.image {
                WeatherView(calendar: calendar)
                    .background(
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    )
            } else if let hex = calendar.theme?.hex {
                WeatherView(calendar: calendar)
                    .background(LinearGradient(gradient: Gradient(colors: hex.components(separatedBy: .whitespaces).map { Color(UIColor(hex: $0)) }), startPoint: .leading, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/))
            } else {
                WeatherView(calendar: calendar)
                    .background(LinearGradient(gradient: Gradient(colors: [ Color(UIColor.cabinetYellow), Color(UIColor.cabinetRed) ]), startPoint: .topLeading, endPoint: .bottomTrailing))
            }
        }
    }
}

private struct WeatherView : View {
    var calendar: CalendarModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .renderingMode(.template)
                Text(calendar.currentWeather?.address ?? "北京")
                    .font(.system(size: 15, weight: .medium))
                Spacer()
                Text(calendar.currentWeather?.now.text ?? "晴")
                    .font(.system(size: 15, weight: .medium))
            }
            HStack {
                WeatherIconView(icon: calendar.currentWeather?.now.icon)
                Spacer()
                Text(given(calendar.currentWeather?.now.temp) { $0 + "°C"} ?? "27°C")
                    .font(.system(size: 24, weight: .bold))
            }
            Spacer()
            HStack {
                Text(given(calendar.currentWeather?.now.windDir, calendar.currentWeather?.now.windScale) { $0 + " " + $1 + "级" } ?? "东南风3级" )
                    .font(.system(size: 15, weight: .medium))
                Spacer()
            }
        }
        .foregroundColor(getForegroundColor())
        .padding(16)
    }
    
    private func getForegroundColor() -> Color {
        if let hex = calendar.theme?.foreground {
            return Color(UIColor(hex: hex))
        } else {
            return .white
        }
    }
}

private struct WeatherIconView : View {
    var icon: String?
    
    var body: some View {
        if let icon = icon, !icon.isEmpty {
            Image(uiImage: UIImage(named: icon)!)
                .renderingMode(.template)
                .resizable()
                .frame(width: 36, height: 36, alignment: .center)
        } else {
            Image(systemName: "cloud.sun.fill")
                .renderingMode(.template)
                .resizable()
                .frame(width: 36, height: 36, alignment: .center)
        }
    }
}
