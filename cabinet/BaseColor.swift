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
    @objc public static var cabinetGreen: UIColor { return UIColor(named: "Shamrock", in: BaseBundle.bundle, compatibleWith: nil)! }
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
    @objc public static var cabinetYellow: UIColor { return UIColor(named: "Laser", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Chestnut Rose (#D06656)
    @objc public static var cabinetRose: UIColor { return UIColor(named: "Chestnut Rose", in: BaseBundle.bundle, compatibleWith: nil)! }
    /// Tuna (#30313B)
    @objc public static var cabinetTuna: UIColor { return UIColor(named: "Tuna", in: BaseBundle.bundle, compatibleWith: nil)! }
    
    /// Initializes a color instance declared outside of the project's design guidelines using a custom RGB hex.
    public static func nonStandardColor(withRGBHex value: UInt) -> UIColor {
        return .init(rgbHex: value)
    }
    
    static var lightestBlue: UIColor { return .nonStandardColor(withRGBHex: 0xABDCFF) }
    static var darkBlue: UIColor { return .nonStandardColor(withRGBHex: 0x0396FF) }
}
