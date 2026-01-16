// Infinite.Observable.Iterator.swift
// Iterator for homogeneous Observable types (where Tail == Self).

/// Hoisted iterator for `Infinite.Observable.Iterator`.
///
/// This is the canonical `Iterator` type for all `Observable` types where `Tail == Self`.
/// For such types (like `Repeat`, `Iterate`, `Unfold`), `SomeType.Iterator` is this type.
///
/// Converts coalgebraic observation (head/tail) into iterative access.
///
/// ## Usage
///
/// This iterator is automatically used when you call `makeIterator()` on
/// any `Observable` type where `Tail == Self`:
///
/// ```swift
/// let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
/// for n in naturals.prefix(10) {
///     print(n)  // Uses Infinite.Observable.Iterator
/// }
///
/// // Access via concrete type's Iterator:
/// let iter: Infinite.Iterate<Int>.Iterator = naturals.makeIterator()
/// ```
///
/// - Note: This type is hoisted to module level with `__` prefix because Swift
///   doesn't allow types nested in protocols. The canonical name is
///   `Infinite.Observable.Iterator` (reflected in file name and documentation).
public struct __InfiniteObservableIterator<Source: Infinite.Observable>: IteratorProtocol, Sendable
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

// MARK: - Sequence Conformance

extension Infinite.Observable where Tail == Self {
    /// Returns an iterator for this observable sequence.
    ///
    /// This default implementation is used by all homogeneous Observable types
    /// (where `Tail == Self`), providing the unified `Infinite.Observable.Iterator` type.
    @inlinable
    public func makeIterator() -> __InfiniteObservableIterator<Self> {
        __InfiniteObservableIterator(self)
    }
}
