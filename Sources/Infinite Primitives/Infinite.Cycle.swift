// Infinite.Cycle.swift
// Cycling through a finite collection indefinitely.

public import Collection_Primitives

extension Infinite {
    /// An infinite sequence that cycles through a finite collection.
    ///
    /// `Cycle` repeats the elements of a collection indefinitely:
    /// `[a, b, c]` becomes `a, b, c, a, b, c, a, b, c, ...`
    ///
    /// ## Example
    ///
    /// ```swift
    /// let colors = Infinite.Cycle(["red", "green", "blue"])!
    /// print(Array(colors.prefix(7)))
    /// // ["red", "green", "blue", "red", "green", "blue", "red"]
    /// ```
    ///
    /// ## Precondition
    ///
    /// The base collection must not be empty. Use the failable `init?(_:)` for
    /// safe construction, or `init(__unchecked:_:)` when emptiness is already ruled out.
    ///
    /// ## Observable Conformance
    ///
    /// `Cycle` conforms to `Observable` when the base collection is a
    /// `RandomAccessCollection`, enabling efficient head/tail decomposition.
    /// For other collection types, only `Sequence` and `Enumerable` are provided.
    public struct Cycle<Base: Swift.Collection & Sendable>
    where Base.Element: Sendable {
        /// The finite collection being cycled.
        @usableFromInline
        let base: Base

        /// Creates a cycling sequence, returning `nil` if the collection is empty.
        ///
        /// - Parameter base: A non-empty collection to cycle through.
        /// - Returns: The cycling sequence, or `nil` if `base` is empty.
        @inlinable
        public init?(_ base: Base) {
            guard !base.isEmpty else { return nil }
            self.base = base
        }

        /// Creates a cycling sequence without emptiness checking.
        ///
        /// - Parameter __unchecked: Marker parameter indicating unchecked access.
        /// - Parameter base: Must be non-empty.
        @inlinable
        public init(__unchecked: Void, _ base: Base) {
            self.base = base
        }
    }
}

// MARK: - Sequence

extension Infinite.Cycle: Swift.Sequence {
    /// Returns an iterator over this cycling sequence.
    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(base: base)
    }

    /// An iterator that cycles through a collection indefinitely.
    public struct Iterator: Sequence.Iterator.`Protocol`, IteratorProtocol {
        @usableFromInline
        let base: Base

        @usableFromInline
        var index: Base.Index

        @inlinable
        init(base: Base) {
            self.base = base
            self.index = base.startIndex
        }

        /// Returns the next element, wrapping to the start when exhausted.
        @inlinable
        public mutating func next() -> Base.Element? {
            let element = base[index]
            base.formIndex(after: &index)
            if index == base.endIndex {
                index = base.startIndex
            }
            return element
        }
    }
}

// MARK: - Sendable

extension Infinite.Cycle: Sendable {}
extension Infinite.Cycle.Iterator: Sendable where Base.Index: Sendable {}

// MARK: - Enumerable

extension Infinite.Cycle: Infinite.Enumerable {}

// MARK: - Observable (RandomAccessCollection)

extension Infinite.Cycle: Infinite.Observable where Base: Swift.RandomAccessCollection {
    /// The first element of the cycle (same as first element of base).
    @inlinable
    public var head: Base.Element {
        base[base.startIndex]
    }

    /// The cycle starting from the second element.
    ///
    /// For efficiency, this shifts the internal view rather than copying.
    @inlinable
    public var tail: Infinite.Cycle<Collection.Rotated<Base>> {
        let rotated = Collection.Rotated(base: base, startOffset: .one)
        return Infinite.Cycle<Collection.Rotated<Base>>(__unchecked: (), rotated)
    }
}

// MARK: - Equatable

extension Infinite.Cycle: Equatable where Base: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.base == rhs.base
    }
}

// MARK: - Hashable

extension Infinite.Cycle: Hashable where Base: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(base)
    }
}
