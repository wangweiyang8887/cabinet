// Copyright © 2021 evan. All rights reserved.

/// Adapted from https://github.com/apple/swift/blob/master/test/Prototypes/Result.swift
enum Result<Value> {
    case success(Value)
    case error(Error)

    public init(_ value: Value) {
        self = .success(value)
    }

    public init(_ error: Error) {
        self = .error(error)
    }

    public init(_ value: Value?, _ error: @autoclosure () -> Error) {
        if let value = value {
            self = .success(value)
        } else {
            self = .error(error())
        }
    }

    /// Creates a derived `Result` that applies a transformation to the value of the result, if the result is a *success*. If the `Result` is an *error*, the derived `Result` will directly propagate that error and the transformation will not be invoked.
    ///
    /// If the transform throws an error, the value is mapped to an error.
    public func map<U>(_ transform: (Value) throws -> U) -> Result<U> {
        switch self {
        case .success(let value): return catchResult { try transform(value) }
        case .error(let error): return .error(error)
        }
    }

    /// Creates a derived `Result` based on the value of the result, if the result is a *success*.  If the `Result` is an *error*, the derived `Result` will directly propagate that error and the transformation will not be invoked.
    public func flatMap<U>(_ transform: (Value) -> Result<U>) -> Result<U> {
        switch self {
        case .success(let value): return transform(value)
        case .error(let error): return .error(error)
        }
    }

    /// Maps to the result of the success associated object to *Void*.
    public func void() -> Result<Void> {
        return map { _ in }
    }

    public func get() throws -> Value {
        switch self {
        case .success(let value): return value
        case .error(let error): throw error
        }
    }

    public var value: Value? {
        guard case .success(let value) = self else { return nil }
        return value
    }

    public var error: Error? {
        guard case .error(let error) = self else { return nil }
        return error
    }
}

/// Translates the execution of a throwing closure into a `Result`.
func catchResult<Value>(invoking body: () throws -> Value) -> Result<Value> {
    do {
        return .success(try body())
    } catch {
        return .error(error)
    }
}
