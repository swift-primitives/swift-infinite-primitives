// Infinite.swift
// Namespace for infinite/unbounded sequence infrastructure.

/// Namespace for infinite sequence infrastructure.
///
/// `Infinite` contains types for working with unbounded sequences—sequences
/// that do not terminate or whose length is not known at compile time.
///
/// ## Core Protocols
///
/// - ``Observable``: Coalgebraic protocol for head/tail decomposition
/// - ``Enumerable``: Marker protocol for infinite `Sequence` types
///
/// ## Generators
///
/// - ``Repeat``: Constant repetition of a single value
/// - ``Iterate``: Repeated function application `x, f(x), f(f(x)), ...`
/// - ``Unfold``: Full anamorphism with separate state and element types
/// - ``Cycle``: Cycling through a finite collection indefinitely
///
/// ## Transformers
///
/// - ``Map``: Lazy element-wise transformation
/// - ``Zip``: Parallel combination of two sequences
/// - ``Scan``: Running accumulation (prefix sums)
///
/// ## Algebraic vs Coalgebraic
///
/// Where `Finite.Enumerable` provides algebraic construction (index → value),
/// `Infinite.Observable` provides coalgebraic observation (head + tail).
///
/// | Finite (Algebraic) | Infinite (Coalgebraic) |
/// |-------------------|----------------------|
/// | `count` - known cardinality | N/A - unbounded |
/// | `ordinal` - random access | `head` - current element |
/// | `init(ordinal:)` - construction | `tail` - continuation |
/// | Catamorphism (fold) | Anamorphism (unfold) |
///
/// ## Example
///
/// ```swift
/// // Create infinite sequences
/// let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
/// let squares = naturals.map { $0 * $0 }
/// let pairs = Infinite.zip(naturals, squares)
///
/// // Take finite prefixes
/// print(Array(pairs.prefix(5)))
/// // [(0, 0), (1, 1), (2, 4), (3, 9), (4, 16)]
///
/// // Use coalgebraic observation
/// print(naturals.head)           // 0
/// print(naturals.tail.head)      // 1
/// print(naturals.tail.tail.head) // 2
/// ```
public enum Infinite: Sendable {}
