// Copyright © 2021 evan. All rights reserved.

extension Dictionary where Key == NSAttributedString.Key, Value == Any {
    public static var strikethrough: [Key:Value] {
        return [ .strikethroughStyle : NSUnderlineStyle.single.rawValue ]
    }
}

extension String {
    public func withAttributes(_ attributes: [NSAttributedString.Key:Any]) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: self, attributes: attributes)
    }

    public func withColor(_ color: UIColor) -> NSAttributedString {
        return withAttributes([ .foregroundColor : color ])
    }

    public func withStrikethrough(style: NSUnderlineStyle = .single) -> NSAttributedString {
        return withAttributes([ .strikethroughStyle : style.rawValue ])
    }

    public func withSystemFont(of size: CGFloat, weight: UIFont.Weight = .regular, color: UIColor? = nil, alignment: NSTextAlignment? = nil, lineSpace: CGFloat = 0.0) -> NSMutableAttributedString {
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpace
        given(alignment) { paragraphStyle.alignment = $0 }
        var attributes: [NSAttributedString.Key:Any] = [ .font : font, .paragraphStyle : paragraphStyle ]
        given(color) { attributes[.foregroundColor] = $0 }
        return withAttributes(attributes)
    }

    public func withLineHeight(_ lineHeight: CGFloat) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        return withAttributes([ .paragraphStyle : paragraphStyle ])
    }

    /// Marks with bold all the substrings that are between pairs of asterisk symbol (*). Similar to how BBCode or certain markdown marks work.
    ///
    /// - Parameter boldFont: The font to be applied on the substrings between asterisks.
    /// - Returns: An attributed string containing the whole given string, but with the respective bold portions.
    public func withBoldParts(boldFont: UIFont) -> NSAttributedString {
        return NSAttributedString(string: self).withBoldParts(boldFont: boldFont)
    }

    public func replacingPlaceholders(by arguments: NSAttributedString...) -> NSAttributedString {
        let result = NSMutableAttributedString(string: self)
        result.replacePlaceholders(by: arguments)
        return result
    }
}

extension NSAttributedString {
    public func with(_ attributes: [NSAttributedString.Key:Any], range: NSRange? = nil) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: self)
        let applyRange = range ?? NSRange(location: 0, length: result.length)
        result.addAttributes(attributes, range: applyRange)
        return result
    }

    public func appending(_ other: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: self)
        result.append(other)
        return result
    }

    /// Returns the size required to draw the string given a certain width and height constraint, wrapping as necessary.
    ///
    /// The returned size might break the constraints (typically the height constraint) if there is not enough space to fit the entire string.
    /// - Parameter isUsedToSizeView: To use the return value to size a view, set this parameter to true and the result will be rounded up to the nearest integer.
    public func size(maxWidth: CGFloat = .greatestFiniteMagnitude, maxHeight: CGFloat = .greatestFiniteMagnitude, isUsedToSizeView: Bool) -> CGSize {
        let maxSize = CGSize(width: maxWidth, height: maxHeight)
        var result = self.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, context: nil).size
        if isUsedToSizeView { result = CGSize(width: ceil(result.width), height: ceil(result.height)) }
        return result
    }

    /// Marks with bold all the substrings that are between pairs of asterisk symbol (*). Similar to how BBCode or certain markdown marks work.
    ///
    /// - Parameter boldFont: The font to be applied on the substrings between asterisks.
    /// - Returns: An attributed string containing the whole given string, but with the respective bold portions.
    public func withBoldParts(boldFont: UIFont) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: self)
        // Bold
        let boldRegex = try! NSRegularExpression(pattern: "\\*(?=\\S)([^*]+)(?<=\\S)\\*")
        result.replaceMatches(of: boldRegex) { match in
            let text = (result.string as NSString).substring(with: match.range(at: 1))
            return text.withAttributes([ .font : boldFont ])
        }
        return result
    }

    public func replacingPlaceholders(by arguments: NSAttributedString...) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: self)
        result.replacePlaceholders(by: arguments)
        return result
    }

    @objc public convenience init(image: UIImage, centeredFor font: UIFont) {
        let iconAttachment = NSTextAttachment()
        iconAttachment.image = image
        iconAttachment.bounds = CGRect(x: 0, y: font.capHeight / 2 - image.size.height / 2, width: image.size.width, height: image.size.height)
        self.init(attachment: iconAttachment)
    }
}

extension NSMutableAttributedString {
    public func replaceMatches(of regex: NSRegularExpression, transform: (NSTextCheckingResult) -> NSAttributedString) {
        while let match = regex.firstMatch(in: string, range: NSRange(location: 0, length: string.utf16.count)) {
            replaceCharacters(in: match.range, with: transform(match))
        }
    }

    public func replacePlaceholders(by arguments: NSAttributedString...) {
        replacePlaceholders(by: arguments)
    }

    fileprivate func replacePlaceholders(by arguments: [NSAttributedString]) {
        for argument in arguments {
            let range = (string as NSString).range(of: "%@")
            precondition(range.location != NSNotFound)
            replaceCharacters(in: range, with: argument)
        }
    }
}

public func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString { return lhs.appending(rhs) }
public func + (lhs: String, rhs: NSAttributedString) -> NSAttributedString { return NSAttributedString(string: lhs).appending(rhs) }
public func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString { return lhs.appending(NSAttributedString(string: rhs)) }
public func += (lhs: inout NSAttributedString, rhs: NSAttributedString) { lhs = lhs + rhs }
public func += (lhs: inout NSAttributedString, rhs: String) { lhs = lhs + rhs }
public func += (lhs: NSMutableAttributedString, rhs: NSAttributedString) { lhs.append(rhs) }
public func += (lhs: NSMutableAttributedString, rhs: String) { lhs.append(NSAttributedString(string: rhs)) }
