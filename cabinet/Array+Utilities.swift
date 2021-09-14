// Copyright © 2021 evan. All rights reserved.

import Foundation

extension Sequence where Element : Hashable {
    /// Remove duplicated elements from the sequence, without the guarantee that the order will be maintained.
    /// - SeeAlso: `orderedUniqueElements` for the ordered counterpart of this utility.
    /// - Complexity: although the complexity of this algorithm is not explicitly documented, this method is slightly faster than `orderedUniqueElements` for most general cases, unless the array is relatively long (e.g. more than 250 elements).
    public var unorderedUniqueElements: [Element] { return Array(Set(self)) }
}

extension Array {
    /// A sequence with the elements of the receiving sequence, excluding the repeated elements.
    /// - Note: The order of the elements is kept.
    /// - SeeAlso: `unorderedUniqueElements` for the unordered counterpart of this utility
    /// - Complexity: although the complexity of this algorithm is not explicitly documented, this method is slightly slower than `unorderedUniqueElements` for most general cases, unless the array is relatively long (e.g. more than 250 elements).
    public var orderedUniqueElements: [Element] {
        let orderedSet = NSOrderedSet(array: self)
        return orderedSet.array as! [Element]
    }

    /// Adds the given element to the end of this array, returning the resulting array.
    ///
    /// - Parameter item: Element to be appended.
    /// - Returns: The resulting array.
    public func appending(_ item: Element) -> [Element] {
        let result = self + [ item ]
        return result
    }

    /// Returns the index of the first element of the sequence that satisfies the given
    /// predicate.
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as
    ///   its argument and returns a Boolean value indicating whether the
    ///   element is a match.
    /// - Returns: The index of the first element of the sequence that satisfies `predicate`,
    ///   or `nil` if there is no element that satisfies `predicate`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    public func indexOfFirst(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        for (index, element) in enumerated() where try predicate(element) {
            return index
        }
        return nil
    }

    /// This method implements an efficient parallel mapping, being designed for expensive transformations. An internal dispatch queue executes the submitted transformation block and waits for all transformations to complete before returning.
    /// - SeeAlso: https://talk.objc.io/episodes/S01E90-concurrent-map
    @discardableResult public func concurrentMap<B>(_ transform: @escaping (Element) -> B) -> [B] {
        var result = [B?](repeating: nil, count: count)
        let syncQueue = DispatchQueue(label: "sync queue")
        DispatchQueue.concurrentPerform(iterations: count) { index in
            let element = self[index]
            let transformed = transform(element)
            syncQueue.sync {
                result[index] = transformed
            }
        }
        return result.map { $0! }
    }

    /// Returns a dictionary whose key-value pairs are results of the transformation closure passed to this function.
    /// - Parameter transform: the closure that will define how the resulting dictionary will be generated.
    public func dictionaryMap<Key, Value>(_ transform: (inout [Key:Value], Element) -> [Key:Value]) -> [Key:Value] {
        return reduce([Key:Value]()) { result, element -> [Key:Value] in
            var result = result
            return transform(&result, element)
        }
    }

    /// Returns a dictionary with the given key-value pairs from the elements of this array.
    /// - Parameters:
    ///   - key: the element's KeyPath to be the key of the resulting dictionary.
    ///   - value: the element's KeyPath to be the value of the resulting dictionary.
    public func dictionary<Key, Value>(withKey key: Swift.KeyPath<Element, Key>, value: Swift.KeyPath<Element, Value>) -> [Key:Value] {
        return reduce(into: [:]) { dictionary, element in
            let key = element[keyPath: key]
            let value = element[keyPath: value]
            dictionary[key] = value
        }
    }
}
