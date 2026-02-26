// Infinite.Enumerable.swift
// Protocol for types representing unbounded iteration.

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
    /// Use `Enumerable` for iterator-based algorithms (e.g., `prefix`, `dropFirst`).
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
    /// struct Fibonacci: Infinite.Enumerable {
    ///     func makeIterator() -> Iterator {
    ///         Iterator()
    ///     }
    ///
    ///     struct Iterator: IteratorProtocol, Sendable {
    ///         var a = 0, b = 1
    ///         mutating func next() -> Int? {
    ///             let result = a
    ///             (a, b) = (b, a + b)
    ///             return result
    ///         }
    ///     }
    /// }
    ///
    /// // Take first 10 Fibonacci numbers
    /// for n in Fibonacci().prefix(10) {
    ///     print(n)
    /// }
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
    public protocol Enumerable: Swift.Sequence, Sendable {}
}
