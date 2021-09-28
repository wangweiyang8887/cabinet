// Copyright © 2020 PeoGooCore. All rights reserved.

import Foundation
import CoreGraphics
import UIKit

// MARK: General
extension String {
    public func trimmed() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var trimmedNilIfEmpty: String? {
        let result = trimmed()
        return result.isEmpty ? nil : result
    }

    public func deletePathExtension() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    /// Returns the size required to draw the string given a certain width and height constraint, wrapping as necessary.
    ///
    /// The returned size might break the constraints (typically the height constraint) if there is not enough space to fit the entire string.
    /// - Parameter isUsedToSizeView: To use the return value to size a view, set this parameter to true and the result will be rounded up to the nearest integer.
    public func size(maxWidth: CGFloat = .greatestFiniteMagnitude, maxHeight: CGFloat = .greatestFiniteMagnitude, attributes: [NSAttributedString.Key:Any]? = nil, isUsedToSizeView: Bool, enforceStyle: Bool = true) -> CGSize {
        let maxSize = CGSize(width: maxWidth, height: maxHeight)
        var result = self.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
        if isUsedToSizeView { result = CGSize(width: ceil(result.width), height: ceil(result.height)) }
        return result
    }

    public var alphanumericAndEmojiOnlyString: String {
        return filter { char in char.isEmoji || char.isAlphanumeric }
    }


    func indices(of occurrence: String) -> [Int] {
        var indices = [Int]()
        var position = startIndex
        while let range = range(of: occurrence, range: position..<endIndex) {
            let i = distance(from: startIndex, to: range.lowerBound)
            indices.append(i)
            let offset = occurrence.distance(from: occurrence.startIndex, to: occurrence.endIndex) - 1
            guard let after = index(range.lowerBound, offsetBy: offset, limitedBy: endIndex) else { break }
            position = index(after: after)
        }
        return indices
    }

    public func ranges(of searchString: String) -> [Range<String.Index>] {
        let _indices = indices(of: searchString)
        let count = searchString.count
        return _indices.map { index(startIndex, offsetBy: $0)..<index(startIndex, offsetBy: $0 + count) }
    }

    public func countInstances(of stringToFind: String) -> Int {
        var stringToSearch = self
        var count = 0
        while let foundRange = stringToSearch.range(of: stringToFind, options: .diacriticInsensitive) {
            stringToSearch = stringToSearch.replacingCharacters(in: foundRange, with: "")
            count += 1
        }
        return count
    }

    /// Compute the initials of self, i.e. the first letter of the first and last words. Minimum of 1 character, maximum of 2, and returns a `👤` if the string is empty. This utility does take emojis into consideration.
    public var initials: String {
        var result: String = ""
        // Not using NSStringEnumerationByWords because it doesn't take emoji into consideration
        let words = components(separatedBy: CharacterSet.whitespacesAndNewlines).compactMap { substring -> String? in
            let normalizedString = substring.alphanumericAndEmojiOnlyString
            return normalizedString.trimmedNilIfEmpty
        }
        // Get first letter of the first and last word
        if let firstWord = words.first as NSString? {
            // Get character range to handle emoji (emojis consist of 2 characters in sequence)
            let firstLetterRange = firstWord.rangeOfComposedCharacterSequences(for: NSRange(location: 0, length: 1))
            result += firstWord.substring(with: firstLetterRange)
            if words.count >= 2, let lastWord = words.last as NSString? {
                // Get character range to handle emoji (emojis consist of 2 characters in sequence)
                let lastLetterRange = lastWord.rangeOfComposedCharacterSequences(for: NSRange(location: 0, length: 1))
                result += lastWord.substring(with: lastLetterRange)
            }
        }
        guard !result.isEmpty else { return "👤" }
        return result.uppercased()
    }
}

extension Character {
    /// Whether the current character is an emoji. This method embeds a lot of different logic to cover all the false positives and false negatives not properly handled by Foundation's UnicodeScalar emoji utilities.
    public var isEmoji: Bool {
        if unicodeScalars.count == 1 {
            let scalar = unicodeScalars.first!
            switch scalar.value {
            case 0x1F321...0x1F6F3: return true // Emojis are not following these rules 👁🗣🕶🕷🕸🕊🐿🌪🌤🌥🌦🌧🌩🌨🌬🌫🌶🍽🎖🏵🎗🎟🏎🏍🛩🛰🛥🛳🗺🏟🏖🏝🏜🏔🏕🏘🏚🏗🏛🛤🛣🏞🏙🖥🖨🖱🖲🕹🗜📽🎞🎙🎚🎛🕰🕯🗑🛢🛠🗡🛡🕳🌡🛎🗝🛋🛏🖼🛍🏷🗒🗓🗃🗳🗄🗂🗞🖇🖊🖋🖌🖍🕉🗯
            default: if scalar.isASCII { return false }
            }
        }
        if (unicodeScalars.contains { $0.properties.isVariationSelector }) { return true }
        if unicodeScalars.count > 2 && (unicodeScalars.contains { $0.properties.isJoinControl }) { return true }
        return unicodeScalars.allMatch {
            $0.properties.isEmojiPresentation ||
                $0.properties.isEmojiModifier ||
                $0.properties.isEmojiModifierBase ||
                $0.properties.isDefaultIgnorableCodePoint || // 🏴󠁧󠁢󠁥󠁮󠁧󠁿 🏴󠁧󠁢󠁳󠁣󠁴󠁿 🏴󠁧󠁢󠁷󠁬󠁳󠁿
                ($0.properties.isEmoji && $0.properties.isPatternSyntax)
        }
    }
    
    public var isChinese: Bool {
        if unicodeScalars.count == 1 {
            let scalar = unicodeScalars.first!
            switch scalar.value {
            case 0x4e00...0x9fff: return true
            default: return false
            }
        }
        return false
    }

    /// Whether the current caracter is an `alphanumeric` character.
    public var isAlphanumeric: Bool {
        let characterSet = CharacterSet.alphanumerics
        let string = String(self)
        return string.rangeOfCharacter(from: characterSet) != nil
    }
    
    /// Whether the current caracter is a `decimalDigits` character.
    public var isDigital: Bool {
        let characterSet = CharacterSet.decimalDigits
        let string = String(self)
        return string.rangeOfCharacter(from: characterSet) != nil
    }
}

// MARK: Localization
extension String {
    /// Get a formatted string based on the number passed.
    /// - parameter format: `NSLocalizedString` containing one `%@` for where the conditionalized numbered string goes, e.g. `NSLocalizedString(@"You Have %@", nil)`, or simply `"%@"` (the default) without `NSLocalizedString` if there're no other words to be localized.
    /// - parameter number: The number you want to conditionalize on.
    /// - parameter zero: `NSLocalizedString` containing no placeholders (optional), e.g. `NSLocalizedString(@"No Friend", nil)`.
    /// - parameter singular: `NSLocalizedString` containing no placeholders, `e.g. NSLocalizedString(@"One Friend", nil)`.
    /// - parameter pluralFormat: `NSLocalizedString` containing one `%@` for where the conditionalized number goes, e.g. `NSLocalizedString(@"%@ Friends", nil)`.
    public init(format: String = "%@", number: Decimal, zero: String? = nil, singular: String, pluralFormat: String) {
        let numberString: String
        if number == 0, let zero = zero {
            numberString = zero
        } else if abs(number) == 1 {
            numberString = singular
        } else {
            numberString = String(format: pluralFormat, number as NSNumber)
        }
        self = String(format: format, numberString)
    }

    public init(format: String = "%@", number: Int, zero: String? = nil, singular: String, pluralFormat: String) {
        self.init(format: format, number: Decimal(number), zero: zero, singular: singular, pluralFormat: pluralFormat)
    }
}

extension StringProtocol where Index == String.Index {
    public func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}

extension String {
    public func image(withAttributes attributes: [NSAttributedString.Key:Any]) -> UIImage? {
        let size = (self as NSString).size(withAttributes: attributes)
        return UIGraphicsImageRenderer(size: size).image { _ in (self as NSString).draw(in: CGRect(origin: .zero, size: size), withAttributes: attributes) }
    }
    
    public var isValidPhoneNumber: Bool {
        if(self.isEmpty || self.count != 11) { return false }
        let mobile_regular = "^1[1-9]\\d{9}$"
        let regex: NSPredicate = NSPredicate(format: "SELF MATCHES %@", mobile_regular)
        return regex.evaluate(with: self)
    }
    
    /// Currently used to cover the middle four digits of the phone number, also we can cover the others
    public func coverd(by string: String, in range: NSRange = NSRange(location: 3, length: 4)) -> String {
        let text = self as NSString
        return text.replacingCharacters(in: range, with: string)
    }
}
