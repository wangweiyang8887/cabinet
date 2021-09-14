// Copyright © 2021 evan. All rights reserved.

class TTTextView : UITextView {
    var placeholder: String? { didSet { updateTextViewText() } }
    var attributedPlaceholder: NSAttributedString? { didSet { updateTextViewText() } }
    var textChangedHandler: ((String) -> Void)? { didSet { observer.onTextViewTextDidChange { [weak self] in self?.textChangedHandler?($0.text) } } }
    var willReplaceWithTextInRangeHandler: TextViewObserver.TextViewWillReplaceWithTextInRange? { didSet { given(willReplaceWithTextInRangeHandler) { observer.onTextViewWillReplaceTextInRangeSelection($0) } } }
    var placeholderTextColor: UIColor? {
        set { fakePlaceholderTextView.textColor = newValue }
        get { return fakePlaceholderTextView.textColor }
    }

    override var text: String! { didSet { updateTextViewText() } }
    override var attributedText: NSAttributedString! { didSet { updateTextViewText() } }
    override var font: UIFont? { didSet { updateFontIfNeeded() } }
    private lazy var observer: TextViewObserver = TextViewObserver(textView: self)

    // MARK: Initialize
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        observer.onTextViewTextDidChange { [weak self] _ in self?.updateTextViewText() }
        fakePlaceholderTextView.textAlignment = textAlignment
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        fakePlaceholderTextView.frame = bounds
    }

    // MARK: Components
    private lazy var fakePlaceholderTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .nonStandardColor(withRGBHex: 0xE9E9E9)
        textView.backgroundColor = nil
        textView.isEditable = false
        textView.isSelectable = false
        textView.isUserInteractionEnabled = false
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        addSubview(textView)
        return textView
    }()

    // MARK: Convenience
    private var shouldShowPlaceholder: Bool {
        return text.nilIfEmpty == nil
    }

    private func updateFontIfNeeded() {
        // If it's using attributed placeholder, we shouldn't touch the font
        guard attributedPlaceholder == nil else { return }
        fakePlaceholderTextView.font = font
    }

    private func updateTextViewText() {
        fakePlaceholderTextView.isHidden = !shouldShowPlaceholder
        guard shouldShowPlaceholder else { return }
        fakePlaceholderTextView.textContainerInset = textContainerInset
        fakePlaceholderTextView.textContainer.lineFragmentPadding = textContainer.lineFragmentPadding
        if let attributed = attributedPlaceholder {
            fakePlaceholderTextView.attributedText = attributed
        } else {
            updateFontIfNeeded()
            fakePlaceholderTextView.text = placeholder
            fakePlaceholderTextView.textColor = placeholderTextColor
        }
    }
}

extension TTTextView {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(cut(_:)) || action == #selector(copy(_:)) || action == #selector(paste(_:)) { return true }
        return false
    }
}
