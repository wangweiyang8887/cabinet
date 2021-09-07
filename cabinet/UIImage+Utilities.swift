// Copyright © 2021 evan. All rights reserved.

extension UIImage {
    public func tinted(with color: UIColor) -> UIImage {
         let renderer = UIGraphicsImageRenderer(size: size)
         let resultImage = renderer.image {
             let rect = CGRect(origin: .zero, size: size)
             draw(in: rect)
             $0.cgContext.setBlendMode(.sourceAtop)
             $0.cgContext.setFillColor(color.cgColor)
             $0.cgContext.fill(rect)
         }
         return resultImage
     }
}
