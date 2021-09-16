// Copyright © 2021 evan. All rights reserved.

import SwiftUI

struct DailyView: View {
    var body: some View {
        ZStack {
            HStack {
                DailyLeftView()
                DailyRightView()
                Spacer()
            }
        }
        .foregroundColor(.white)
        .background(LinearGradient(gradient: Gradient(colors: [ Color(UIColor.darkBlue), Color(UIColor.cabinetJava) ]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

private struct DailyLeftView : View {
    var body: some View {
        VStack(spacing: 12) {
            Text("狮子座")
                .font(.system(size: 15, weight: .medium))
            Text("16")
                .font(.system(size: 42, weight: .semibold))
            VStack {
                Text("九月 星期四")
                    .font(.system(size: 13))
                Text("辛丑年 八月初八")
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
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 8) {
                Text("宜")
                    .font(.system(size: 27, weight: .bold))
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.white, lineWidth: 1)
                    )
                Text("结婚 会亲友")
                    .font(.system(size: 15, weight: .medium))
            }
            HStack(alignment: .center, spacing: 8) {
                Text("忌")
                    .font(.system(size: 27, weight: .bold))
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.white, lineWidth: 1)
                    )
                Text("-")
                    .font(.system(size: 15, weight: .medium))
            }
        }
        .padding(8)
    }
}

struct DailyView_Previews: PreviewProvider {
    static var previews: some View {
        DailyView()
    }
}
