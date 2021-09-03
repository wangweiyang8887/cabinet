// Copyright © 2021 evan. All rights reserved.

import Foundation

extension Sequence {
    public func grouped<T : Hashable>(by keyForValue: (Element) throws -> T) rethrows -> [T:[Element]] {
        return try [T:[Element]](grouping: self, by: keyForValue)
    }
}

extension Collection { // TODO: Make work for SequenceTypes?
    /// Return a sequence of consecutive groups of `n` elements, or less than `n`
    /// for the last group if there are not enough elements left in `self`.
    public func grouped(per n: Int) -> AnySequence<SubSequence> {
        return AnySequence { GroupsGenerator(base: self, maxGroupSize: n) }
    }
}

private struct GroupsGenerator<Base : Collection> : IteratorProtocol {
    let base: Base
    let maxGroupSize: Int
    var currentIndex: Base.Index

    init(base: Base, maxGroupSize: Int) {
        precondition(maxGroupSize > 0)
        (self.base, self.maxGroupSize, self.currentIndex) = (base, maxGroupSize, base.startIndex)
    }

    mutating func next() -> Base.SubSequence? {
        let groupStartIndex = currentIndex
        _ = base.formIndex(&currentIndex, offsetBy: maxGroupSize, limitedBy: base.endIndex)
        // Get range
        let range = groupStartIndex..<currentIndex
        guard !range.isEmpty else { return nil }
        return base[range]
    }
}
