// Copyright © 2021 evan. All rights reserved.

import SwiftUI

struct LotteryView: View {
    enum Kind { case ssq, dlt }
    
    var entry: LotteryEntry
    
    var body: some View {
        ZStack {
            VStack(spacing: 8) {
                ResultView(kind: .ssq, model: entry.models.first)
                ResultView(kind: .dlt, model: entry.models.last)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.all, 16)
            .foregroundColor(.white)
            .background(LinearGradient(gradient: Gradient(colors: [ Color(UIColor.cabinetRoseRed.withAlphaComponent(0.3)), Color(UIColor.cabinetPureBlue.withAlphaComponent(0.4)) ]), startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .background(Color.white)
    }
}

private struct ResultView : View {
    var kind: LotteryView.Kind
    var model: LotteryModel?
    
    var body: some View {
            VStack {
                HStack(alignment: .center, spacing: 4) {
                    makeText(kind == .ssq ? "双色球" : "大乐透", size: 12, weight: .regular)
                    makeText(model?.lottery_no ?? "-", size: 13, weight: .medium)
                    makeText("期", size: 12, weight: .regular)
                    Spacer()
                    makeText("开奖日期", size: 12, weight: .regular)
                    makeText(model?.lottery_date ?? "-", size: 13, weight: .medium)
                }
                Spacer()
                HStack {
                    makeText((kind == .ssq ? model?.ssqRedBall : model?.dltRedBall) ?? "-", size: 27, weight: .bold)
                        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.2), radius: 2, x: 1, y: 2)
                    makeText((kind == .ssq ? model?.ssqBlueBall : model?.dltBlueBallOne) ?? "", size: 27, weight: .bold)
                        .foregroundColor(Color(UIColor.nonStandardColor(withRGBHex: 0xEBB11C)))
                        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.2), radius: 2, x: 1, y: 2)
                    if kind == .dlt {
                        makeText(model?.dltBlueBallTwo ?? "", size: 27, weight: .bold)
                            .foregroundColor(Color(UIColor.nonStandardColor(withRGBHex: 0xEBB11C)))
                            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.2), radius: 2, x: 1, y: 2)
                    }
                    Spacer()
                }
            }
    }
    
    private func makeText(_ text: String, size: CGFloat, weight: Font.Weight) -> Text {
        Text(text)
            .font(.system(size: size, weight: weight))
    }
}
