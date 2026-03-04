// Infinite.Scan.swift
// Running accumulation over an infinite sequence (scanl).

public import Index_Primitives

extension Infinite {
    /// An infinite sequence of running accumulations.
    ///
    /// `Scan` (also known as `scanl` or prefix sum) produces intermediate
    /// accumulator values as it processes each element of the source sequence.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Running sum of natural numbers
    /// let naturals = Infinite.Iterate(initial: 1) { $0 + 1 }
    /// let runningSums = Infinite.Scan(initial: 0, source: naturals) { acc, n in acc + n }
    /// let first6 = runningSums.prefix(6) // [0, 1, 3, 6, 10, 15]
    ///
    /// // Using the extension method
    /// let factorials = naturals.scan(initial: 1) { acc, n in acc * n }
    /// let first6fac = factorials.prefix(6) // [1, 1, 2, 6, 24, 120]
    /// ```
    ///
    /// ## Behavior
    ///
    /// The sequence starts with the initial value, then for each source element,
    /// produces `combine(accumulator, element)`:
    /// ```
    /// scan(init, [a, b, c, ...], f) = [init, f(init, a), f(f(init, a), b), ...]
    /// ```
    ///
    /// ## Mathematical Interpretation
    ///
    /// `Scan` is the mealy machine corecursively defined as:
    /// ```
    /// scan(s, xs, f) = s : scan(f(s, head(xs)), tail(xs), f)
    /// ```
    public struct Scan<Source: Infinite.Enumerable, Result> {
        /// The initial accumulator value.
        @usableFromInline
        let initial: Result

        /// The source infinite sequence.
        @usableFromInline
        let source: Source

        /// The combining function.
        @usableFromInline
        let combine: @Sendable (Result, Source.Element) -> Result

        /// Creates a scanning infinite sequence.
        ///
        /// - Parameters:
        ///   - initial: The initial accumulator value (first element of output).
        ///   - source: The source infinite sequence.
        ///   - combine: A function that combines the accumulator with each source element.
        @inlinable
        public init(
            initial: Result,
            source: Source,
            _ combine: @escaping @Sendable (Result, Source.Element) -> Result
        ) {
            self.initial = initial
            self.source = source
            self.combine = combine
        }
    }
}

// MARK: - Iteration

extension Infinite.Scan {
    /// Returns an iterator over this scanning sequence.
    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(accumulator: initial, source: source.makeIterator(), combine: combine)
    }

    /// An iterator that produces running accumulations.
    ///
    /// Uses the **heap buffer** iterator strategy: a single heap-allocated
    /// element buffer for span-based access. One allocation per iterator
    /// lifetime. The `deinit` ensures deterministic cleanup.
    @safe public struct Iterator: ~Copyable, Sequence.Iterator.`Protocol` {
        public typealias Element = Result

        @usableFromInline
        var accumulator: Result

        @usableFromInline
        var source: Source.Iterator

        @usableFromInline
        let combine: @Sendable (Result, Source.Element) -> Result

        @usableFromInline
        var emittedInitial: Bool = false

        @usableFromInline
        let _mutableBuffer: UnsafeMutablePointer<Result>

        @usableFromInline
        var _bufferPtr: UnsafePointer<Result>

        @usableFromInline
        var _bufferInitialized: Bool

        @inlinable
        init(
            accumulator: Result,
            source: consuming Source.Iterator,
            combine: @escaping @Sendable (Result, Source.Element) -> Result
        ) {
            self.accumulator = accumulator
            self.source = source
            self.combine = combine
            let buf = UnsafeMutablePointer<Result>.allocate(capacity: 1)
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
        public mutating func nextSpan(maximumCount: Cardinal) -> Span<Result> {
            guard maximumCount > .zero else {
                return unsafe Span(_unsafeStart: _bufferPtr, count: 0)
            }
            let element: Result
            if !emittedInitial {
                emittedInitial = true
                element = accumulator
            } else {
                guard let sourceElement = source.next() else {
                    return unsafe Span(_unsafeStart: _bufferPtr, count: 0)
                }
                accumulator = combine(accumulator, sourceElement)
                element = accumulator
            }
            if _bufferInitialized {
                unsafe _mutableBuffer.deinitialize(count: 1)
            }
            unsafe _mutableBuffer.initialize(to: element)
            _bufferInitialized = true
            let span = unsafe Span(_unsafeStart: _bufferPtr, count: 1)
            return unsafe _overrideLifetime(span, mutating: &self)
        }

        /// Returns the next accumulator value.
        @_lifetime(self: immortal)
        @inlinable
        public mutating func next() -> Result? {
            if !emittedInitial {
                emittedInitial = true
                return accumulator
            }
            guard let element = source.next() else { return nil }
            accumulator = combine(accumulator, element)
            return accumulator
        }
    }
}

// MARK: - Sendable

extension Infinite.Scan: Sendable where Source: Sendable, Result: Sendable {}
extension Infinite.Scan.Iterator: @unchecked Sendable where Source.Iterator: Sendable, Result: Sendable {}

// MARK: - Enumerable

extension Infinite.Scan: Infinite.Enumerable {}

// MARK: - Enumerable Extension

extension Infinite.Enumerable {
    /// Returns an infinite sequence of running accumulations.
    ///
    /// - Parameters:
    ///   - initial: The initial accumulator value (first element of output).
    ///   - combine: A function that combines the accumulator with each element.
    /// - Returns: An infinite sequence of accumulator values.
    @inlinable
    public func scan<T>(
        initial: T,
        _ combine: @escaping @Sendable (T, Element) -> T
    ) -> Infinite.Scan<Self, T> {
        Infinite.Scan(initial: initial, source: self, combine)
    }
}
