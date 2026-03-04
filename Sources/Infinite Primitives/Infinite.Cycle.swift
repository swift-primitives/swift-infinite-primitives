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

// MARK: - Iteration

extension Infinite.Cycle {
    /// Returns an iterator over this cycling sequence.
    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(base: base)
    }

    /// An iterator that cycles through a collection indefinitely.
    ///
    /// Uses the **heap buffer** iterator strategy: a single heap-allocated
    /// element buffer for span-based access. One allocation per iterator
    /// lifetime. The `deinit` ensures deterministic cleanup.
    @safe public struct Iterator: ~Copyable, Sequence.Iterator.`Protocol` {
        public typealias Element = Base.Element

        @usableFromInline
        let base: Base

        @usableFromInline
        var index: Base.Index

        @usableFromInline
        let _mutableBuffer: UnsafeMutablePointer<Base.Element>

        @usableFromInline
        var _bufferPtr: UnsafePointer<Base.Element>

        @usableFromInline
        var _bufferInitialized: Bool

        @inlinable
        init(base: Base) {
            self.base = base
            self.index = base.startIndex
            let buf = UnsafeMutablePointer<Base.Element>.allocate(capacity: 1)
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
        public mutating func nextSpan(maximumCount: Cardinal) -> Span<Base.Element> {
            guard maximumCount > .zero else {
                return unsafe Span(_unsafeStart: _bufferPtr, count: 0)
            }
            let element = base[index]
            base.formIndex(after: &index)
            if index == base.endIndex {
                index = base.startIndex
            }
            if _bufferInitialized {
                unsafe _mutableBuffer.deinitialize(count: 1)
            }
            unsafe _mutableBuffer.initialize(to: element)
            _bufferInitialized = true
            let span = unsafe Span(_unsafeStart: _bufferPtr, count: 1)
            return unsafe _overrideLifetime(span, mutating: &self)
        }

        /// Returns the next element, wrapping to the start when exhausted.
        @_lifetime(self: immortal)
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
