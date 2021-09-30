// Copyright © 2021 evan. All rights reserved.

import SwiftUI

struct DailyView: View {
    var entry: DailyEntry
    
    var contentView: some View {
        ZStack {
            HStack {
                DailyLeftView(daily: entry.daily)
                DailyRightView(daily: entry.daily)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(getForegroundColor())
    }
    
    var body: some View {
        if let image = entry.theme?.image {
            contentView
                .background(
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                )
        } else if let hex = entry.theme?.background {
            contentView
                .background(LinearGradient(gradient: Gradient(colors: hex.components(separatedBy: .whitespaces).map { Color(UIColor(hex: $0)) }), startPoint: .leading, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/))
        } else {
            contentView
                .background(LinearGradient(gradient: Gradient(colors: [ Color(UIColor.darkBlue), Color(UIColor.cabinetJava) ]), startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
    
    private func getForegroundColor() -> Color {
        if let hex = entry.theme?.foreground {
            return Color(UIColor(hex: hex))
        } else {
            return .white
        }
    }
}

private struct DailyLeftView : View {
    var daily: DailyModel?
    var body: some View {
        VStack(spacing: 12) {
            Text(daily?.constellation ?? "-")
                .font(.system(size: 15, weight: .medium))
            Text("\(CalendarDate.today(in: .current).day)")
                .font(.system(size: 42, weight: .semibold))
            VStack {
                Text("\(Calendar.currentMonth) \(Calendar.currentWeek)")
                    .font(.system(size: 13))
                Text("\(Calendar.lunarYear) \(Calendar.lunarMonthAndDay)")
                    .font(.system(size: 13))
            }
        }
        .padding(.leading, 24)
        .padding(.top, 16)
        .padding(.trailing, 8)
        .padding(.bottom, 16)
    }

}

private struct DailyRightView : View {
    var daily: DailyModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 8) {
                Text("宜")
                    .font(.system(size: 27, weight: .bold))
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(lineWidth: 1)
                    )
                Text(UserDefaults.shared[.todayYI] ?? "诸事不宜")
                    .font(.system(size: 15, weight: .medium))
            }
            HStack(alignment: .center, spacing: 8) {
                Text("忌")
                    .font(.system(size: 27, weight: .bold))
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(lineWidth: 1)
                    )
                Text(UserDefaults.shared[.todayJI] ?? "-")
                    .font(.system(size: 15, weight: .medium))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(8)
    }
}
