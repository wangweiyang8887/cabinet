// Copyright © 2021 evan. All rights reserved.

extension UIImage {
    public static func createPDF(forImages images: [UIImage]) -> NSData? {
        guard !images.isEmpty else { return nil }
        let pdfData = NSMutableData()
        let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!
        var mediaBox = CGRect(x: 0, y: 0, width: images.first!.size.width, height: images.first!.size.height)
        let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil)!
        for image in images {
            mediaBox = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            pdfContext.beginPage(mediaBox: &mediaBox)
            pdfContext.draw(image.cgImage!, in: mediaBox)
            pdfContext.endPage()
        }
        return pdfData
    }

    public func scale(toSize newSize: CGSize) -> UIImage? {
        var newImage: UIImage?
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(cgImage, in: newRect)
            if let img = context.makeImage() {
                newImage = UIImage(cgImage: img)
            }
            UIGraphicsEndImageContext()
        }
        return newImage
    }

    // MARK: Image Compression
    
    /// See compressedScaledImageData() for more information.
    /// - NOTE: Lossy image compression.
    /// - Parameters:
    ///   - maxBytes: Maximum bytes of image compression。
    ///   - compressionFactor: Factor used to compress the image after scaling it. Defaults to 50%. When the minimum value is 0.1, compression will no longer occur
    /// - Returns: Scaled and compressed image.
    public func compressedScaledImage(to maxBytes: UInt, compressionFactor: CGFloat = 0.5) -> (UIImage, Data) {
        let imageData = compressedScaledImageData(compressionFactor: compressionFactor)
        let decrescentFactor = compressionFactor - 0.1
        guard imageData.count < maxBytes || decrescentFactor == 0.1 else { return compressedScaledImage(to: maxBytes, compressionFactor: decrescentFactor) }
        return (UIImage(data: imageData)!, imageData)
    }

    /// See compressedScaledImageData() for more information.
    /// - NOTE: Lossy image compression.
    /// - Parameters:
    ///   - maxSize: Max resolution of the resulting image. Defaults to CGSize(width: 1280, height: 1024).
    ///   - compressionFactor: Factor used to compress the image after scaling it. Defaults to 50%.
    /// - Returns: Scaled and compressed image.
    public func compressedScaledImage(maxSize: CGSize = CGSize(width: 1280, height: 1024), compressionFactor: CGFloat = 0.5) -> UIImage {
        let imageData = compressedScaledImageData(maxSize: maxSize, compressionFactor: compressionFactor)
        return UIImage(data: imageData)!
    }

    /// Scales the image up to the given max resolution. If the original resolution of the image isn't higher than the given max resolution, it doesn't change the resolution.
    /// After scaling, it compresses the image using the given compression factor.
    /// - NOTE: Lossy image compression.
    /// - Parameters:
    ///   - maxSize: Max resolution of the resulting image. Defaults to CGSize(width: 1280, height: 1024).
    ///   - compressionFactor: Factor used to compress the image after scaling it. Defaults to 50%.
    /// - Returns: Scaled and compressed image data.
    @objc public func compressedScaledImageData(maxSize: CGSize = CGSize(width: 1280, height: 1024), compressionFactor: CGFloat = 0.5) -> Data {
        var imageWidth = size.width
        var imageHeight = size.height
        let maxWidth = maxSize.width
        let maxHeight = maxSize.height
        let originalRatio = imageWidth / imageHeight
        let maxRatio = maxWidth / maxHeight

        if imageHeight > maxHeight || imageWidth > maxWidth {
            if originalRatio < maxRatio {
                // Adjust width according to maxHeight
                let newRatio = maxHeight / imageHeight
                imageWidth = newRatio * imageWidth
                imageHeight = maxHeight
            } else if originalRatio > maxRatio {
                // Adjust height according to maxWidth
                let newRatio = maxWidth / imageWidth
                imageHeight = newRatio * imageHeight
                imageWidth = maxWidth
            } else {
                // Image is already at 4:3 ratio
                imageHeight = maxHeight
                imageWidth = maxWidth
            }
        }

        func getImageData(with image: UIImage) -> Data? {
            return autoreleasepool { return image.jpegData(compressionQuality: compressionFactor) }
        }
        
        let rect = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        UIGraphicsBeginImageContext(rect.size)
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        let imageData = getImageData(with: image)
        UIGraphicsEndImageContext()

        return imageData!
    }

    // FIXME: This can only be changed from NSMutableArray to a regular Swift array when we stop using AFNetworking, as it's a requirement on framework's end.
    public static func json(fromImages images: [UIImage]) -> NSMutableArray {
        return NSMutableArray(array: images.concurrentMap { UIImage.json(fromImage: $0) })
    }

    public static func json(fromImage image: UIImage) -> [String:Any] {
        return [
            "data" : image.compressedScaledImageData(),
            "mime" : DocumentExtension.jpeg.mime,
            "filename" : "image\(DocumentExtension.jpeg.extension)",
        ]
    }
}


// MARK: Caching
extension UIImage {
    /// Tints a UIImage with a diagonal linear gradient between given colors
    ///
    /// - Parameters:
    ///   - Gradient: ZLGradient used to create the linear gradient from it's color components
    ///   - Direction: Gradient direction
    public func tinted(with gradient: TTGradient, direction: TTGradient.Direction) -> UIImage {
        let result = UIGraphicsImageRenderer(size: size).image { context in
            let (height, width) = (size.height, size.width)
            context.cgContext.translateBy(x: 0, y: height)
            context.cgContext.scaleBy(x: 1, y: -1)
            context.cgContext.setBlendMode(.normal)
            let rect = CGRect(x: 0, y: 0, width: width, height: height)
            let colorsArray = (gradient.components.map { $0.cgColor }) as CFArray
            let space = CGColorSpaceCreateDeviceRGB()
            let cgGradient = CGGradient(colorsSpace: space, colors: colorsArray, locations: nil)
            context.cgContext.clip(to: rect, mask: cgImage!)
            let (startPoint, endPoint) = { () -> (CGPoint, CGPoint) in
                switch direction {
                case .topLeftToBottomRight: return (CGPoint(x: 0, y: height), CGPoint(x: width, y: 0))
                case .topRightToBottomLeft: return (CGPoint(x: width, y: height), CGPoint(x: 0, y: 0))
                case .bottomRightToTopLeft: return (CGPoint(x: width, y: 0), CGPoint(x: 0, y: height))
                case .topToBottom: return (CGPoint(x: 0, y: height), CGPoint(x: 0, y: 0))
                case .bottomToTop: return (CGPoint(x: 0, y: 0), CGPoint(x: 0, y: height))
                case .rightToLeft: return (CGPoint(x: width, y: height), CGPoint(x: 0, y: height))
                case .leftToRight: return (CGPoint(x: 0, y: height), CGPoint(x: width, y: height))
                case .custom(let values): return (values.start, values.end)
                }
            }()
            context.cgContext.drawLinearGradient(cgGradient!, start: startPoint, end: endPoint, options: .drawsBeforeStartLocation)
        }
        return result
    }
    
    // http://stackoverflow.com/a/7377827/588253
    @objc public func masked(with color: UIColor) -> UIImage {
        let imageRect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        
        // Flip the image
        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1, y: -1)
        
        // Attempt 1
        // Draw original image
        context?.draw(cgImage!, in: imageRect)
        
        // Apply tint to mask
        context?.setBlendMode(.sourceIn)
        color.setFill()
        context?.fill(imageRect)
        
        let colorizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return colorizedImage ?? self
    }
    
    @objc public func scaledToSize(_ newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0);
        draw(in: CGRect(origin: .zero, size: newSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? self
    }
}
