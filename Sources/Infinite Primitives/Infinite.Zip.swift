// Infinite.Zip.swift
// Element-wise combination of two infinite sequences.

public import Iterator_Protocol

extension Infinite {
    /// An infinite sequence combining elements from two sources pairwise.
    ///
    /// `Zip` pairs up corresponding elements from two infinite sequences,
    /// producing tuples `(first[i], second[i])` for each index `i`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
    /// let squares = naturals.map { $0 * $0 }
    /// let pairs = Infinite.Zip(naturals, squares)
    /// let first5 = pairs.prefix(5)
    /// // [(0, 0), (1, 1), (2, 4), (3, 9), (4, 16)]
    ///
    /// // Using static convenience
    /// let zipped = Infinite.zip(naturals, squares)
    /// ```
    ///
    /// ## Infiniteness
    ///
    /// Since both sources are infinite, the zipped sequence is also infinite.
    /// This differs from `Swift.zip`, which terminates when either source ends.
    ///
    /// ## Observable Conformance
    ///
    /// `Zip` conforms to `Observable` when both sources do. The `Tail` type
    /// is `Zip<First.Tail, Second.Tail>`.
    public struct Zip<First: Infinite.Enumerable, Second: Infinite.Enumerable> {
        /// The first source sequence.
        @usableFromInline
        let first: First

        /// The second source sequence.
        @usableFromInline
        let second: Second

        /// Creates a zipped infinite sequence.
        ///
        /// - Parameters:
        ///   - first: The first infinite sequence.
        ///   - second: The second infinite sequence.
        @inlinable
        public init(_ first: First, _ second: Second) {
            self.first = first
            self.second = second
        }
    }
}

// MARK: - Static Convenience

extension Infinite {
    /// Creates a zipped infinite sequence from two sources.
    ///
    /// - Parameters:
    ///   - first: The first infinite sequence.
    ///   - second: The second infinite sequence.
    /// - Returns: An infinite sequence of paired elements.
    @inlinable
    public static func zip<First: Enumerable, Second: Enumerable>(
        _ first: First,
        _ second: Second
    ) -> Self.Zip<First, Second> {
        Self.Zip(first, second)
    }
}

// MARK: - Iteration

extension Infinite.Zip {
    /// Returns an iterator over this zipped sequence.
    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(first: first.makeIterator(), second: second.makeIterator())
    }

    /// An iterator that pairs elements from two sources.
    ///
    /// Uses `Optional<(First.Element, Second.Element)>` as inline storage for
    /// span-based access. Zero heap allocation. The Optional payload is at byte
    /// offset 0 (ABI guarantee for single-payload enums), enabling safe
    /// reinterpretation as a `Span` via `withUnsafeMutablePointer`.
    public struct Iterator: ~Copyable, Iterator_Primitive.Iterator.`Protocol` {
        /// The element type: a pair of one element drawn from each source sequence.
        public typealias Element = (First.Element, Second.Element)

        @usableFromInline
        var first: First.Iterator

        @usableFromInline
        var second: Second.Iterator

        @inlinable
        init(first: consuming First.Iterator, second: consuming Second.Iterator) {
            self.first = first
            self.second = second
        }

        /// Returns the next pair of elements.
        @inlinable
        public mutating func next() -> (First.Element, Second.Element)? {
            guard let a = first.next(), let b = second.next() else { return nil }
            return (a, b)
        }
    }
}

// MARK: - Sendable

extension Infinite.Zip: Sendable where First: Sendable, Second: Sendable {}
// WHY: Category D — structural Sendable workaround (SP-4).
// WHY: ~Copyable is for single-use iteration semantics, not resource ownership.
// WHY: Generic parameter blocks structural Sendable inference.
// WHEN TO REMOVE: When compiler gains structural Sendable through generic params.
// TRACKING: unsafe-audit-findings.md Category D SP-4.
extension Infinite.Zip.Iterator: @unchecked Sendable where First.Iterator: Sendable, Second.Iterator: Sendable {}

// MARK: - Enumerable

extension Infinite.Zip: Infinite.Enumerable {}

// MARK: - Observable

extension Infinite.Zip: Infinite.Observable
where First: Infinite.Observable, Second: Infinite.Observable {
    /// The paired head elements.
    @inlinable
    public var head: (First.Element, Second.Element) {
        (first.head, second.head)
    }

    /// The zipped tail sequences.
    @inlinable
    public var tail: Infinite.Zip<First.Tail, Second.Tail> {
        Infinite.Zip<First.Tail, Second.Tail>(first.tail, second.tail)
    }
}
