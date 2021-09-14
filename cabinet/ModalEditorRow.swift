// Copyright © 2020 Peogoo. All rights reserved.

class ModalEditorRow<Value> : EditorRow<Value> {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    @IBOutlet fileprivate var imageView: UIImageView!
    @IBOutlet private var topConstraint: NSLayoutConstraint!
    @IBOutlet private var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private var trailingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate var containerView: UIView!
    override class var height: RowHeight { return .auto(estimate: 54) }
    override class var nibName: String { return "PGModalEditorRow" }
    override var isEnabled: Bool { didSet { handleIsEnabledSet() } }

    var _formatter: Formatter?
    var formatter: Formatter? { get { return _formatter } set { _formatter = newValue; handleFormatterSet() } }
    var _attributedFormatter: AttributedFormatter?
    var attributedFormatter: AttributedFormatter? { get { return _attributedFormatter } set { _attributedFormatter = newValue; handleAttributedFormatterSet() } }
    var isPlaceholder: ((Value) -> Bool)? { didSet { updateValueLabel() } }
    var placeholderColor: UIColor = .nonStandardColor(withRGBHex: 0xC8C8C8) { didSet { updateValueLabel() } }
    var editingColor: UIColor = .nonStandardColor(withRGBHex: 0x999999) { didSet { updateValueLabel() } }
    var valueTextColor: UIColor! { didSet { updateValueLabel() } }
    var isChangeTitleLabel: ChangeTitleLabel?
    var edgeInsets: UIEdgeInsets = UIEdgeInsets(horizontal: 16, vertical: 24) { didSet { hanldeEdgeInsetsChanged() } }
    
    typealias Formatter = (Value) -> String
    typealias AttributedFormatter = (Value) -> NSAttributedString
    typealias ChangeTitleLabel = (Value) -> Void
    
    // MARK: Initialization
    convenience init(title: String, initialValue: Value) {
        self.init()
        (self.title, self.value) = (title, initialValue)
    }
    
    // MARK: Initialization
    override func initialize() {
        super.initialize()
        isHighlightable = true
        valueTextColor = valueLabel.textColor
    }
    
    private func handleIsEnabledSet() {}
    
    override func handleIsEditableChanged() {
        isHighlightable = isEditable
    }
    
    func setModalEditor<Editor : ModalEditor>(_ createEditor: @escaping () -> Editor) {
        selectionHandler = { [unowned self] in
            guard self.isEditable else { return }
            let editor = createEditor()
            // Set value
            if let value = self.value as? Editor.Value {
                editor.value = value
            }
            // Link edited handler
            editor.valueEditedHandler = { [unowned self] editorValue in
                self.value = editorValue as! Value
                self.valueEditedHandler?(self.value)
            }
            // Show
            editor.show()
        }
    }
    
    // MARK: Updating
    func updateValueLabel() {
        guard _value != nil || Value.self is AnyOptional.Type else { valueLabel.text = nil; return } // Initialization case, where value has not yet been set for a non-optional type.
        // Color
        if isPlaceholder?(value) ?? false {
            valueLabel.textColor = placeholderColor
        } else if isFirstResponder {
            valueLabel.textColor = editingColor
        } else {
            valueLabel.textColor = valueTextColor
        }
        // Text
        if let attributedFormatter = attributedFormatter {
            valueLabel.attributedText = attributedFormatter(value)
        } else if let formatter = formatter {
            // home loans style
            if isChangeTitleLabel != nil {
                valueLabel.text = ""
                titleLabel.text = formatter(value)
                isChangeTitleLabel!(value)
            } else {
                valueLabel.text = formatter(value)
            }
        } else if let value = value as? String {
            valueLabel.text = value
        } else {
            valueLabel.text = nil
        }
    }
    
    override func handleValueSet() {
        updateValueLabel()
    }

    private func handleFormatterSet() {
        _attributedFormatter = nil
        updateValueLabel()
    }

    private func handleAttributedFormatterSet() {
        _formatter = nil
        updateValueLabel()
    }
    
    private func hanldeEdgeInsetsChanged() {
        leadingConstraint.constant = edgeInsets.left
        trailingConstraint.constant = edgeInsets.right
        topConstraint.constant = edgeInsets.top
        bottomConstraint.constant = edgeInsets.bottom
    }
    
    func reloadTitle() {
        updateValueLabel()
    }
    
    // MARK: Accessors
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var attributedTitle: NSAttributedString? {
        get { return titleLabel.attributedText }
        set { titleLabel.attributedText = newValue }
    }
    
    var titleColor: UIColor {
        get { return titleLabel.textColor }
        set { titleLabel.textColor = newValue }
    }
    
    var font: UIFont? {
        get { return titleLabel.font }
        set { titleLabel.font = newValue }
    }
    
    var valueTitle: String? {
        get { return valueLabel.text }
        set { valueLabel.text = newValue }
    }
    
    var valueFont: UIFont? {
        get { return valueLabel.font }
        set { valueLabel.font = newValue }
    }
    
    var valueTitleColor: UIColor {
        get { return valueLabel.textColor }
        set { valueLabel.textColor = newValue }
    }
    
    var valueLabelNumberOfLines: Int {
        get { return valueLabel.numberOfLines }
        set { valueLabel.numberOfLines = newValue }
    }
}
