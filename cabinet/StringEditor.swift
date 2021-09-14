// Copyright © 2021 evan. All rights reserved.

class StringEditor<Value> : NSObject, Editor, UITextFieldDelegate, UITextViewDelegate  {
    // Text Field
    private(set) var textField: TTTextField?
    private(set) var textView: TTTextView?
    var keyboardType: UIKeyboardType = .default { didSet { updateInputViewProperties() } }
    var autocapitalizationType: UITextAutocapitalizationType = .sentences { didSet { updateInputViewProperties() } }
    var isSecureTextEntry = false { didSet { updateInputViewProperties() } }
    var autocorrectionType: UITextAutocorrectionType = .no { didSet { updateInputViewProperties() } }
    var showDismissalAccessory: Bool = false { didSet { updateInputViewProperties() } }
    var placeholder: String = "" { didSet { updateInputViewProperties() } }
    var returnKeyType: UIReturnKeyType = .default { didSet { updateInputViewProperties() } }
    var returnAction: ActionClosure?
    /// Used to temporarily detach one of the editor from text field/view when there are two editors on the same text field/view.
    var attachable: Bool = true
    /// A closure that can be used to perform attributed string formatting on the text before it is displayed.
    ///
    /// - Warning: This closure should not modify the text, it must only apply string attributes.
    var textAttributer: Attributer? { didSet { handleTextAttributerSet() } }
    var placeholderAttributer: Attributer? { didSet { setTextFieldPlaceholder() } }
    var dismissalInputAccessoryDoneHandler: ValueEditedHandler?
    // Input
    private var decoratedInput: String { return textField?.text ?? "" }
    private(set) var semanticInput: String = ""
    // Value
    var _value: Value {
        didSet { lastEntry = decoratedInput(fromValue: _value) }
    }

    var value: Value { get { return _value } set { setValue(newValue) } }
    var validatedValue: Value { return validate(value: value) == nil ? value : emptyValue }
    /// A handler that will be called whenever the value is changed by the user (even while typing).
    var valueEditedHandler: ValueEditedHandler?
    /// The original value when the text field begins editing. Meant to be set only by the editor delegate.
    private(set) var originalValue: Value?
    private var equalityFunction: EqualityFunction
    private var lastEntry: String?

    /// The value that corresponds to empty input. By default, the placeholder is set to this value.
    var emptyValue: Value {
        if let valueType = Value.self as? AnyOptional.Type { return valueType.any_none as! Value }
        if Value.self == String.self { return "" as! Value }
        return value
    }

    typealias ValueEditedHandler = (Value) -> Void
    typealias Attributer = (String) -> NSAttributedString
    typealias EqualityFunction = (Value, Value) -> Bool

    // MARK: Lifecycle
    init(initialValue: Value, equalityFunction: @escaping EqualityFunction) {
        _value = initialValue
        self.equalityFunction = equalityFunction
        super.init()
        placeholder = decoratedInput(fromValue: emptyValue)
        updateTextFromValue()
        updateTextViewFromValue()
    }

    // MARK: General
    func attach(to textField: TTTextField) {
        self.textView = nil
        self.textField = textField
        updateInputViewProperties()
        updateTextFromValue()
    }

    private func updateInputViewProperties() {
        if let textField = textField {
            textField.keyboardType = keyboardType
            textField.autocapitalizationType = autocapitalizationType
            textField.autocorrectionType = autocorrectionType
            textField.delegate = self
            textField.isSecureTextEntry = isSecureTextEntry
            textField.returnKeyType = returnKeyType
            textField.addTarget(self, action: #selector(valueDidChange(_:)), for: .editingChanged)
            setTextFieldPlaceholder()
        } else if let textView = textView {
            textView.keyboardType = keyboardType
            textView.autocapitalizationType = autocapitalizationType
            textView.autocorrectionType = autocorrectionType
            textView.delegate = self
            textView.isSecureTextEntry = isSecureTextEntry
            textView.returnKeyType = returnKeyType
            setTextViewPlaceholder()
        } else {
            // Do nothing
        }
    }

    private func updateTextFromValue() {
        setTextFieldText(equalityFunction(value, emptyValue) ? "" : decoratedInput(fromValue: value))
        self.semanticInput = semanticInput(fromValue: value)
    }

    private func setTextFieldText(_ text: String?) {
        guard let textField = textField else { return }
        if let text = text, let attributer = textAttributer {
            let attributedText = attributer(text)
            assert(attributedText.string == text, "attributer should not modify the text, it must only apply string attributes.")
            textField.attributedText = attributedText
        } else {
            textField.text = text
        }
    }

    private func setTextFieldPlaceholder() {
        guard let textField = textField else { return }
        if let attributer = placeholderAttributer {
            let attributedPlaceholder = attributer(placeholder)
            assert(attributedPlaceholder.string == placeholder, "attributer should not modify the text, it must only apply string attributes.")
            textField.attributedPlaceholder = attributedPlaceholder
        } else {
            textField.placeholder = placeholder
        }
    }

    private func setValue(_ value: Value) {
        let oldValue = self.value
        // Sanitize
        let value = sanitize(value: value)
        if !shouldAllow(value: value) { }
        // Set
        _value = value
        // Update
        if !(textField?.isEditing == true && equalityFunction(oldValue, value)) {
            updateTextFromValue()
        }
    }

    private func handleTextAttributerSet() {
        guard let textField = textField else { return }
        let selection = textField.selection
        setTextFieldText(textField.text)
        if let selection = selection { textField.select(selection) }
    }

    @objc
    private func valueDidChange(_ textField: UITextField) {
        handleTextDidChange(textField.text)
    }

    private func handleTextDidChange(_ text: String?) {
        guard attachable else { return }
        let decoratedText = text ?? ""
        // Convert to semantic
        let semanticText = self.semanticEdit(fromDecoratedEdit: decoratedText)
        // Validate new input & value
        guard shouldAllow(semanticInput: semanticText) else { return }
        let newValue = self.value(fromSemanticInput: semanticText)
        guard shouldAllow(value: newValue) else { return }
        // Update
        semanticInput = semanticText
        self._value = newValue
        valueEditedHandler?(value)
    }

    // MARK: Text Field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {
        guard attachable else { return true }
        return shouldChangeText(in: range, text: textField.text, replacementText: replacementString, inputView: textField)
    }

    // TODO: Modify selection on begin editing to fix cursor position when we have a suffix?
    func textFieldDidBeginEditing(_ textField: UITextField) {
        originalValue = value
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateTextFromValue()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let returnAction = returnAction {
            returnAction()
        } else if let nextInput = textField.nextInput {
            nextInput.becomeFirstResponder()
        }
        return true
    }

    // MARK: Decorated <=> Semantic
    func semanticInput(fromDecoratedInput decoratedInput: String, selection decoratedSelection: Range<String.Index>) -> (String, Range<String.Index>) {
        return (decoratedInput, decoratedSelection)
    }

    func decoratedInput(fromSemanticInput semanticInput: String, selection semanticSelection: Range<String.Index>) -> (String, Range<String.Index>) {
        return (semanticInput, semanticSelection)
    }

    func semanticEdit(fromDecoratedEdit edit: String) -> String {
        return edit
    }

    func performSemanticEdit(_ edit: String, on input: String, selection: Range<String.Index>) -> (String, Range<String.Index>)? {
        let newInput = input.replacingCharacters(in: selection, with: edit)
        let currentText: String = textView?.text ?? textField?.text ?? ""
        if semanticInput(fromDecoratedInput: currentText) != semanticInput, !shouldAllow(semanticInput: newInput) { // Probably we are in a state with pasted text
            let newText: String = {
                guard shouldAllow(semanticInput: edit) else { return semanticInput(fromValue: emptyValue) } // Resetting
                return edit // Applying the edit in the whole string
            }()
            return (newText, newText.endIndex..<newText.endIndex)
        }
        let newUTF16Index = String.Index(utf16Offset: selection.lowerBound.utf16Offset(in: newInput) + edit.utf16.count, in: newInput)
        let newCursorIndex = newUTF16Index != newInput.utf16.endIndex ? newInput.rangeOfComposedCharacterSequence(at: newUTF16Index).lowerBound : newInput.endIndex
        return (newInput, newCursorIndex..<newCursorIndex)
    }

    // MARK: Value <=> Semantic
    func value(fromSemanticInput input: String) -> Value {
        precondition(Value.self == String.self, "Subclasses must override this method if Value is any type other than String.")
        return input as! Value
    }

    func semanticInput(fromValue value: Value) -> String {
        precondition(Value.self == String.self, "Subclasses must override this method if Value is any type other than String.")
        return value as! String
    }

    // MARK: Validation
    /// Returns whether the given semantic input should be allowed to occur.
    ///
    /// By default, the editor stops any edits that result in a semantic input for which this method returns `false`.
    func shouldAllow(semanticInput input: String) -> Bool { return true }

    /// Returns whether the value should be allowed to occur in the text field.
    ///
    /// By default, the editor stops any edits that result in a value for which this method returns `false`.
    func shouldAllow(value: Value) -> Bool { return true }

    /// Constrains the value to a normalized allowable value.
    ///
    /// Subclasses should override this method if not all values are allowed and/or any value has a normalized form.
    /// This sanitization will automatically be applied to any value set programmatically.
    /// - Note: The returned value is required to pass `shouldAllow(value:)`, but not necessarily `validate(value:)`.
    func sanitize(value: Value) -> Value { return value }

    /// Validates the value and returns an error if it does not pass validation.
    ///
    /// This is generally not called by the editor itself but by the consumer of the editor,
    /// and shown in the UI (by the caller) only when the user tries to continue w the invalid value, i.e. not as-you-type.
    ///
    /// Subclasses can override to provide error-based validation. The return error should contains descriptions
    /// suitable for display to the user.
    func validate(value: Value) -> Error? { return nil }

    // MARK: Convenience
    // If you implemented the required methods listed under subclassing notes, these methods will automatically work.

    func semanticInput(fromDecoratedInput input: String) -> String {
        let dummySelection = input.endIndex..<input.endIndex
        let (result, _) = semanticInput(fromDecoratedInput: input, selection: dummySelection)
        return result
    }

    func decoratedInput(fromSemanticInput input: String) -> String {
        let dummySelection = input.endIndex..<input.endIndex
        let (result, _) = decoratedInput(fromSemanticInput: input, selection: dummySelection)
        return result
    }

    func value(fromDecoratedInput input: String) -> Value {
        return value(fromSemanticInput: semanticInput(fromDecoratedInput: input))
    }

    func decoratedInput(fromValue value: Value) -> String {
        return decoratedInput(fromSemanticInput: semanticInput(fromValue: value))
    }

    // MARK: UITextView
    func attach(to textView: TTTextView) {
        guard !isSecureTextEntry else { preconditionFailure("`isSecureTextEntry` is only compatible with UITextField, please use that instead.") }
        self.textField = nil
        self.textView = textView
        updateInputViewProperties()
        updateTextViewFromValue()
    }

    private func updateTextViewFromValue() {
        setTextViewText(equalityFunction(value, emptyValue) ? "" : decoratedInput(fromValue: value))
    }

    private func setTextViewText(_ text: String?) {
        guard let textView = textView else { return }
        if let text = text, let attributer = textAttributer {
            let attributedText = attributer(text)
            assert(attributedText.string == text, "attributer should not modify the text, it must only apply string attributes.")
            textView.attributedText = attributedText
        } else {
            textView.text = text
        }
    }

    private func setTextViewPlaceholder() {
        guard let textView = textView else { return }
        if let attributer = placeholderAttributer {
            let attributedPlaceholder = attributer(placeholder)
            assert(attributedPlaceholder.string == placeholder, "attributer should not modify the text, it must only apply string attributes.")
            textView.attributedPlaceholder = attributedPlaceholder
        } else {
            textView.placeholder = placeholder
        }
    }

    // MARK: TextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return shouldChangeText(in: range, text: textView.text, replacementText: text, inputView: textView)
    }

    func textViewDidChange(_ textView: UITextView) {
        handleTextDidChange(textView.text)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        originalValue = value
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        updateTextViewFromValue()
    }

    // MARK: General
    private func shouldChangeText(in range: NSRange, text: String?, replacementText: String, inputView: UIView) -> Bool {
        lastEntry = replacementText
        // TODO: Fix it in a better place (ZLNumberEditor, maybe)
        // Fix that user can input non-digits key on iPad(or hardware keyboard) with Chinese keyboard as there is no number only keyboard on iPad.
        let (allowDigitsOnly, isNumberPadKey): (Bool, Bool) = {
            let isDecimalType = Value.self == Decimal.self
            let isDigitType = Value.self == Int.self || Value.self == Double.self || Value.self == CGFloat.self || Value.self == Float.self
            let allowDigitsOnly = isDecimalType || isDigitType
            let isNumberPadKey =
                (isDigitType && Double(replacementText) != nil) ||
                (isDecimalType && Decimal(string: replacementText) != nil)
            return (allowDigitsOnly, isNumberPadKey)
        }()
        // Don't allow Chinese and Japanese keyboards performing custom changes as the Chinese/Japanese keyboards are completed broken by performing the custom change.
        let keyboardPrimaryLanguage = (inputView as UIResponder).textInputMode?.primaryLanguage?.lowercased() ?? ""
        // Keyboards which the `replacementString` is not match the value user typed.
        let isWeirdKeyboard = keyboardPrimaryLanguage.contains("zh") || keyboardPrimaryLanguage.contains("ja")
        // When the Chinese keyboard's type is `emailAddress`, we're not going to use semantic value.
        if let textView = inputView as? UITextView {
            if isWeirdKeyboard && textView.keyboardType == .emailAddress {
                return true
            }
        } else if let textField = inputView as? UITextField {
            if isWeirdKeyboard && textField.keyboardType == .emailAddress {
                return true
            }
        } else { 🔥 } // Will never happen

        // We allow localized decimal separator and normalize it in the NumberEditor
        if !replacementText.isEmpty && replacementText != NSLocale.current.decimalSeparator {
            if allowDigitsOnly {
                if !isNumberPadKey { return false }
            }
        }
        // TODO: Rejected paste still modifies the cursor position
        let decoratedInput = (text ?? "")
        let decoratedSelection = String.Index(utf16Offset: range.lowerBound, in: decoratedInput)..<String.Index(utf16Offset: range.upperBound, in: decoratedInput)
        let decoratedEdit = replacementText
        // Convert to semantic
        let (semanticInput, semanticSelection) = self.semanticInput(fromDecoratedInput: decoratedInput, selection: decoratedSelection)
        let semanticEdit = self.semanticEdit(fromDecoratedEdit: decoratedEdit)
        // Perform edit
        guard let (newSemanticInput, _) = performSemanticEdit(semanticEdit, on: semanticInput, selection: semanticSelection) else { return false }
        // Validate new input & value
        guard shouldAllow(semanticInput: newSemanticInput) else { return false }
        let newValue = self.value(fromSemanticInput: newSemanticInput)
        guard shouldAllow(value: newValue) else { return false }
        self.semanticInput = newSemanticInput
        _value = newValue
        valueEditedHandler?(value)
        return true
    }
}

extension StringEditor where Value : Equatable {
    convenience init(initialValue: Value) {
        self.init(initialValue: initialValue, equalityFunction: ==)
    }
}

// MARK: Utility
private extension UITextInput {
    func select(in range: Range<String.Index>, with text: String?) {
        let nsRange = NSRange(range, in: text ?? "")
        let start = self.position(from: self.beginningOfDocument, offset: nsRange.location)!
        let end = self.position(from: start, offset: nsRange.length)!
        self.selectedTextRange = self.textRange(from: start, to: end)
    }
}
