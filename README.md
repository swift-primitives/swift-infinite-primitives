# Infinite Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Infinite-sequence value types for Swift — an `Infinite` namespace of lazy stream generators (`Repeat`, `Iterate`, `Unfold`, `Cycle`) and transformers (`Map`, `Zip`, `Scan`) over a head/tail coalgebra, with zero platform dependencies.

---

## Quick Start

`Infinite` models sequences that never end. Where a finite collection is *built* by indexing (ordinal → value), an infinite sequence is *observed* by decomposition: a `head` (the current element) and a `tail` (the rest of the stream). That coalgebraic view is captured by `Infinite.Observable`; the iterator-based view, used by `prefix`, is `Infinite.Enumerable`. Concrete types conform to both when possible.

```swift
import Infinite_Primitives

// Generate the naturals by repeated function application: 0, 1, 2, 3, ...
let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }

// Transformers compose lazily and stay infinite.
let squares = naturals.map { $0 * $0 }
let pairs = Infinite.zip(naturals, squares)

// Cross into the finite world only when you take a prefix.
print(pairs.prefix(5))
// [(0, 0), (1, 1), (2, 4), (3, 9), (4, 16)]

// Or observe head/tail directly — no iterator, no mutation.
print(naturals.head)            // 0
print(naturals.tail.head)       // 1
print(naturals.tail.tail.head)  // 2
```

`Unfold` is the general anamorphism: it carries hidden state separate from the emitted element, so a single value can be produced from a richer step. `Scan` threads a running accumulator through a source, emitting every intermediate result; `Cycle` repeats a finite collection forever.

```swift
import Infinite_Primitives

// Fibonacci: state is a pair, but each step emits a single value.
let fib = Infinite.Unfold(seed: (0, 1)) { a, b in (a, (b, a + b)) }
print(Array(fib.prefix(10)))   // [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]

// Running sums via a left scan.
let runningSums = naturals.scan(initial: 0) { acc, n in acc + n }
print(runningSums.prefix(6))   // [0, 1, 3, 6, 10, 15]

// Cycle a finite collection indefinitely (failable: nil on empty input).
let colors = Infinite.Cycle(["red", "green", "blue"])!
print(colors.prefix(7))
// ["red", "green", "blue", "red", "green", "blue", "red"]
```

Unlike `Swift.zip`, `Infinite.zip` never terminates early — both sources are unbounded, so the result is too. Iterators are `~Copyable` single-use values with inline storage and no heap allocation; `prefix` is the safe bridge that materializes a bounded number of elements into an array.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-infinite-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Infinite Primitives", package: "swift-infinite-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

Two library products. Depends only on the `Collection`, `Input`, and `Iterator` primitives.

| Product | Target | Purpose |
|---------|--------|---------|
| `Infinite Primitives` | `Sources/Infinite Primitives/` | The `Infinite` namespace: the protocols `Observable` (head/tail coalgebra) and `Enumerable` (forward iteration); the generators `Repeat`, `Iterate`, `Unfold`, `Cycle`; and the transformers `Map`, `Zip`, `Scan`. |
| `Infinite Primitives Test Support` | `Tests/Support/` | Re-exports the main target for test consumers. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
