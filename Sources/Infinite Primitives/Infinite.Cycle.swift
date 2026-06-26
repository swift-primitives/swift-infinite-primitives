// Infinite.Cycle.swift
// Cycling through a finite collection indefinitely.

public import Collection_Primitives
public import Iterator_Protocol

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
    /// let first7 = colors.prefix(7)
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
    /// For other collection types, only `Enumerable` is provided.
    public struct Cycle<Base: Swift.Collection> {
        /// The finite collection being cycled.
        @usableFromInline
        let base: Base

        /// Creates a cycling sequence, returning `nil` if the collection is empty.
        ///
        /// - Parameter base: A non-empty collection to cycle through.
        @inlinable
        public init?(_ base: Base) {
            guard !base.isEmpty else { return nil }
            self.base = base
        }

        /// Creates a cycling sequence without emptiness checking.
        ///
        /// - Parameters:
        ///   - __unchecked: Marker parameter indicating unchecked access.
        ///   - base: Must be non-empty.
        @inlinable
        public init(__unchecked: Void, _ base: Base) {
            self.base = base
        }
    }
}

// MARK: - Iteration

extension Infinite.Cycle {
    /// Returns an iterator over this cycling sequence.
    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(base: base)
    }

    /// An iterator that cycles through a collection indefinitely.
    ///
    /// Uses `Optional<Base.Element>` as inline storage for span-based access.
    /// Zero heap allocation. The Optional payload is at byte offset 0
    /// (ABI guarantee for single-payload enums), enabling safe reinterpretation
    /// as a `Span<Base.Element>` via `withUnsafeMutablePointer`.
    public struct Iterator: ~Copyable, Iterator_Primitive.Iterator.`Protocol` {
        /// The element type: the base collection's element.
        public typealias Element = Base.Element

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

extension Infinite.Cycle: Sendable where Base: Sendable {}
// WHY: Category D — structural Sendable workaround (SP-4).
// WHY: ~Copyable is for single-use iteration semantics, not resource ownership.
// WHY: Generic parameter blocks structural Sendable inference.
// WHEN TO REMOVE: When compiler gains structural Sendable through generic params.
// TRACKING: unsafe-audit-findings.md Category D SP-4.
extension Infinite.Cycle.Iterator: @unchecked Sendable where Base: Sendable, Base.Index: Sendable {}

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
    /// Returns whether two cycling sequences wrap equal base collections.
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.base == rhs.base
    }
}

// MARK: - Hashable

extension Infinite.Cycle: Hashable where Base: Hashable {
    /// Feeds the base collection into the given hasher.
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(base)
    }
}
