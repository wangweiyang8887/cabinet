// Copyright © 2021 evan. All rights reserved.

final class TextViewObserver : NSObject {
    typealias TextViewChangeType = (UITextView) -> Void
    typealias TextViewWillReplaceWithTextInRange = (UITextView, String, NSRange) -> Bool

    var textInputModeDidChangeHandler: SelectionHandler<Bool>?
    var textDidChangeHandler: ActionClosure?

    private let notifications = Observers()
    private let observers = ObserverCollection()
    private var textDidChangeCallbacks: [TextViewChangeType] = []
    private var textDidChangeSelectionCallbacks: [TextViewChangeType] = []

    private enum Cache {
        // Workaround to prevent the array from being set to empty. Don't know why.
        static var textWillReplaceWithTextInRangeCallbacks: [TextViewWillReplaceWithTextInRange] = []
    }

    deinit {
        observers.removeAll()
        notifications.removeAll()
        textDidChangeCallbacks.removeAll()
        textDidChangeSelectionCallbacks.removeAll()
        Cache.textWillReplaceWithTextInRangeCallbacks.removeAll()
    }

    init(textView: UITextView) {
        super.init()
        textView.delegate = self
        notifications.when(UITextView.textDidChangeNotification, object: textView) { [weak self] in
            guard let self = self else { return }
            self.textViewDidChangeNotification(notification: $0)
            self.textDidChangeHandler?()
        }
        observers.addObserver(forName: UITextInputMode.currentInputModeDidChangeNotification) { [weak self, weak textView] _ in
            self?.textInputModeDidChangeHandler?(textView?.textInputMode?.primaryLanguage == "dictation")
        }
    }

    private func textViewDidChangeNotification(notification: Notification) {
        guard let textView = notification.object as? UITextView else { return }
        textDidChangeCallbacks.forEach { $0(textView) }
    }

    /// To listen whenever a UITextViewTextDidChange notification is posted
    func onTextViewTextDidChange(_ changeHandler: @escaping TextViewChangeType) {
        textDidChangeCallbacks.append(changeHandler)
    }

    /// To listen whenever textViewDidChangeSelection delegate method is called
    func onTextViewDidChangeSelection(_ changeHandler: @escaping TextViewChangeType) {
        textDidChangeSelectionCallbacks.append(changeHandler)
    }

    /// To listen whenever textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) delegate method is called
    func onTextViewWillReplaceTextInRangeSelection(_ changeHandler: @escaping TextViewWillReplaceWithTextInRange) {
        Cache.textWillReplaceWithTextInRangeCallbacks.append(changeHandler)
    }
}

extension TextViewObserver : UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        textDidChangeSelectionCallbacks.forEach { $0(textView) }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let results: [Bool] = Cache.textWillReplaceWithTextInRangeCallbacks.map { $0(textView, text, range) }
        return !results.contains(false) // Same as AND operator over all the results.
    }
}
