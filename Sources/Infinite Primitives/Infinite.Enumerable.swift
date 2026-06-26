// Infinite.Enumerable.swift
// Protocol for types representing unbounded iteration.

public import Iterator_Protocol

extension Infinite {
    /// A type representing an unbounded or potentially infinite sequence.
    ///
    /// `Enumerable` is the iterator-based protocol for infinite sequences. It is
    /// the dual of `Finite.Enumerable`, providing only forward iteration with no
    /// termination guarantee.
    ///
    /// ## Semantics
    ///
    /// An `Infinite.Enumerable` type:
    /// - Has no `count` (cardinality is undefined or infinite)
    /// - Has no `ordinal` (random access is not meaningful)
    /// - Has no `init(__unchecked:ordinal:)` (cannot construct from arbitrary position)
    /// - Provides only forward iteration via `makeIterator()`
    ///
    /// ## Relationship to Observable
    ///
    /// `Enumerable` and ``Observable`` represent two views of infinite sequences:
    ///
    /// | Enumerable (Iterator) | Observable (Coalgebra) |
    /// |----------------------|----------------------|
    /// | `makeIterator()` | `head` / `tail` |
    /// | Stateful iteration | Pure decomposition |
    /// | Any infinite sequence | Copattern-based |
    ///
    /// All concrete types in this package conform to both when possible.
    /// Use `Enumerable` for iterator-based algorithms (e.g., `prefix`).
    /// Use `Observable` for coalgebraic algorithms (e.g., corecursion, bisimulation).
    ///
    /// ## Use Cases
    ///
    /// - Natural number generators
    /// - Fibonacci sequences
    /// - Random number streams
    /// - Event streams
    /// - Lazy transformations of infinite sources
    ///
    /// ## Example
    ///
    /// ```swift
    /// let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
    /// let first10 = naturals.prefix(10)
    /// // [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    /// ```
    ///
    /// ## Built-in Enumerable Types
    ///
    /// - ``Repeat``: Constant repetition
    /// - ``Iterate``: Repeated function application
    /// - ``Unfold``: Full anamorphism
    /// - ``Cycle``: Cycling a finite collection
    /// - ``Map``: Lazy transformation
    /// - ``Zip``: Parallel combination
    /// - ``Scan``: Running accumulation
    public protocol Enumerable {
        associatedtype Element
        associatedtype Iterator: ~Copyable, Iterator_Primitive.Iterator.`Protocol`
        where Iterator.Element == Element, Iterator.Failure == Never
        func makeIterator() -> Iterator
    }
}

// MARK: - Prefix

extension Infinite.Enumerable where Element: Copyable {
    /// Returns an array containing the first `maxLength` elements.
    ///
    /// - Parameter maxLength: The maximum number of elements to return.
    /// - Returns: An array of up to `maxLength` elements.
    @inlinable
    public func prefix(_ maxLength: Int) -> [Element] {
        var iter = makeIterator()
        var result: [Element] = []
        result.reserveCapacity(maxLength)
        for _ in 0..<maxLength {
            guard let element = iter.next() else { break }
            result.append(element)
        }
        return result
    }
}
