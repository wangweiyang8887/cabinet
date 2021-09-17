// Copyright © 2021 evan. All rights reserved.

import SwiftUI
import Foundation

struct InspireView: View {
    var entry: InspireEntry
    
    var body: some View {
        ZStack {
            VStack {
                Text(getText())
                    .font(.system(size: 15, weight: .medium))
                    .padding(24)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color(UIColor.black.withAlphaComponent(0.7)), radius: 2, x: 1, y: 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(.white)
            .background(LinearGradient(gradient: Gradient(colors: [ Color(UIColor.cabinetRoseRed.withAlphaComponent(0.3)), Color(UIColor.cabinetPureBlue.withAlphaComponent(0.4)) ]), startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .background(Color.white)

    }
    
    private func getText() -> String {
        let defaultText = "Other presents come when you least expect them.\n惊喜总是不期而至。"
        guard let values = entry.daily?.sentence else { return defaultText }
        let random = Int.random(in: 0..<values.count)
        return values[ifPresent: random] ?? defaultText
    }
}
