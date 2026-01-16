// Infinite.Repeat.swift
// Constant infinite repetition of a single value.

extension Infinite {
    /// An infinite sequence that repeats a single value forever.
    ///
    /// `Repeat` is the simplest `Observable`—it produces the same element
    /// indefinitely. This is the infinite analog of a singleton or constant.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let ones = Infinite.Repeat(1)
    /// print(ones.head)           // 1
    /// print(ones.tail.head)      // 1
    /// print(Array(ones.prefix(5))) // [1, 1, 1, 1, 1]
    /// ```
    ///
    /// ## Mathematical Interpretation
    ///
    /// `Repeat(x)` corresponds to the constant stream corecursively defined as:
    /// ```
    /// repeat(x) = x : repeat(x)
    /// ```
    ///
    /// In category theory, this is the unique morphism from the terminal object
    /// to the carrier of the stream coalgebra.
    public struct Repeat<Element: Sendable>: Sendable {
        /// The value repeated infinitely.
        public let value: Element

        /// Creates an infinite repetition of the given value.
        ///
        /// - Parameter value: The value to repeat forever.
        @inlinable
        public init(_ value: Element) {
            self.value = value
        }
    }
}

// MARK: - Observable

extension Infinite.Repeat: Infinite.Observable {
    /// The repeated element.
    @inlinable
    public var head: Element { value }

    /// The same infinite repetition (self-referential tail).
    @inlinable
    public var tail: Self { self }
}

// MARK: - Sequence

extension Infinite.Repeat: Sequence {
    /// Returns an iterator over this infinite repetition.
    @inlinable
    public func makeIterator() -> Iterator {
        Iterator(value)
    }

    /// An iterator that produces the same value indefinitely.
    public struct Iterator: IteratorProtocol, Sendable {
        @usableFromInline
        let value: Element

        @inlinable
        init(_ value: Element) {
            self.value = value
        }

        /// Returns the repeated value.
        @inlinable
        public mutating func next() -> Element? {
            value
        }
    }
}

// MARK: - Enumerable

extension Infinite.Repeat: Infinite.Enumerable {}

// MARK: - Equatable

extension Infinite.Repeat: Equatable where Element: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}

// MARK: - Hashable

extension Infinite.Repeat: Hashable where Element: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
