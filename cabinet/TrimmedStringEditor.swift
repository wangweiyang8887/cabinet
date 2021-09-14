// Copyright © 2021 evan. All rights reserved.

class TrimmedStringEditor : StringEditor<String?> {
    var charLimit: Int?
    var allowEmojis: Bool = false // 是否允许输入表情
    var allowWhitespace: Bool = true // 是否允许输入空格
    var allowAlphanumeric: Bool = true // 是否允许输入符号

    init(charLimit: Int? = nil) {
        super.init(initialValue: nil, equalityFunction: ==)
        self.charLimit = charLimit
    }

    override func value(fromSemanticInput input: String) -> String? {
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedInput.isEmpty ? trimmedInput : nil
    }

    override func semanticInput(fromValue value: String?) -> String {
        return value ?? ""
    }
    
    override func shouldAllow(semanticInput input: String) -> Bool {
        return !(input.last?.isWhitespace ?? false) || allowWhitespace
    }
    
    override func shouldAllow(value: String?) -> Bool {
        guard let value = value else { return true }
        if !allowEmojis && value.contains(where: { $0.isEmoji }) { return false }
        if !allowAlphanumeric && value.contains(where: { !$0.isAlphanumeric && !$0.isWhitespace }) { return false }
        if let charLimit = charLimit { return value.count <= charLimit }
        return true
    }

    override func sanitize(value: String?) -> String? {
        var value = value?.trimmedNilIfEmpty
        given(value, charLimit) { value = String($0.prefix($1)) }
        return value?.trimmedNilIfEmpty // Retrim because char limit cut off might've left trailing whitespace
    }
}

extension StringEditor {
    static func titleEditor() -> TrimmedStringEditor {
        let editor = TrimmedStringEditor()
        editor.autocapitalizationType = .words
        return editor
    }
}

class IPAddressEditor : TrimmedStringEditor {
    init(placeholder: String = "") {
        super.init()
        keyboardType = .default
        returnKeyType = .done
        self.placeholder = placeholder
        charLimit = 20
    }

    override func shouldAllow(value: String?) -> Bool {
        return super.shouldAllow(value: value) && !(value?.contains(where: { $0.isEmoji }) ?? false)
    }

    override func sanitize(value: String?) -> String? {
        let value = value?.filter { !$0.isEmoji }
        return super.sanitize(value: value)
    }

}
