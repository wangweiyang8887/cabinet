// Copyright © 2021 evan. All rights reserved.

class TextRow : BaseRow {
    private var bottomConstraint: NSLayoutConstraint!
    private var topConstraint: NSLayoutConstraint!
    private var leftConstraint: NSLayoutConstraint!
    private var rightConstraint: NSLayoutConstraint!
    // The four margin below is in content, their names are more suitable for `edge inset`.
    var bottomMargin: CGFloat {
        get { return edgeInsets.bottom }
        set { edgeInsets.bottom = newValue }
    }

    var topMargin: CGFloat {
        get { return edgeInsets.top }
        set { edgeInsets.top = newValue }
    }

    var leftMargin: CGFloat {
        get { return edgeInsets.left }
        set { edgeInsets.left = newValue }
    }

    var rightMargin: CGFloat {
        get { return edgeInsets.right }
        set { edgeInsets.right = newValue }
    }

    var edgeInsets: UIEdgeInsets = UIEdgeInsets(horizontal: 16, vertical: 12) { didSet { handleMarginsChanged() } }

    // MARK: Settings
    override class var height: RowHeight { return .auto(estimate: 98) }
    override class var style: Style { return .separatorless }

    // MARK: Initialization
    convenience init(text: String, font: UIFont = .systemFont(ofSize: 15), icon: UIImage? = nil) {
        self.init()
        self.text = text
        self.icon = icon
        self.font = font
    }

    convenience init(attributedText: NSAttributedString, font: UIFont = .systemFont(ofSize: 15)) {
        self.init()
        self.attributedText = attributedText
        self.font = font
    }

    required init() { super.init() }
    required init?(coder: NSCoder) { 🔥 }

    override func initialize() {
        super.initialize()
        self.icon = nil
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        leftConstraint = stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16)
        topConstraint = stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12)
        bottomConstraint = contentView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 12)
        rightConstraint = contentView.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: 16)
        [ topConstraint, bottomConstraint, leftConstraint, rightConstraint ].forEach { $0?.isActive = true }
    }

    // MARK: Components
    private lazy var stackView = UIStackView(axis: .horizontal, distribution: .fill, alignment: .center, spacing: 16, arrangedSubviews: [ iconImageView, textView ])

    private lazy var iconImageView: UIImageView = {
        let result = UIImageView()
        result.constrainSize(to: CGSize(uniform: 24))
        return result
    }()

    private lazy var textView: TTHyperlinkTextView = {
        let result = TTHyperlinkTextView(frame: .zero)
        result.shouldInteractWithURL = { [unowned self] in
            UIApplication.shared.canOpenURL($0)
            return false
        }
        result.textContainerInset = .zero
        result.textContainer.lineFragmentPadding = 0
        result.textContainer.lineBreakMode = .byTruncatingTail
        result.backgroundColor = .clear
        result.isUserInteractionEnabled = false
        result.textColor = .cabinetBlack
        return result
    }()

    // MARK: Accessors
    var textViewCenterYAnchor: NSLayoutYAxisAnchor {
        return textView.centerYAnchor
    }

    var text: String? {
        get { return textView.text }
        set { textView.text = newValue; invalidateLayout() }
    }

    var attributedText: NSAttributedString? {
        get { return textView.attributedText }
        set { textView.attributedText = newValue; invalidateLayout() }
    }

    var textAlignment: NSTextAlignment {
        get { return textView.textAlignment }
        set { textView.textAlignment = newValue }
    }

    var textColor: UIColor? {
        get { return textView.textColor }
        set { textView.textColor = newValue }
    }

    var icon: UIImage? {
        get { return iconImageView.image }
        set { iconImageView.image = newValue; iconImageView.isHidden = (newValue == nil) }
    }

    var font: UIFont? {
        get { return textView.font }
        set { textView.font = newValue }
    }

    var numberOfLines: Int {
        get { return textView.textContainer.maximumNumberOfLines }
        set { textView.textContainer.maximumNumberOfLines = newValue }
    }

    // MARK: Updating
    private func handleMarginsChanged() {
        bottomConstraint.constant = bottomMargin
        topConstraint.constant = topMargin
        leftConstraint.constant = leftMargin
        rightConstraint.constant = rightMargin
        collectionView?.reloadData() // TODO: Implement partial load when available
    }

    // MARK: Actions
    func setText(_ text: String, links: [TTHyperlinkTextView.Link]) {
        textView.isUserInteractionEnabled = true
        textView.setText(text, links: links)
    }

    func setAttributedText(_ attributedText: NSAttributedString, links: [TTHyperlinkTextView.Link]) {
        textView.isUserInteractionEnabled = true
        textView.setAttributedText(attributedText, links: links)
    }
}

final class BackgroundlessTextRow : TextRow {
    override class var style: Style { return .backgroundless }
}
