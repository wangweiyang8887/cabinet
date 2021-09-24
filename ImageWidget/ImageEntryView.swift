// Copyright © 2021 evan. All rights reserved.

import SwiftUI

struct ImageEntryView: View {
    var entry: SimpleEntry
    
    var body: some View {
        ZStack {
            Image(uiImage: entry.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
