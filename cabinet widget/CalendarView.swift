// Copyright © 2021 evan. All rights reserved.

import SwiftUI

struct CalendarView: View {
    var calendar: CalendarModel
    
    var body: some View {
        ZStack {
            WeatherView(weather: calendar.currentWeather)
                .background(LinearGradient(gradient: Gradient(colors: [ Color(UIColor.cabinetYellow), Color(UIColor.cabinetRed) ]), startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}

private struct WeatherView : View {
    var weather: CurrentWeather?
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .renderingMode(.template)
                Text(weather?.address ?? "北京")
                    .font(.system(size: 15, weight: .medium))
                Spacer()
                Text(weather?.now.text ?? "晴")
                    .font(.system(size: 15, weight: .medium))
            }
            HStack {
                WeatherIconView(icon: weather?.now.icon)
                Spacer()
                Text(given(weather?.now.temp) { $0 + "°C"} ?? "27°C")
                    .font(.system(size: 24, weight: .bold))
            }
            Spacer()
            HStack {
                Text(given(weather?.now.windDir, weather?.now.windScale) { $0 + " " + $1 + "级" } ?? "东南风3级" )
                    .font(.system(size: 15, weight: .medium))
                Spacer()
            }
        }
        .foregroundColor(.white)
        .padding(16)
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
