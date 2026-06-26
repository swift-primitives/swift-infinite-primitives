// Infinite.Observable.Iterator.swift
// Iterator for homogeneous Observable types (where Tail == Self).

public import Iterator_Protocol

/// Hoisted iterator for `Infinite.Observable.Iterator`.
///
/// This is the canonical `Iterator` type for all `Observable` types where `Tail == Self`.
/// For such types (like `Repeat`, `Iterate`, `Unfold`), `SomeType.Iterator` is this type.
///
/// Converts coalgebraic observation (head/tail) into iterative access.
///
/// Uses `Optional<Source.Element>` as inline storage for span-based access.
/// Zero heap allocation. The Optional payload is at byte offset 0
/// (ABI guarantee for single-payload enums), enabling safe reinterpretation
/// as a `Span<Source.Element>` via `withUnsafeMutablePointer`.
///
/// - Note: This type is hoisted to module level with `__` prefix because Swift
///   doesn't allow types nested in protocols. The canonical name is
///   `Infinite.Observable.Iterator` (reflected in file name and documentation).
public struct __InfiniteObservableIterator<Source: Infinite.Observable>: ~Copyable, Iterator_Primitive.Iterator.`Protocol`
where Source.Tail == Source {
    /// The element type: the source observable's element.
    public typealias Element = Source.Element

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

// MARK: - Sendable

// WHY: Category D — structural Sendable workaround (SP-4).
// WHY: ~Copyable is for single-use iteration semantics, not resource ownership.
// WHY: Generic parameter blocks structural Sendable inference.
// WHEN TO REMOVE: When compiler gains structural Sendable through generic params.
// TRACKING: unsafe-audit-findings.md Category D SP-4.
extension __InfiniteObservableIterator: @unchecked Sendable where Source: Sendable {}

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
