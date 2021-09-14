// Copyright © 2020 PeoGooCore. All rights reserved.

extension UIResponder {
    /// The responder that should become first responder when the user taps the next button (or any similar control).
    @IBOutlet public var nextInput: UIResponder? {
        get { return getAssociatedValue(for: #selector(getter: UIResponder.nextInput).key) as! UIResponder? }
        set { setAssociatedValue(newValue, forKey: #selector(getter: UIResponder.nextInput).key) }
    }

    public static var firstResponder: UIResponder? { return currentFirst }

    @discardableResult
    public static func resignAllFirstResponders() -> Bool {
        while let firstResponder = firstResponder {
            guard firstResponder.resignFirstResponder() else { return false }
        }
        return true
    }
    
    static weak var _currentFirst: UIResponder?
    
    static var currentFirst: UIResponder? {
        _currentFirst = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder), to: nil, from: nil, for: nil)
        return _currentFirst
    }
    
    @objc func findFirstResponder() {
        UIResponder._currentFirst = self
    }
}
