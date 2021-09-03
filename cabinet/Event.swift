// Copyright © 2021 evan. All rights reserved.

public class Event<Arguments> : Equatable, AnyEvent {
    public private(set) var observers: [Observer<Arguments>] = [] { didSet { handleObserversChanged() } }

    fileprivate init() {}

    // MARK: General
    private func add(_ observer: Observer<Arguments>) {
        precondition(observer.event == nil, "Attempting to attach an observer that is already attached to an event.")
        assert(!observers.contains(observer))
        observers.append(observer)
        observer.event = self
    }

    fileprivate func remove(_ observer: Observer<Arguments>) {
        precondition(observer.event == self)
        observers = observers.filter { $0 != observer }
    }

    fileprivate func handleObserversChanged() {}

    public static func == <T>(lhs: Event<T>, rhs: Event<T>) -> Bool { return lhs === rhs }
}

public final class OwnedEvent<Arguments> : Event<Arguments> {
    public var observersChangedHandler: (([Observer<Arguments>]) -> Void)?

    public override init() {}

    public func raise(withArguments arguments: Arguments) {
        for observer in observers {
            guard observer.event == self else { continue } // Can happen if it was remove in the handler of an earlier observer
            observer.handler(arguments)
        }
    }

    fileprivate override func handleObserversChanged() {
        observersChangedHandler?(observers)
    }
}

extension OwnedEvent where Arguments == Void {
    public func raise() { raise(withArguments: ()) }
}

// MARK: Any Event
public protocol AnyEvent {
    func any_add(_ handler: @escaping () -> Void) -> AnyObserver
}

extension Event {
    public func any_add(_ handler: @escaping () -> Void) -> AnyObserver {
        return add { _ in handler() }
    }
}

// MARK: Convenience
extension Event {
    public func add(_ handler: @escaping (Arguments) -> Void) -> Observer<Arguments> {
        let observer = Observer(handler)
        add(observer)
        return observer
    }

    public func onNextFiring(_ handler: @escaping (Arguments) -> Void) {
        weak var weakObserver: Observer<Arguments>?
        let observer = Observer<Arguments> { [weak self] arguments in
            if let event = self, let observer = weakObserver, observer.event == event { event.remove(observer) }
            handler(arguments)
        }
        weakObserver = observer
        add(observer)
    }
}

public func += <T>(event: Event<T>, handler: @escaping Observer<T>.Handler) -> Observer<T> { return event.add(handler) }

// MARK: - Observer

public final class Observer<Arguments> : AnyObserver, Equatable {
    fileprivate weak var event: Event<Arguments>?
    public let handler: Handler

    public typealias Handler = (Arguments) -> Void

    // MARK: Initialization
    fileprivate init(_ handler: @escaping Handler) {
        self.handler = handler
    }

    // MARK: General
    public func remove() {
        event?.remove(self)
    }

    public static func == <T>(lhs: Observer<T>, rhs: Observer<T>) -> Bool { return lhs === rhs }
}

public protocol AnyObserver {
    func remove()
}
