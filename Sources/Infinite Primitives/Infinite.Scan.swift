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
    /// Uses `Optional<Result>` as inline storage for span-based access.
    /// Zero heap allocation. The Optional payload is at byte offset 0
    /// (ABI guarantee for single-payload enums), enabling safe reinterpretation
    /// as a `Span<Result>` via `withUnsafeMutablePointer`.
    public struct Iterator: ~Copyable, Sequence.Iterator.`Protocol` {
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
        var _element: Result? = nil

        @inlinable
        init(
            accumulator: Result,
            source: consuming Source.Iterator,
            combine: @escaping @Sendable (Result, Source.Element) -> Result
        ) {
            self.accumulator = accumulator
            self.source = source
            self.combine = combine
        }

        /// Returns the next batch of elements as a contiguous span.
        @_lifetime(&self)
        @inlinable
        public mutating func nextSpan(maximumCount: Cardinal) -> Span<Result> {
            let ptr = unsafe withUnsafeMutablePointer(to: &_element) { p in
                unsafe UnsafePointer<Result>(
                    unsafe UnsafeRawPointer(p).assumingMemoryBound(to: Result.self)
                )
            }
            guard maximumCount > .zero else {
                let span = unsafe Span(_unsafeStart: ptr, count: 0)
                return unsafe _overrideLifetime(span, mutating: &self)
            }
            if !emittedInitial {
                emittedInitial = true
                _element = accumulator
            } else {
                guard let sourceElement = source.next() else {
                    let span = unsafe Span(_unsafeStart: ptr, count: 0)
                    return unsafe _overrideLifetime(span, mutating: &self)
                }
                accumulator = combine(accumulator, sourceElement)
                _element = accumulator
            }
            let span = unsafe Span(_unsafeStart: ptr, count: 1)
            return unsafe _overrideLifetime(span, mutating: &self)
        }

        /// Returns the next accumulator value.
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
