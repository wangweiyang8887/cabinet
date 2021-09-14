// Copyright © 2021 evan. All rights reserved.

class EditorRow<Value> : BaseRow, Editor {
    var _value: Value!
    final var value: Value {
        get { return _value ?? (Value.self as! AnyOptional.Type).any_none as! Value } // Require _value is initialized, or Value is optional
        // Don't allow did set overrides, as those internally call the getter (to get the oldValue), which fails if unitialized
        set { _value = newValue; handleValueSet() }
    }

    var valueEditedHandler: ValueEditedHandler? // When changed by the user
    var isEditable: Bool = true { didSet { handleIsEditableChanged() } }

    override var item: Any? {
        get { return _value }
        set { value = newValue as! Value }
    }

    typealias ValueEditedHandler = (Value) -> Void

    // MARK: Initialization
    convenience init(value: Value) {
        self.init()
        self.value = value
    }

    // MARK: Updating
    /// Called when the value is set programmatically. To be overriden by subclasses.
    func handleValueSet() {}

    /// Called when the isEditable changed. To be overriden by subclasses.
    func handleIsEditableChanged() {}
}


// MARK: - Protocols
protocol Editor : AnyObject {
    var value: Value { get set }
    var valueEditedHandler: ValueEditedHandler? { get set }

    associatedtype Value
    typealias ValueEditedHandler = (Value) -> Void
}

protocol ModalEditor : Editor {
    func show()
}
