// Infinite.Rotated.swift
// A rotated view of a collection.

extension Infinite {
    /// A collection that presents a rotated view of another collection.
    ///
    /// Used internally by `Cycle` to implement efficient `tail` without copying.
    /// The rotation shifts the starting position while maintaining the same elements.
    ///
    /// ## Example
    ///
    /// For a collection `[a, b, c, d]` with `startOffset: 1`, the rotated view
    /// presents elements as `[b, c, d, a]`.
    public struct Rotated<Base: RandomAccessCollection & Sendable>: RandomAccessCollection, Sendable
    where Base.Element: Sendable {
        @usableFromInline
        let base: Base

        @usableFromInline
        let startOffset: Int

        @inlinable
        init(base: Base, startOffset: Int) {
            self.base = base
            self.startOffset = startOffset % base.count
        }

        @inlinable
        public var startIndex: Int { 0 }

        @inlinable
        public var endIndex: Int { base.count }

        @inlinable
        public subscript(position: Int) -> Base.Element {
            let actualIndex = (startOffset + position) % base.count
            return base[base.index(base.startIndex, offsetBy: actualIndex)]
        }

        @inlinable
        public func index(after i: Int) -> Int { i + 1 }

        @inlinable
        public func index(before i: Int) -> Int { i - 1 }

        @inlinable
        public func index(_ i: Int, offsetBy distance: Int) -> Int { i + distance }

        @inlinable
        public func distance(from start: Int, to end: Int) -> Int { end - start }
    }
}
