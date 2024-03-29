// Copyright © 2021 evan. All rights reserved.

/// A wrapper around gradient components, that also include gradient utilities.
public struct TTGradient : Equatable {
    /// The array of color objects defining the color of each gradient stop.
    public let components: [UIColor]
    /// An optional array of NSNumber objects defining the location of each
    /// gradient stop as a value in the range [0,1]. The values must be
    /// monotonically increasing. If a nil array is given, the stops are
    /// assumed to spread uniformly across the [0,1] range. When rendered,
    /// the colors are mapped to the output colorspace before being
    /// interpolated. Defaults to nil.
    public let locations: [NSNumber]?

    // Lifecycle
    /// Initializes a custom gradient
    ///
    /// - Parameters:
    ///   - components: The array of color objects defining the color of each gradient stop.
    ///   - locations: An optional array of NSNumber objects defining the location of each
    ///                gradient stop as a value in the range [0,1]. The values must be
    ///                monotonically increasing. If a nil array is given, the stops are
    ///                assumed to spread uniformly across the [0,1] range. When rendered,
    ///                the colors are mapped to the output colorspace before being
    ///                interpolated. Defaults to nil.
    public init(components: [UIColor], locations: [NSNumber]? = nil) {
        self.components = components
        self.locations = locations
    }

    public static let topic = TTGradient(components: [ .nonStandardColor(withRGBHex: 0xFD915B) ])
    /// Converts a single color to a gradient
    public static func color(_ color: UIColor) -> TTGradient { return TTGradient(components: [ color ]) }
    
    // Presets
    public static let curiousBlueToVividViolet = TTGradient(components: [ .cabinetBlue, .cabinetPurple ])
    public static let curiousBlueToBrinkPink = TTGradient(components: [ .cabinetBlue, .cabinetBrinkPink ])
    public static let shockingPinkToChalky = TTGradient(components: [ .cabinetShockingPink, .cabinetChalky ])
    public static let goldenrodToMandyToVividViolet = TTGradient(components: [ .cabinetYellow, .cabinetRed, .cabinetPurple ])
    public static let heliotropeToCerulean = TTGradient(components: [ .cabinetHeliotrope, .cabinetCerulean ])
    public static let denimToJava = TTGradient(components: [ .cabinetDarkBlue, .cabinetJava ])
    public static let goldenrodToJava = TTGradient(components: [ .cabinetYellow, .cabinetJava ])
    public static let tacaoToDallas = TTGradient(components: [ .cabinetTacao, .cabinetDallas ])
    public static let first = TTGradient(components: [ .nonStandardColor(withRGBHex: 0x3D2C8D), .nonStandardColor(withRGBHex: 0x916BBF) ])
    public static let second = TTGradient(components: [ .nonStandardColor(withRGBHex: 0xFF7777), .nonStandardColor(withRGBHex: 0xA2416B) ])
    public static let third = TTGradient(components: [ .nonStandardColor(withRGBHex: 0xB24080), .nonStandardColor(withRGBHex: 0xECAC5D) ])
    public static let fouth = TTGradient(components: [ .nonStandardColor(withRGBHex: 0xD57E7E), .nonStandardColor(withRGBHex: 0xA2CDCD) ])
    public static let fifth = TTGradient(components: [ .nonStandardColor(withRGBHex: 0xB1E693), .nonStandardColor(withRGBHex: 0xEC9CD3) ])
    public static let sixth = TTGradient(components: [ .nonStandardColor(withRGBHex: 0xB5DEFF), .nonStandardColor(withRGBHex: 0xCAB8FF) ])
    public static let seventh = TTGradient(components: [ .nonStandardColor(withRGBHex: 0xFDB9FC), .nonStandardColor(withRGBHex: 0xFFEDED) ])
    public static let eighth = TTGradient(components: [ .nonStandardColor(withRGBHex: 0xFFEF78), .nonStandardColor(withRGBHex: 0xB1FFFD) ])
    public static let ninth = TTGradient(components: [ .nonStandardColor(withRGBHex: 0xB97A95), .nonStandardColor(withRGBHex: 0x290FBA) ])
    public static let tenth = TTGradient(components: [ .nonStandardColor(withRGBHex: 0xFF95C5), .nonStandardColor(withRGBHex: 0x6F69AC) ])
    public static let eleventh = TTGradient(components: [ .nonStandardColor(withRGBHex: 0xF037A5), .nonStandardColor(withRGBHex: 0x3DB2FF) ])
    public static let twelfth = TTGradient(components: [ .nonStandardColor(withRGBHex: 0xF0D9FF), .nonStandardColor(withRGBHex: 0xDF2E2E) ])
    public static let thirteenth = TTGradient(components: [ .nonStandardColor(withRGBHex: 0xF43B86), .nonStandardColor(withRGBHex: 0x5C527F) ])    

    /// Applies self to a given layer.
    ///
    /// - Parameters:
    ///   - Layer: Layer on which the gradient will be applied.
    ///   - Direction: Direction of the gradient.
    public func apply(to layer: CAGradientLayer, direction: Direction) {
        guard components.count > 1 else {
            layer.colors = nil
            layer.locations = nil
            layer.backgroundColor = components.first?.cgColor
            return
        }
        layer.colors = components.map { $0.cgColor }
        layer.startPoint = direction.points.start
        layer.endPoint = direction.points.end
        layer.locations = locations
    }

    /// Generates a UIImage from a gradient.
    ///
    /// - Parameters:
    ///   - Size: Size of the generated UIImage
    ///   - Direction: Direction of the gradient of the image
    public func image(with size: CGSize, direction: Direction) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        apply(to: gradientLayer, direction: direction)
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    /// Direction presets that are translated into start and end points when rendering the gradient layer.
    public enum Direction {
        case topLeftToBottomRight, topRightToBottomLeft, bottomRightToTopLeft, topToBottom, leftToRight, bottomToTop, rightToLeft, custom((start: CGPoint, end: CGPoint))

        public var points: (start: CGPoint, end: CGPoint) {
            switch self {
            case .topLeftToBottomRight: return (CGPoint(x: 0.01, y: 0), CGPoint(x: 1, y: 1))
            case .topRightToBottomLeft: return (CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1))
            case .bottomRightToTopLeft: return (CGPoint(x: 1, y: 1), CGPoint(x: 0.01, y: 0))
            case .topToBottom: return (CGPoint(x: 0.5, y: 0), CGPoint(x: 0.5, y: 1))
            case .leftToRight: return (CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5))
            case .bottomToTop: return (CGPoint(x: 0.5, y: 1), CGPoint(x: 0.5, y: 0))
            case .rightToLeft: return (CGPoint(x: 1, y: 0.5), CGPoint(x: 0, y: 0.5))
            case .custom(let values): return (values.start, values.end)
            }
        }
    }
}

extension UIColor {

    /// Initializes a UIColor from a gradient pattern.
    /// - Parameters:
    ///   - gradient: the gradient used to generate the color pattern.
    ///   - bounds: the bounds of the gradient layer used to generate the color pattern.
    ///   - direction: the direction of the gradient.
    convenience init?(gradient: TTGradient, bounds: CGRect, direction: TTGradient.Direction = .leftToRight) {
        guard let layer = gradient.layer(withBounds: bounds, direction: direction) else { return nil }
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let image = renderer.image { layer.render(in: $0.cgContext) }
        self.init(patternImage: image)
    }
}

extension TTGradient {
    /// Initializes a gradient layer from this gradient, with the given bounds and applying the given direction.
    /// - Parameters:
    ///   - bounds: the bounds of the gradient layer.
    ///   - direction: the direction of the gradient.
    public func layer(withBounds bounds: CGRect, direction: Direction = .leftToRight) -> CAGradientLayer? {
        guard components.count > 1 else { return nil }
        let layer = CAGradientLayer()
        layer.colors = components.map { $0.cgColor }
        layer.startPoint = direction.points.start
        layer.endPoint = direction.points.end
        layer.locations = locations
        layer.bounds = bounds
        return layer
    }
}

extension TTGradient {
    /// All the predefined gradients, organized so they seemlessly transition between one gradient and the next one.
    static var allCases: [TTGradient] = [ .curiousBlueToVividViolet, .curiousBlueToBrinkPink, .shockingPinkToChalky, .goldenrodToMandyToVividViolet, .heliotropeToCerulean, .denimToJava, .goldenrodToJava, .tacaoToDallas, .first, .second, .third, .fouth, .fifth, .sixth, .seventh, .eighth, .ninth, .tenth, .eleventh, .twelfth, .thirteenth ]
}

extension TTGradient : ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: UIColor...) {
        self.init(components: elements)
    }
}

