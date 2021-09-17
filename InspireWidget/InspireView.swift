// Copyright © 2021 evan. All rights reserved.

import SwiftUI

struct InspireView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text("Other presents come when you least expect them.\n惊喜总是不期而至。")
                    .padding(24)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black, radius: 2, x: 1, y: 2)
            }
            Spacer()
        }
        .foregroundColor(.white)
        .background(LinearGradient(gradient: Gradient(colors: [ Color(UIColor.cabinetBrinkPink), Color(UIColor.cabinetHeliotrope) ]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

struct InspireView_Previews: PreviewProvider {
    static var previews: some View {
        InspireView()
    }
}
