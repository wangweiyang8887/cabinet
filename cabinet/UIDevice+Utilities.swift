// Copyright © 2021 evan. All rights reserved.

import UIKit

extension UIDevice {
    /// Device model.
    public struct Model : CustomStringConvertible {
        /// Device family, e.g. iPhone for iPhone XS (iPhone11,2).
        public let family: Family
        /// Internal major version, e.g. "11" for iPhone XS (iPhone11,2).
        public let majorVersion: Int
        /// Internal minor version, e.g. "2" for iPhone XS (iPhone11,2).
        public let minorVersion: Int
        /// Internal hardware model, e.g. "iPhone11,2" for iPhone XS.
        public var identifier: String { return "\(family.rawValue)\(majorVersion),\(minorVersion)" }

        /// Initializes a model based on the given parameters.
        ///
        /// - Parameters:
        ///   - family: device family, e.g. iPhone for iPhone XS (iPhone11,2).
        ///   - majorVersion: internal major version, e.g. "11" for iPhone XS (iPhone11,2).
        ///   - minorVersion: internal minor version, e.g. "2" for iPhone XS (iPhone11,2).
        public init(family: Family, majorVersion: Int, minorVersion: Int) {
            (self.family, self.majorVersion, self.minorVersion) = (family, majorVersion, minorVersion)
        }

        /// Initializes a model based on a given identifier, e.g. "iPhone11,2"
        public init?(identifier: String) {
            let regex = try! NSRegularExpression(pattern: "^([A-Za-z]+)(\\d+),(\\d+)$")
            guard let match = regex.firstMatch(in: identifier, range: NSRange(location: 0, length: identifier.utf16.count)) else { return nil }
            let familyString = (identifier as NSString).substring(with: match.range(at: 1))
            let majorVersionString = (identifier as NSString).substring(with: match.range(at: 2))
            let minorVersionString = (identifier as NSString).substring(with: match.range(at: 3))
            let family = Family(rawValue: familyString) ?? .unknown
            guard let majorVersion = Int(majorVersionString), let minorVersion = Int(minorVersionString) else { return nil }
            (self.family, self.majorVersion, self.minorVersion) = (family, majorVersion, minorVersion)
        }

        /// Same as the model's identifier.
        public var description: String { return identifier }
    }

    /// Device family.
    ///
    /// - iPhone: iPhone family.
    /// - iPod: iPod family.
    /// - iPad: iPad family.
    /// - appleTV: AppleTV family.
    /// - appleWatch: watch family.
    /// - unknown: represent a family that can't be identified yet.
    public enum Family : String {
        case iPhone = "iPhone"
        case iPod = "iPod"
        case iPad = "iPad"
        case appleTV = "AppleTV"
        case appleWatch = "Watch"
        case unknown
    }

    /// Return the model of the current device, or unknown if it can't be identifier yet.
    public static let model: Model = {
        // Adapted from https://stackoverflow.com/questions/46192280/detect-if-the-device-is-iphone-x
        let identifier: String = {
            if isSimulator {
                return ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
            } else {
                var size = 0
                sysctlbyname("hw.machine", nil, &size, nil, 0)
                var machine = [CChar](repeating: 0, count: size)
                sysctlbyname("hw.machine", &machine, &size, nil, 0)
                return String(cString: machine)
            }
        }()
        guard let model = Model(identifier: identifier) else {
            return Model(family: .unknown, majorVersion: 1, minorVersion: 1) // Don't crash
        }
        return model
    }()

    /// Whether the current device is a simulator.
    @objc public static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }

    /// Whether the current device is from an iPhone X family. As of date, those would be e.g. iPhone X, XS, XS Max, and XR.
    @objc public static let isIPhoneX: Bool = {
        guard model.family == .iPhone else { return false }
        switch (model.majorVersion, model.minorVersion) {
        case (10, 3), (10, 6), (11..., _): return true // Default unknown newer models to "iPhone X"-like
        default: return false
        }
    }()

    @objc public static let isIPad: Bool = {
        model.family == .iPad
    }()
    
    @objc public static let screenWidth: CGFloat = {
        return UIScreen.main.bounds.size.width
    }()
    
    @objc public static let screenHeight: CGFloat = {
        return UIScreen.main.bounds.size.height
    }()
    
    @objc public static let statusBarHeight: CGFloat = {
        let topInset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? UIApplication.shared.statusBarFrame.size.height
        return UIDevice.isIPhoneX ? topInset : 20
    }()
    
    @objc public static let navigationBarHeight: CGFloat = {
        return 44
    }()
    
    @objc public static let navigationHeight: CGFloat = {
        let topInset: CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? UIApplication.shared.statusBarFrame.size.height
        return UIDevice.isIPhoneX ? topInset + 44 : 64
    }()
    
    static let tabbarHeight: CGFloat = 49
    static let tabbarOutsideHeight: CGFloat = 75
    @objc public static let safeTopHeight: CGFloat = {
        return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
    }()
    
    @objc public static let safeBottomHeight: CGFloat = {
        return UIDevice.isIPhoneX ? 34 : 0
    }()
}

// MARK: - Legacy

extension UIDevice {
    /// Objective-C bridge that returns the model identifier.
    @objc public static var objc_modelIdentifier: String { return model.identifier }
}

