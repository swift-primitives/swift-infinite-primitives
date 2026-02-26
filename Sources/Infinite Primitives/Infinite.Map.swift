// Infinite.Map.swift
// Lazy transformation of infinite sequences.

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
    /// print(Array(squares.prefix(5))) // [0, 1, 4, 9, 16]
    ///
    /// // Using the extension method
    /// let cubes = naturals.map { $0 * $0 * $0 }
    /// print(Array(cubes.prefix(5))) // [0, 1, 8, 27, 64]
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
    public struct Map<Source: Infinite.Enumerable & Sendable, Element: Sendable>: Sendable {
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

// MARK: - Sequence

extension Infinite.Map: Swift.Sequence {
    /// Returns an iterator over this mapped sequence.
    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(base: source.makeIterator(), transform: transform)
    }

    /// An iterator that applies a transformation to each element.
    public struct Iterator: Sequence.Iterator.`Protocol`, IteratorProtocol {
        @usableFromInline
        var base: Source.Iterator

        @usableFromInline
        let transform: @Sendable (Source.Element) -> Element

        @inlinable
        init(base: Source.Iterator, transform: @escaping @Sendable (Source.Element) -> Element) {
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

extension Infinite.Map.Iterator: Sendable where Source.Iterator: Sendable {}

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

extension Infinite.Enumerable where Self: Sendable {
    /// Returns an infinite sequence with elements transformed by the given closure.
    ///
    /// - Parameter transform: A closure that transforms each element.
    /// - Returns: An infinite sequence of transformed elements.
    @inlinable
    public func map<T: Sendable>(_ transform: @escaping @Sendable (Element) -> T) -> Infinite.Map<Self, T> {
        Infinite.Map(self, transform)
    }
}
