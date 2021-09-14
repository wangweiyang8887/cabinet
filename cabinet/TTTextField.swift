// Copyright © 2021 evan. All rights reserved.

final class TTTextField : UITextField {
    weak var decoratedInputProvider: DecoratedInputProvider?

    /// The insets for text field
    var insets: UIEdgeInsets = .zero

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds).inset(by: insets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds).inset(by: insets)
    }

    /// Adds a button in the text field's right view that toggles the `isSecureEntry` property.
    func addPasswordVisibilityToggle() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        button.action = TTButtonAction(icon: nil, block: { [unowned self] in
            self.isSecureTextEntry.toggle()
            // Hack because UITextField doesn't recalculate text width
            if let range = self.textRange(from: self.beginningOfDocument, to: self.endOfDocument) {
                self.replace(range, withText: self.text!)
            }
        })
        rightView = button
        rightViewMode = .whileEditing
    }

    /// Used to disable auto fill suggestions
    func disableAutoFillSuggestions() {
        textContentType = .none
    }

//    private func accessoryButtonImage() -> UIImage {
//        return isSecureTextEntry ? #imageLiteral(resourceName: "password-eye") : #imageLiteral(resourceName: "password-eye-closed")
//    }

}

extension TTTextField {
    var selection: Range<String.Index>? {
        guard let selectedTextRange = selectedTextRange, let text = text else { return nil }
        let startOffset = offset(from: beginningOfDocument, to: selectedTextRange.start)
        let length = offset(from: selectedTextRange.start, to: selectedTextRange.end)
        return String.Index(utf16Offset: startOffset, in: text)..<String.Index(utf16Offset: startOffset + length, in: text)
    }
}

// MARK: Custom Copy, Cut and Paste Methods
extension TTTextField {
    public override func copy(_ sender: Any?) {
        // If there's no selection, there's nothing to be copied.
        guard let selection = selection, let text = text else { return }
        let selectedText = String(text[selection.lowerBound...text.index(before: selection.upperBound)])
        var target: String?
        if let provider = decoratedInputProvider {
            // Coping always the semantic value
            target = provider.semanticInput(fromDecoratedInput: selectedText, selection: selection).0
        } else {
            target = selectedText
        }
        UIPasteboard.general.string = target
    }

    // The original implementation of Cut doesn't work alongside string editors. So we override its implementation and customize it.
    public override func cut(_ sender: Any?) {
        // Don't call super() because it crashes (for an unknown reason).
        // If there's no selection, there's nothing to be cut.
        guard let selection = selection else { return }
        // Copy the content to UIPasteboard.general, as the cut method normally would.
        copy(sender)
        // Then we update the information relevant to the string editor.
        let range = NSRange(selection, in: text ?? "")
        if delegate?.textField?(self, shouldChangeCharactersIn: range, replacementString: "") ?? true {
            text = self.text?.replacingCharacters(in: selection, with: "")
            sendActions(for: .editingChanged)
        }
    }

    override func paste(_ sender: Any?) {
        // Selection will always exist. If there is no text selected, its value is a Range with lowerBounds == upperBounds representing the cursor position
        guard let text = UIPasteboard.general.string, let selection = selection else { return }
        var target: String
        if let provider = decoratedInputProvider {
            // Get the current semantic text and the correspondent selection over it
            let (currentSemanticText, semanticSelection) = provider.semanticInput(fromDecoratedInput: self.text ?? "", selection: selection)
            // Get the new semantic text and paste it in the current semantic text
            let newSemanticText = provider.semanticInput(fromDecoratedInput: text, selection: text.startIndex..<text.endIndex).0
            let finalText = currentSemanticText.replacingCharacters(in: semanticSelection, with: newSemanticText)
            // Get the final decorated text
            let decoratedInput = provider.decoratedInput(fromSemanticInput: finalText, selection: finalText.startIndex..<finalText.endIndex).0
            target = decoratedInput
        } else {
            let currentText = self.text ?? ""
            target = currentText.replacingCharacters(in: selection, with: text)
        }
        // Set text and trigger the editingChanged event
        self.text = target
        sendActions(for: .editingChanged)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(cut(_:)) || action == #selector(copy(_:)) || action == #selector(paste(_:)) { return true }
        return false
    }
}

// MARK: Decorated Input Provider Protocol
protocol DecoratedInputProvider : AnyObject {
    func semanticInput(fromDecoratedInput decoratedInput: String, selection decoratedSelection: Range<String.Index>) -> (String, Range<String.Index>)
    func decoratedInput(fromSemanticInput semanticInput: String, selection semanticSelection: Range<String.Index>) -> (String, Range<String.Index>)
}
