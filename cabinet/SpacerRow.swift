// Copyright © 2021 evan. All rights reserved.

final class SpacerRow : BaseRow {
    fileprivate let height: CGFloat

    // MARK: Settings
    override func computeHeight() -> RowHeight { return .fixed(height) }

    // MARK: Lifecycle
    required init?(coder: NSCoder) { 🔥 }
    required init() {
        height = 8
        super.init()
    }

    init(height: CGFloat, backgroundColor: UIColor = .cabinetWhite) {
        self.height = height
        super.init()
        self.backgroundColor = backgroundColor
    }
}
