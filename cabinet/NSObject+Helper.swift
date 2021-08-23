// Copyright © 2021 evan. All rights reserved.

import Foundation

extension Selector {
    /// Selectors can be used as unique `void *` keys, this gets that key.
    public var key: UnsafeRawPointer { return unsafeBitCast(self, to: UnsafeRawPointer.self) }
}

extension NSObject {
    public func getAssociatedValue(for key: UnsafeRawPointer) -> Any? {
        return objc_getAssociatedObject(self, key)
    }

    public func setAssociatedValue(_ value: Any?, forKey key: UnsafeRawPointer) {
        objc_setAssociatedObject(self, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

/// Initializes and configures a given NSObject.
/// This utility method can be used to cut down boilerplate code.
///
/// - SeeAlso: https://itnext.io/refactoring-in-swift-setup-closures-d06b896c412c
/// - Parameter construct: contains the initialization code of this object.
public func create<T : NSObject>(constructing construct: (T) -> Void) -> T {
    let obj = T()
    construct(obj)
    return obj
}
