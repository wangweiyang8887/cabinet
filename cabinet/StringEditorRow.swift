// Copyright © 2020 Peogoo. All rights reserved.

class StringEditorRow<Value> : EditorRow<Value> {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var valueTextField: TTTextField!
    @IBOutlet private(set) var rightStackView: UIStackView!
    
    override class var nibName: String? { return "StringEditorRow" }
    override class var height: RowHeight { .fixed(64) }
    
    var editor: StringEditor<Value>? { didSet { if editor != oldValue { handleEditorChanged() } } }
    var validatedValue: Value { return editor!.validatedValue }
    override func initialize() {
        super.initialize()
        (title, valueTextField.text) = (nil, nil) // clean
        let gestureView = UIView()
        gestureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        gestureView.backgroundColor = .clear
        contentView.addSubview(gestureView, pinningEdges: .all)
        handleEditorChanged()
    }
    
    @objc
    private func handleTap() {
        guard isEditable, isEnabled else { return }
        if let handler = selectionHandler {
            handler()
        } else {
            startEditing()
        }
        handleDidSelect()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let rightView = valueTextField.rightView, rightView.point(inside: convert(point, to: rightView), with: event) {
            return rightView
        }
        
        if let stackView = rightStackView {
            let newPoint = convert(point, to: stackView)
            if stackView.point(inside: newPoint, with: event) {
                return stackView.hitTest(newPoint, with: event)
            }
        }
        return super.hitTest(point, with: event)
    }
    
    private func startEditing() {
        valueTextField.becomeFirstResponder()
    }
    
    private func handleValueEdited(_ value: Value) {
        _value = value
        valueEditedHandler?(value)
    }
    
    private func handleEditorChanged() {
        guard let editor = editor else { return }
        editor.attach(to: valueTextField)
        editor.showDismissalAccessory = true
        editor.value = value
        editor.valueEditedHandler = { [weak self] in self?.handleValueEdited($0) }
    }
    
    override func handleValueSet() {
        editor?.value = value
    }
    
    override func handleIsEditableChanged() {
        isUserInteractionEnabled = isEditable
        if !isEditable && valueTextField.isFirstResponder { valueTextField.resignFirstResponder() }
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return valueTextField.becomeFirstResponder()
    }
    
    // MARK: Accessors
    var title: String? {
        get { return titleLabel?.text }
        set { titleLabel?.text = newValue; titleLabel?.isHidden = (newValue == nil) }
    }

    var titleColor: UIColor? {
        get { return titleLabel.textColor }
        set { titleLabel.textColor = newValue }
    }
    
    var titleFont: UIFont? {
        get { return titleLabel.font }
        set { titleLabel.font = newValue }
    }

    var valueColor: UIColor? {
        get { return valueTextField.textColor }
        set { valueTextField.textColor = newValue }
    }

    var attributedTitle: NSAttributedString? {
        get { return titleLabel?.attributedText }
        set { titleLabel?.attributedText = newValue; titleLabel?.isHidden = (newValue == nil) }
    }
}
