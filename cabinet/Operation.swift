// Copyright © 2021 evan. All rights reserved.

import Dispatch
import Foundation
import UIKit

// MARK: - Operation

/// Represents an asynchronous operation that will produce a result (either a value or an error) upon completion.
///
/// Using completion callbacks, an operation allows adding actions and mappings on the result before the operation actually completes.
/// This class is thread-safe, i.e. it's safe to access its  properties and methods from any queue at any time.
class Operation<Value> : Equatable {
    /// A serial queue for exclusive access to the private stored properties.
    private let serialQueue = DispatchQueue(label: "Operation<\(Value.self)>.serialQueue")
    /// The result with which the operation was completed, or `nil` if it has not been completed yet.
    private var _result: Result<Value>?
    /// The completion callbacks that will be invoked once the operation completes, together with the queues they will be invoked on.
    private var callbacks: [(DispatchQueue, Callback)] = [] // Empty once completed, to release the callbacks

    /// Returns the result with which the operation was completed, or `nil` if it has not been completed yet.
    ///
    /// Once the operation completes this result is guaranteed to stay the same.
    var result: Result<Value>? { return serialQueue.sync { _result } }

    typealias Callback = (Result<Value>) -> Void

    fileprivate init() {}

    // MARK: General
    fileprivate func complete(with result: Result<Value>) { // OwnedOperation overrides this to be
        serialQueue.async {
            // Check the operation hasn't been completed already.
            guard self._result == nil else { return }
            // Store result
            self._result = result
            // Get callbacks, clearing them before actually invoking them
            let callbacks = self.callbacks
            self.callbacks = [] // Clear callbacks after completion to stop strongly referencing them
            for (queue, callback) in callbacks {
                queue.async { callback(result) }
            }
        }
    }

    /// Adds a callback to be invoked once the operation completes.
    ///
    /// The callback will be strongly referenced until it has been invoked, and is guaranteed to be called only once.
    /// If the operation has already been completed, the callback will be invoked immediately (asynchronously).
    /// - Parameter queue: The queue on which the callback will be performed. Defaults to the main queue.
    @discardableResult  func onCompletion(queue: DispatchQueue = .main, callback: @escaping (Result<Value>) -> Void) -> Operation<Value> {
        serialQueue.async {
            if let result = self._result { // Call callback now if already complete
                queue.async { callback(result) }
            } else { // Append only if not done, callbacks should be empty after completion.
                self.callbacks.append((queue, callback))
            }
        }
        return self
    }

     static func == <T>(lhs: Operation<T>, rhs: Operation<T>) -> Bool { return lhs === rhs }
}

// MARK: - Owned Operation

class OwnedOperation<Value> : Operation<Value> {
     override init() {}

    /// Completes the operation with the given result, calling all registered callbacks.
    ///
    /// If the operation was already completed, has no effect.
     override func complete(with result: Result<Value>) { super.complete(with: result) }
}

// MARK: - Operation Group

/// An operation that is successful when all operations in a group of operations are successful.
 class OperationGroup : Operation<[Any]> {
    private let operations: [AnyOperation]

    // MARK: Initialization
     init(_ operations: [AnyOperation]) {
        self.operations = operations
        super.init()
        // Handle empty case
        guard !operations.isEmpty else {
            complete(with: .success([]))
            return
        }
        // Register handlers
        for operation in operations {
            // The handler strongly references `self`, thus the group will live at least as long as the operations
            operation.any_onCompletion(queue: .global()) { _ in
                self.completeIfPossible()
            }
        }
    }

    private func completeIfPossible() {
        // Check if all are completed
        guard let results = operations.failableMap({ $0.any_result }) else { return }
        // Check if all success
        if let allValues = results.failableMap({ $0.value }) {
            complete(with: .success(allValues))
        } else {
            let error = results.first { $0.error }!
            complete(with: .error(error))
        }
    }
}

// MARK: - Any Operation

 protocol AnyOperation : AnyObject {
    var any_result: Result<Any>? { get }
    @discardableResult func any_onCompletion(queue: DispatchQueue, callback: @escaping (Result<Any>) -> Void) -> AnyOperation
}

extension Operation : AnyOperation {
    /// Type-erased version of `result` for `AnyOperation`.
     var any_result: Result<Any>? { return result?.map { $0 as Any } }

    /// Type-erased version of `onCompletion(_:)` for `AnyOperation`.
    @discardableResult  func any_onCompletion(queue: DispatchQueue = .main, callback: @escaping (Result<Any>) -> Void) -> AnyOperation {
        return onCompletion(queue: queue) { result in
            callback(result.map { $0 as Any })
        }
    }
}

// MARK: - Convenience

extension Operation {
    /// Returns whether the operation has completed.
     var isCompleted: Bool { return result != nil }

    /// Creates an operation that asynchronously performs work on a given queue.
    ///
    /// - Parameter queue: The queue to perform the work on. Defaults to a default priority global concurrent queue.
     convenience init(queue: DispatchQueue = .global(), work: @escaping () throws -> Value) {
        self.init()
        queue.async {
            let result = catchResult(invoking: work)
            self.complete(with: result)
        }
    }

    /// Creates an already completed operation with the given result.
     convenience init(result: Result<Value>) {
        self.init()
        complete(with: result)
    }

    /// Creates an already successfully completed operation with the given value as its result.
     convenience init(value: Value) {
        self.init(result: .success(value))
    }

    /// Creates an already failed operation with the given error as its result.
     convenience init(error: Error) {
        self.init(result: .error(error))
    }

    /// Creates an operation from a closure that starts an Objective-C style asynchronous operation.
    ///
    /// - Parameter startOperation: A closure that starts asynchronous work, which in turn should call the completion handler when done.
    ///   This closure is called synchronously from within this initializer and therefore generally should not block.
     convenience init(objc_startOperation: (@escaping (Value?, Error?) -> Void) -> Void) {
        self.init()
        let completionHandler: ObjCCompletionHandler<Value> = { value, error in
            let result = Result(value, error ?? GenericError())
            self.complete(with: result)
        }
        objc_startOperation(completionHandler)
    }

    /// Adds a callback to be invoked if the operation completes with a successful result.
    ///
    /// See `onCompletion(perform:)` for details.
    /// - Parameter queue: The queue on which the callback will be performed. Defaults to the main queue.
    @discardableResult  func onSuccess(queue: DispatchQueue = .main, callback: @escaping (Value) -> Void) -> Operation<Value> {
        return onCompletion(queue: queue) { result in
            if let value = result.value { callback(value) }
        }
    }

    /// Adds a callback to be invoked if the operation completes with an error.
    ///
    /// See `onCompletion(perform:)` for details.
    /// - Parameter queue: The queue on which the callback will be performed. Defaults to the main queue.
    @discardableResult  func onError(queue: DispatchQueue = .main, callback: @escaping (Error) -> Void) -> Operation<Value> {
        return onCompletion(queue: queue) { result in
            if let error = result.error { callback(error) }
        }
    }

    /// Adds an Objective-C style callback to be invoked once the operation completes.
    ///
    /// See `onCompletion(perform:)` for details.
    /// - Parameter queue: The queue on which the callback will be performed. Defaults to the main queue.
    /// - Parameter callback: The Objective-C style callback, made optional for caller convenience.
    @discardableResult  func objc_onCompletion(queue: DispatchQueue = .main, _ callback: ObjCCompletionHandler<Value>?) -> Operation<Value> {
        guard let callback = callback else { return self }
        return onCompletion { result in
            callback(result.value, result.error)
        }
    }

    /// Blocks until the operation completes and returns its result.
    @discardableResult  func waitUntilFinished() -> Result<Value> {
        let semaphore = DispatchSemaphore(value: 0)
        // Increment on completion
        onCompletion(queue: .global()) { _ in semaphore.signal() } // On a concurrent queue to avoid a potential deadlock
        // Wait for increment
        semaphore.wait()
        return result!
    }

    @discardableResult  func ignoreResult() -> Operation<Void> {
        return map { _ in }
    }
}

extension OwnedOperation {
    /// Creates an operation from a closure that starts an asynchronous operation.
    ///
    /// - Parameter startOperation: A closure that starts asynchronous work, which in turn should complete the operation when done.
    ///   This closure is called synchronously from within this initializer and therefore generally should not block.
     convenience init(startOperation: (OwnedOperation<Value>) -> Void) {
        self.init()
        startOperation(self)
    }

    /// Creates an owned operation that completes when the passed operation completes.
    ///
    /// This can be useful to e.g. be able to cancel or otherwise complete the operation independently.
    /// If the given operation was already completed the owned operation is completed immediately, synchronously.
     convenience init(_ operation: Operation<Value>) {
        self.init()
        if let result = operation.result {
            complete(with: result)
        } else {
            operation.onCompletion { self.complete(with: $0) }
        }
    }

    /// Successfully completes the operation with the given value as its result, calling all registered callbacks.
    ///
    /// If the operation was already completed, has no effect.
     func complete(with value: Value) { complete(with: .success(value)) }

    /// Fails the operation with the given error as its result, calling all registered callbacks.
    ///
    /// If the operation was already completed, has no effect.
     func complete(with error: Error) { complete(with: .error(error)) }
}

extension OperationGroup {
     convenience init(_ operations: AnyOperation...) {
        self.init(operations)
    }

    /// Splits the given items in batches, starts an operation for each batch (in parallel), and joins the results.
     static func batching<T, U>(_ items: [T], per batchSize: Int, startBatch: ([T]) -> Operation<[U]>) -> Operation<[U]> {
        let operations = items.grouped(per: batchSize).map { startBatch(Array($0)) }
        if operations.isEmpty { return Operation(value: []) }
        if let operation = operations.onlyElement { return operation }
        return OperationGroup(operations as [AnyOperation]).map { chunks in
            Array((chunks as! [[U]]).joined())
        }
    }
}

// MARK: - Derived Operations

extension Operation {
    /// Creates a derived operation that applies a mapping to the result value of the operation (once it completes)
    /// and completes itself with the result of that mapping.
    ///
    /// If the operation results in an error, the derived operation will directly propagate that error and the mapping will not be invoked.
    /// - Parameter queue: The queue on which the mapping will be performed. Defaults to the main queue.
     func map<U>(queue: DispatchQueue = .main, mapping: @escaping (Value) throws -> U) -> Operation<U> {
        let operation = OwnedOperation<U>()
        onCompletion(queue: queue) { result in
            operation.complete(with: result.map(mapping))
        }
        return operation
    }

    /// Creates a derived operation that performs another operation based on the result value of the operation (once it completes),
    /// and completes itself with the eventual result of that second operation.
    ///
    /// If the operation results in an error, the derived operation will directly propagate that error and the mapping will not be invoked.
    /// - Parameter queue: The queue on which the mapping will be performed. Defaults to the main queue.
     func flatMap<U>(queue: DispatchQueue = .main, mapping: @escaping (Value) throws -> Operation<U>) -> Operation<U> {
        return OwnedOperation<U>(startOperation: { operation in
            onCompletion(queue: queue) { result in
                let mappingResult = result.map(mapping)
                switch mappingResult {
                case .success(let secondOperation): secondOperation.onCompletion(queue: .global()) { operation.complete(with: $0) }
                case .error(let error): operation.complete(with: error)
                }
            }
        })
    }

    /// Creates a derived operation that applies a mapping to the result of the operation (once it completes)
    /// and completes itself with the result of that mapping.
    ///
    /// - Parameter queue: The queue on which the mapping will be performed. Defaults to the main queue.
     func mapResult<U>(queue: DispatchQueue = .main, mapping: @escaping (Result<Value>) throws -> U) -> Operation<U> {
        let operation = OwnedOperation<U>()
        onCompletion(queue: queue) { result in
            operation.complete(with: catchResult { try mapping(result) })
        }
        return operation
    }

    /// Creates a derived operation that performs another operation based on the result of the operation (once it completes),
    /// and completes itself with the eventual result of that second operation.
    ///
    /// - Parameter queue: The queue on which the mapping will be performed. Defaults to the main queue.
     func flatMapResult<U>(queue: DispatchQueue = .main, mapping: @escaping (Result<Value>) throws -> Operation<U>) -> Operation<U> {
        return OwnedOperation<U>(startOperation: { operation in
            onCompletion(queue: queue) { result in
                let mappingResult = catchResult { try mapping(result) }
                switch mappingResult {
                case .success(let secondOperation): secondOperation.onCompletion(queue: .global()) { operation.complete(with: $0) }
                case .error(let error): operation.complete(with: error)
                }
            }
        })
    }
}

extension Operation {
    /// Wraps an operation to enable retrying it.
     convenience init(_ performOperation: @escaping () -> Operation<Value>, shouldRetry: @escaping (Result<Value>) -> Bool, maximumNumberOfRetries: Int) {
        self.init()
        assert(maximumNumberOfRetries >= 0)
        var numberOfRetriesLeft = maximumNumberOfRetries
        func completeOrRetry(with result: Result<Value>) {
            if numberOfRetriesLeft > 0 && shouldRetry(result) {
                numberOfRetriesLeft -= 1
                performOperation().onCompletion { completeOrRetry(with: $0) }
            } else {
                self.complete(with: result)
            }
        }
        performOperation().onCompletion { completeOrRetry(with: $0) }
    }
}
