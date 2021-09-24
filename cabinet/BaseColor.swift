// Copyright © 2021 evan. All rights reserved.

import UIKit

extension UIColor {
    private convenience init(rgbHex value: UInt) {
        let red = CGFloat((value >> 16) & 0xFF) / 255
        let green = CGFloat((value >> 8) & 0xFF) / 255
        let blue = CGFloat((value >> 0) & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

    /// Apple Blossom (#A83D3D)
    @objc public static var cabinetBlossom: UIColor { return UIColor(named: "Apple Blossom", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Shamrock (#53D9AE)
    @objc public static var cabinetGreenV2: UIColor { return UIColor(named: "Shamrock", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Gallery (#F0F0F0)
    @objc public static var cabinetLightestGray: UIColor { return UIColor(named: "Gallery", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Wild Sand (#F4F4F4)
    @objc public static var cabinetLighterGray: UIColor { return UIColor(named: "Wild Sand", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Mercury (#E9E9E9)
    @objc public static var cabinetLightGray: UIColor { return UIColor(named: "Mercury", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// French Gray (#C0C1C4)
    @objc public static var cabinetGray: UIColor { return UIColor(named: "French Gray", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Nobel (#B7B7B7)
    @objc public static var cabinetMediumGray: UIColor { return UIColor(named: "Nobel", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Dusty Gray (#999999)
    @objc public static var cabinetDarkGray: UIColor { return UIColor(named: "Dusty Gray", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Dove Gray (#666666)
    @objc public static var cabinetDarkerGray: UIColor { return UIColor(named: "Dove Gray", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Mine Shaft (#333333)
    @objc public static var cabinetDarkestGray: UIColor { return UIColor(named: "Mine Shaft", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// White AF (#FFFFFF)
    @objc public static var cabinetWhite: UIColor { return UIColor(named: "White AF", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Black AF (#000000)
    @objc public static var cabinetBlack: UIColor { return UIColor(named: "Black AF", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Laser (#C9AB79)
    @objc public static var cabinetYellowV2: UIColor { return UIColor(named: "Laser", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Chestnut Rose (#D06656)
    @objc public static var cabinetRose: UIColor { return UIColor(named: "Chestnut Rose", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Tuna (#30313B)
    @objc public static var cabinetTuna: UIColor { return UIColor(named: "Tuna", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Curious Blue (#1AADE0)
    @objc public static var cabinetBlue: UIColor { return UIColor(named: "Curious Blue", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Denim (#1A6CDB)
    public static var cabinetDarkBlue: UIColor { return UIColor(named: "Denim", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Vista (#86D492)
    public static var cabinetGreen: UIColor { return UIColor(named: "Vista", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Vivid Violet (#913BAE)
    public static var cabinetPurple: UIColor { return UIColor(named: "Vivid Violet", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Mandy (#E75763)
    @objc public static var cabinetRed: UIColor { return UIColor(named: "Mandy", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Goldenrod (#FDCD71)
    @objc public static var cabinetYellow: UIColor { return UIColor(named: "Goldenrod", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Yellow Orange (#FFAF3D)
    public static var cabinetDarkYellow: UIColor { return UIColor(named: "Yellow Orange", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Royal Purple (#5B3CDC)
    public static var cabinetPurpleV2: UIColor { return UIColor(named: "Royal Purple", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Fuel Yellow. (#ECB21C)
    public static var cabinetYellowV3: UIColor { return UIColor(named: "Fuel Yellow", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Boulder (#787878)
    /// Nobel (#B3B3B3)
    public static var zillyMediumGray: UIColor { return UIColor(named: "Nobel", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Alto (#D2D2D2)
    @objc public static var zillyLightGray: UIColor { return UIColor(named: "Alto", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Mercury (#E6E6E6)
    @objc public static var zillyLighterGray: UIColor { return UIColor(named: "Mercury", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Concrete (#F2F2F2)
    @objc public static var zillyLightestGray: UIColor { return UIColor(named: "Concrete", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Alabaster (#FAFAFA)
    @objc public static var cabinetOffWhite: UIColor { return UIColor(named: "Alabaster", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Separator (#E9E9E9)
    @objc public static var cabinetSeparator: UIColor { return UIColor(named: "Separator", in: BaseBundle.bundle, compatibleWith: nil)! }
    
    /// Initializes a color instance declared outside of the project's design guidelines using a custom RGB hex.
    public static func nonStandardColor(withRGBHex value: UInt) -> UIColor {
        return .init(rgbHex: value)
    }
    
    static var lightestBlue: UIColor { return .nonStandardColor(withRGBHex: 0xABDCFF) }
    static var darkBlue: UIColor { return .nonStandardColor(withRGBHex: 0x0396FF) }
}

extension UIColor {
    static var cabinetPureBlue: UIColor { return UIColor(named: "Pure Blue", in: BaseBundle.bundle, compatibleWith: nil)! }
    static var cabinetRoseRed: UIColor { return UIColor(named: "Rose Red", in: BaseBundle.bundle, compatibleWith: nil)! }
    static var cabinetBrinkPink: UIColor { return UIColor(named: "Brink Pink", in: BaseBundle.bundle, compatibleWith: nil)! }
    static var cabinetShockingPink: UIColor { return UIColor(named: "Shocking Pink", in: BaseBundle.bundle, compatibleWith: nil)! }
    static var cabinetChalky: UIColor { return UIColor(named: "Chalky", in: BaseBundle.bundle, compatibleWith: nil)! }
    static var cabinetHeliotrope: UIColor { return UIColor(named: "Heliotrope", in: BaseBundle.bundle, compatibleWith: nil)! }
    static var cabinetCerulean: UIColor { return UIColor(named: "Cerulean", in: BaseBundle.bundle, compatibleWith: nil)! }
    static var cabinetJava: UIColor { return UIColor(named: "Java", in: BaseBundle.bundle, compatibleWith: nil)! }
    static var cabinetTacao: UIColor { return UIColor(named: "Tacao", in: BaseBundle.bundle, compatibleWith: nil)! }
    static var cabinetDallas: UIColor { return UIColor(named: "Dallas", in: BaseBundle.bundle, compatibleWith: nil)! }
}
