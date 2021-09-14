// Copyright © 2021 evan. All rights reserved.

import Foundation

public final class TTHyperlinkTextView : UITextView {
    private var ranges: [NSRange] = []
    private var links: [Link] = []
    public var shouldInteractWithURL: ((URL) -> Bool)?
    public var selectionHandler: ActionClosure?

    // MARK: Nested Types
    public struct Link {
        public let text: String
        public let color: UIColor
        public let action: ActionClosure

        public init(text: String, color: UIColor = .blue, action: @escaping ActionClosure) {
            self.text = text
            self.color = color
            self.action = action
        }
    }

    // MARK: Initialization
    override init(frame: CGRect, textContainer: NSTextContainer?) { super.init(frame: frame, textContainer: textContainer); initialize() }
    required init?(coder: NSCoder) { super.init(coder: coder); initialize() }

    private func initialize() {
        dataDetectorTypes = .link
        isScrollEnabled = false
        isEditable = false
        isSelectable = false
        isUserInteractionEnabled = true
        linkTextAttributes = [ .foregroundColor : UIColor.blue ]
        textColor = .black
        font = .systemFont(ofSize: 14)
        delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }

    // MARK: Actions
    @objc private func handleTap(_ tapRecognizer: UITapGestureRecognizer) {
        // TODO: Hack around to improve tappable area
        let point = tapRecognizer.location(in: self)
        let characterIndex = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        guard characterIndex < textStorage.length else { return }
        guard let indexOfFirstRangeThatContainsCharacterIndex = (ranges.indexOfFirst { $0.contains(characterIndex) }) else { selectionHandler?(); return }
        guard let link = links[ifPresent: indexOfFirstRangeThatContainsCharacterIndex] else { selectionHandler?(); return }
        link.action()
    }

    // MARK: Updating
    public func setAttributedText(_ attributedText: NSAttributedString, links: [Link]) {
        self.links = links
        let attributedText = NSMutableAttributedString(attributedString: attributedText)
        ranges = links.map {
            let range = (attributedText.string as NSString).range(of: $0.text)
            attributedText.addAttribute(.foregroundColor, value: $0.color, range: range)
            return range
        }
        self.attributedText = attributedText
    }

    public func setText(_ text: String, links: [Link]) {
        let attributedText = NSMutableAttributedString(string: text)
        let attributes: [NSAttributedString.Key:Any] = [ .font : font!, .foregroundColor : textColor! ]
        attributedText.addAttributes(attributes, range: NSRange(location: 0, length: attributedText.string.count))
        setAttributedText(attributedText, links: links)
    }
}

extension TTHyperlinkTextView : UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return shouldInteractWithURL?(URL) ?? false
    }
}
