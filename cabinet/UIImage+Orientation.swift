// Copyright © 2021 evan. All rights reserved.

extension UIImage {
    // Copied from http://stackoverflow.com/questions/6413851/iphone-rotate-image-context-before-saving-to-file
    // Also here http://stackoverflow.com/a/5427890/588253
    @objc public func fixOrientation() -> UIImage {
        if imageOrientation == .up { return self }
        var transform: CGAffineTransform = .identity
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height).rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0).rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height).rotated(by: -.pi / 2)
        default: break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0).scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0).scaledBy(x: -1, y: 1)
        default: break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage?.bitsPerComponent ?? 0, bytesPerRow: cgImage?.bytesPerRow ?? 0, space: cgImage?.colorSpace ?? colorSpace, bitmapInfo: cgImage?.bitmapInfo.rawValue ?? bitmapInfo.rawValue)
        context?.concatenate(transform)
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context?.draw(cgImage!, in: CGRect(origin: .zero, size: CGSize(width: size.height, height: size.width)))
        default:
            context?.draw(cgImage!, in: CGRect(origin: .zero, size: size))
        }
        guard let cgImage = context?.makeImage() else { return self }
        return UIImage(cgImage: cgImage)
    }
}
