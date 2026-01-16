// Infinite.Observable.swift
// Primary coalgebraic protocol for head/tail observation.

extension Infinite {
    /// A type representing an infinite sequence via coalgebraic observation.
    ///
    /// `Observable` is the coalgebraic dual of construction-based types. Where finite
    /// sequences are built by indexing (ordinal → value), infinite sequences are
    /// observed by decomposition (head + tail).
    ///
    /// ## Coalgebraic Structure
    ///
    /// An `Observable` defines a copattern—instead of constructing values, you
    /// observe them:
    /// - `head`: The current element
    /// - `tail`: The remaining infinite sequence
    ///
    /// This models the mathematical concept of a coalgebra for the functor
    /// `F(X) = A × X`, where observation yields a pair of the current value
    /// and the continuation.
    ///
    /// ## Relationship to Enumerable
    ///
    /// `Observable` refines `Enumerable`, meaning all Observable types are also
    /// infinite Sequences. This enables composition: transformers like `Map` can
    /// require `Enumerable` for basic iteration while gaining `Observable`
    /// conformance when their source is Observable.
    ///
    /// Not all `Enumerable` types are `Observable` (e.g., stateful iterators
    /// without pure decomposition).
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct Naturals: Infinite.Observable {
    ///     let start: Int
    ///
    ///     var head: Int { start }
    ///     var tail: Naturals { Naturals(start: start + 1) }
    /// }
    ///
    /// let n = Naturals(start: 0)
    /// print(n.head)           // 0
    /// print(n.tail.head)      // 1
    /// print(n.tail.tail.head) // 2
    /// ```
    ///
    /// ## Laws
    ///
    /// For any observable `s`:
    /// - Decomposition is pure: observing `head` and `tail` multiple times
    ///   yields the same values
    /// - The sequence is infinite: `tail` always produces a valid `Observable`
    ///
    /// ## Tail Type
    ///
    /// The `Tail` associated type is constrained to `Observable` with matching `Element`.
    /// This captures the coalgebraic essence: the tail of an infinite sequence is also
    /// an infinite sequence of the same element type.
    public protocol Observable: Enumerable, Sendable where Element: Sendable {
        /// The type of the tail (remaining sequence after head).
        ///
        /// Often `Self`, but may differ for transformer types like `Map` or `Zip`.
        /// The tail must also be Observable with the same Element type.
        associatedtype Tail: Observable where Tail.Element == Element

        /// The first element of this infinite sequence.
        var head: Element { get }

        /// The infinite sequence following the head.
        var tail: Tail { get }
    }
}

// MARK: - Homogeneous Observable Iterator

/// An iterator for Observable types where Tail == Self.
///
/// Converts coalgebraic observation (head/tail) into iterative access.
/// Only available when the tail type equals the source type, enabling
/// efficient iteration without type erasure.
public struct HomogeneousObservableIterator<Source: Infinite.Observable>: IteratorProtocol, Sendable
where Source.Tail == Source {
    @usableFromInline
    var current: Source

    @inlinable
    init(_ source: Source) {
        self.current = source
    }

    /// Returns the next element, advancing the iterator.
    @inlinable
    public mutating func next() -> Source.Element? {
        let element = current.head
        current = current.tail
        return element
    }
}

extension Infinite.Observable where Tail == Self {
    /// Returns an iterator for homogeneous observable sequences.
    @inlinable
    public func makeIterator() -> HomogeneousObservableIterator<Self> {
        HomogeneousObservableIterator(self)
    }
}
