// Infinite.Observable.Iterator.swift
// Iterator for homogeneous Observable types (where Tail == Self).

public import Index_Primitives

/// Hoisted iterator for `Infinite.Observable.Iterator`.
///
/// This is the canonical `Iterator` type for all `Observable` types where `Tail == Self`.
/// For such types (like `Repeat`, `Iterate`, `Unfold`), `SomeType.Iterator` is this type.
///
/// Converts coalgebraic observation (head/tail) into iterative access.
///
/// Uses the **heap buffer** iterator strategy: a single heap-allocated
/// element buffer for span-based access. One allocation per iterator
/// lifetime. The `deinit` ensures deterministic cleanup.
///
/// - Note: This type is hoisted to module level with `__` prefix because Swift
///   doesn't allow types nested in protocols. The canonical name is
///   `Infinite.Observable.Iterator` (reflected in file name and documentation).
@safe public struct __InfiniteObservableIterator<Source: Infinite.Observable>: ~Copyable, Sequence.Iterator.`Protocol`
where Source.Tail == Source {
    public typealias Element = Source.Element

    @usableFromInline
    var current: Source

    @usableFromInline
    let _mutableBuffer: UnsafeMutablePointer<Source.Element>

    @usableFromInline
    var _bufferPtr: UnsafePointer<Source.Element>

    @usableFromInline
    var _bufferInitialized: Bool

    @inlinable
    init(_ source: Source) {
        self.current = source
        let buf = UnsafeMutablePointer<Source.Element>.allocate(capacity: 1)
        unsafe self._mutableBuffer = buf
        unsafe self._bufferPtr = UnsafePointer(buf)
        self._bufferInitialized = false
    }

    deinit {
        if _bufferInitialized {
            unsafe _mutableBuffer.deinitialize(count: 1)
        }
        unsafe _mutableBuffer.deallocate()
    }

    /// Returns the next batch of elements as a contiguous span.
    @_lifetime(&self)
    @inlinable
    public mutating func nextSpan(maximumCount: Cardinal) -> Span<Source.Element> {
        guard maximumCount > .zero else {
            return unsafe Span(_unsafeStart: _bufferPtr, count: 0)
        }
        let element = current.head
        current = current.tail
        if _bufferInitialized {
            unsafe _mutableBuffer.deinitialize(count: 1)
        }
        unsafe _mutableBuffer.initialize(to: element)
        _bufferInitialized = true
        let span = unsafe Span(_unsafeStart: _bufferPtr, count: 1)
        return unsafe _overrideLifetime(span, mutating: &self)
    }

    /// Returns the next element, advancing the iterator.
    @_lifetime(self: immortal)
    @inlinable
    public mutating func next() -> Source.Element? {
        let element = current.head
        current = current.tail
        return element
    }
}

// MARK: - Sendable

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
