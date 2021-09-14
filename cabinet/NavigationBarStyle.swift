// Copyright © 2021 evan. All rights reserved.

public struct NavigationBarStyle {
    public var backgroundColor: UIColor
    public var buttonColor: UIColor
    public var titleColor: UIColor
    public var font: UIFont
    public var hasShadow: Bool

    // MARK: Presets
    public static let white = NavigationBarStyle(backgroundColor: .cabinetWhite, buttonColor: .cabinetBlack, titleColor: .cabinetBlack)
    public static let whiteWithoutShadow = NavigationBarStyle(backgroundColor: .cabinetWhite, buttonColor: .cabinetBlack, titleColor: .cabinetBlack, hasShadow: false)
    public static let transparent = NavigationBarStyle(backgroundColor: .clear, buttonColor: .cabinetWhite, titleColor: .cabinetWhite, hasShadow: false)

    // MARK: Initialization
    public init(backgroundColor: UIColor, buttonColor: UIColor, titleColor: UIColor, font: UIFont = .systemFont(ofSize: 17, weight: .semibold), hasShadow: Bool = true) {
        self.backgroundColor = backgroundColor
        self.buttonColor = buttonColor
        self.titleColor = titleColor
        self.font = font
        self.hasShadow = hasShadow
    }
}
