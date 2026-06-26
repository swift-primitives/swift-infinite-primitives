// Infinite.Map.swift
// Lazy transformation of infinite sequences.

public import Iterator_Protocol

extension Infinite {
    /// A lazy transformation of an infinite sequence.
    ///
    /// `Map` applies a transformation to each element of an infinite sequence,
    /// producing another infinite sequence. The transformation is applied lazily
    /// as elements are accessed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
    /// let squares = Infinite.Map(naturals) { $0 * $0 }
    /// let first5 = squares.prefix(5) // [0, 1, 4, 9, 16]
    ///
    /// // Using the extension method
    /// let cubes = naturals.map { $0 * $0 * $0 }
    /// let first5cubes = cubes.prefix(5) // [0, 1, 8, 27, 64]
    /// ```
    ///
    /// ## Preservation of Infiniteness
    ///
    /// Unlike `filter`, which may not preserve infiniteness, `map` always
    /// preserves it—each input element produces exactly one output element.
    ///
    /// ## Observable Conformance
    ///
    /// `Map` conforms to `Observable` when the source does. The `Tail` type
    /// is `Map<Source.Tail, Element>`, enabling heterogeneous transformer chains.
    public struct Map<Source: Infinite.Enumerable, Element> {
        /// The source infinite sequence.
        @usableFromInline
        let source: Source

        /// The transformation applied to each element.
        @usableFromInline
        let transform: @Sendable (Source.Element) -> Element

        /// Creates a mapped infinite sequence.
        ///
        /// - Parameters:
        ///   - source: The source infinite sequence.
        ///   - transform: The transformation to apply to each element.
        @inlinable
        public init(_ source: Source, _ transform: @escaping @Sendable (Source.Element) -> Element) {
            self.source = source
            self.transform = transform
        }
    }
}

// MARK: - Iteration

extension Infinite.Map {
    /// Returns an iterator over this mapped sequence.
    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(base: source.makeIterator(), transform: transform)
    }

    /// An iterator that applies a transformation to each element.
    ///
    /// Uses `Optional<Element>` as inline storage for span-based access.
    /// Zero heap allocation. The Optional payload is at byte offset 0
    /// (ABI guarantee for single-payload enums), enabling safe reinterpretation
    /// as a `Span<Element>` via `withUnsafeMutablePointer`.
    public struct Iterator: ~Copyable, Iterator_Primitive.Iterator.`Protocol` {
        @usableFromInline
        var base: Source.Iterator

        @usableFromInline
        let transform: @Sendable (Source.Element) -> Element

        @inlinable
        init(base: consuming Source.Iterator, transform: @escaping @Sendable (Source.Element) -> Element) {
            self.base = base
            self.transform = transform
        }

        /// Returns the transformed next element.
        @inlinable
        public mutating func next() -> Element? {
            base.next().map(transform)
        }
    }
}

// MARK: - Sendable

extension Infinite.Map: Sendable where Source: Sendable {}
// WHY: Category D — structural Sendable workaround (SP-4).
// WHY: ~Copyable is for single-use iteration semantics, not resource ownership.
// WHY: Generic parameter blocks structural Sendable inference.
// WHEN TO REMOVE: When compiler gains structural Sendable through generic params.
// TRACKING: unsafe-audit-findings.md Category D SP-4.
extension Infinite.Map.Iterator: @unchecked Sendable where Source.Iterator: Sendable {}

// MARK: - Enumerable

extension Infinite.Map: Infinite.Enumerable {}

// MARK: - Observable

extension Infinite.Map: Infinite.Observable
where Source: Infinite.Observable {
    /// The transformed head element.
    @inlinable
    public var head: Element {
        transform(source.head)
    }

    /// The mapped tail sequence.
    @inlinable
    public var tail: Infinite.Map<Source.Tail, Element> {
        Infinite.Map<Source.Tail, Element>(source.tail, transform)
    }
}

// MARK: - Enumerable Extension

extension Infinite.Enumerable {
    /// Returns an infinite sequence with elements transformed by the given closure.
    ///
    /// - Parameter transform: A closure that transforms each element.
    /// - Returns: An infinite sequence of transformed elements.
    @inlinable
    public func map<T>(_ transform: @escaping @Sendable (Element) -> T) -> Infinite.Map<Self, T> {
        Infinite.Map(self, transform)
    }
}
