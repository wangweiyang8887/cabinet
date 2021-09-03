// Copyright © 2021 evan. All rights reserved.

import Foundation

/// - Note: Not thread-safe, all methods must only be called from the main queue.
///   For most UI classes it's fine to call `removeAll()` from `deinit` (as almost always the last reference will be from the main queue).
public final class ObserverCollection {
    private var notificationObservers: [NSObjectProtocol] = []
    private var eventObservers: [AnyObserver] = []
    private var keyValueObservations: [NSKeyValueObservation] = []
    private var blocksKitKVOObservers: [(NSObject, String)] = []
    private var keyboardObservers: [KeyboardObserver] = []

    /// Whether this observer collection doesn't have any observer registered.
    public var isEmpty: Bool {
        return notificationObservers.isEmpty && eventObservers.isEmpty && keyValueObservations.isEmpty && blocksKitKVOObservers.isEmpty && keyboardObservers.isEmpty
    }

    public init() {}

    deinit {
        if !isEmpty {
            print("Observers should be removed using `removeAll()` before the observer collection is deinitialized.")
        }
    }

    // MARK: Adding
    /// Adds an entry to the notification center's dispatch table that includes a notification queue and a block to add to the queue, and an optional notification name and sender.
    /// - Parameter name: The name of the notification for which to register the observer; that is, only notifications with this name are used to add the block to the operation queue.
    ///                   If you pass nil, the notification center doesn’t use a notification’s name to decide whether to add the block to the operation queue.
    /// - Parameter object: The object whose notifications the observer wants to receive; that is, only notifications sent by this sender are delivered to the observer.
    ///                     If you pass nil, the notification center doesn’t use a notification’s sender to decide whether to deliver it to the observer.
    /// - Parameter queue: The operation queue to which block should be added.
    ///                    If you pass nil, the block is run synchronously on the posting thread.
    /// - Parameter handler: the callback handler to be invoked when the notification is received. The notification is passed as an argument of this callback.
    public func addObserver(forName name: NSNotification.Name?, object: Any? = nil, queue: OperationQueue? = nil, handler: @escaping (Notification) -> Void) {
        notificationObservers += NotificationCenter.default.addObserver(forName: name, object: object, queue: queue, using: handler)
    }

    /// Registers a new event observer that has an associated object.
    /// - Parameter event: the event to be observed.
    /// - Parameter handler: the callback handler to be invoked when the event is triggered. The event's associated object is passed as an argument of this callback.
    public func addObserver<T>(for event: Event<T>, handler: @escaping Observer<T>.Handler) {
        eventObservers += event.add(handler)
    }

    /// Registers a new event observer.
    /// - Parameter event: the event to be observed.
    /// - Parameter handler: the callback handler to be invoked when the event is triggered.
    public func addObserver(for event: AnyEvent, handler: @escaping () -> Void) {
        eventObservers += event.any_add(handler)
    }

    /// Registers a new KVO observer.
    /// - Parameter object: object to be observed.
    /// - Parameter properties: a set of properties to be observed, from the object being observed. Prefer using #keyPath() instead of raw strings here.
    /// - Parameter initialUpdate: whether the callback handler should be called immediately when registering this observer.
    /// - Parameter handler: the callback handler to be invoked when there are changes to the given properties of the given object. The object is passed as an argument of this callback.
    public func addKVOObserver<T : NSObject>(on object: T, for properties: Set<String>, initialUpdate: Bool, handler: @escaping (T) -> Void) {
        let identifier = object.bk_addObserver(forKeyPaths: Array(properties)) { _, _ in handler(object) }
        blocksKitKVOObservers += (object, identifier)
        if initialUpdate { handler(object) }
    }

    /// Manages a given KVO observation object.
    /// - Parameter observation:the KVO observation to be observed.
    public func add(_ observation: NSKeyValueObservation) {
        keyValueObservations += observation
    }

    /// Adds and manages a keyboard observer, with a few handy callbacks.
    /// Overriding the following properties on the keyboard observer will change the default implementation, being vulnerable to user error,
    /// thus should be done only if you know what you're doing: `onKeyboardWillChange` and `animationBlock`.
    /// The only properties that are recommended to be overriden are `keyboardWillHide` and `keyboardWillShow`.
    ///
    /// - Parameter handler: this handler will be executed inside the keyboard observer's animationBlock.
    /// - Parameter animated: Whether the handler will be executed animatedly.
    /// - Parameter onChangePosition: This closure gets called everytime the keyboard changes position.
    @discardableResult public func addKeyboardObserver(handler: @escaping KeyboardObserver.KeyboardChangeFrameType, animated: Bool = true, onChangePosition: KeyboardObserver.KeyboardChangePositionType? = nil) -> KeyboardObserver {
        var lastFrame: CGRect?
        let keyboardObserver = KeyboardObserver()

        keyboardObserver.onKeyboardWillChange = { lastFrame = $0 }
        keyboardObserver.onChangePosition = onChangePosition
        keyboardObserver.animationBlock = { [weak self, weak keyboardObserver] in
            guard let self = self, let keyboardObserver = keyboardObserver, self.keyboardObservers.contains(keyboardObserver), let lastFrame = lastFrame else { return }
            if animated {
                handler(lastFrame)
            } else {
                UIView.performWithoutAnimation { handler(lastFrame) }
            }
        }
        keyboardObservers += keyboardObserver
        return keyboardObserver
    }

    /// Unsubscribes from all the observers.
    public func removeAll() {
        notificationObservers.forEach { NotificationCenter.default.removeObserver($0) }
        notificationObservers = []
        eventObservers.forEach { $0.remove() }
        eventObservers = []
        keyValueObservations.forEach { $0.invalidate() }
        keyValueObservations = []
        blocksKitKVOObservers.forEach { object, identifier in object.bk_removeObservers(withIdentifier: identifier) }
        blocksKitKVOObservers = []
        keyboardObservers = []
    }
}

public func += (lhs: ObserverCollection, rhs: NSKeyValueObservation) { lhs.add(rhs) }
