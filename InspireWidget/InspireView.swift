// Copyright © 2021 evan. All rights reserved.

import SwiftUI
import Foundation

struct InspireView: View {
    var entry: InspireEntry
    
    var contentView: some View {
        VStack {
            Text(getText())
                .font(.system(size: 15, weight: .medium))
                .padding(24)
                .multilineTextAlignment(.center)
                .shadow(color: Color(UIColor.black.withAlphaComponent(0.5)), radius: 2, x: 1, y: 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(getForegroundColor())
    }
    
    var body: some View {
        ZStack {
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
                    .background(LinearGradient(gradient: Gradient(colors: [ Color(UIColor.cabinetRoseRed.withAlphaComponent(0.3)), Color(UIColor.cabinetPureBlue.withAlphaComponent(0.4)) ]), startPoint: .topLeading, endPoint: .bottomTrailing))

            }
        }
        .background(Color.white)

    }
    
    private func getForegroundColor() -> Color {
        if let hex = entry.theme?.foreground {
            return Color(UIColor(hex: hex))
        } else {
            return .white
        }
    }
    
    private func getText() -> String {
        let defaultText = "Other presents come when you least expect them.\n惊喜总是不期而至。"
        guard let values = entry.daily?.sentence else { return defaultText }
        let random = Int.random(in: 0..<values.count)
        return values[ifPresent: random] ?? defaultText
    }
}
