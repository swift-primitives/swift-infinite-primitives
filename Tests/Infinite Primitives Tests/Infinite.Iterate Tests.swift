// Infinite.Iterate Tests.swift

import Testing
import Testing

@testable import Infinite_Primitives

// Note: Generic types cannot use #Tests directly.
// We use @Suite with nested structure to match the organizational pattern.

@Suite("Infinite.Iterate")
struct InfiniteIterateTests {
    @Suite struct Unit {
        @Test("natural numbers")
        func naturalNumbers() {
            let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
            let first10 = Array(naturals.prefix(10))
            #expect(first10 == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        }

        @Test("powers of 2")
        func powersOfTwo() {
            let powers = Infinite.Iterate(initial: 1) { $0 * 2 }
            let first10 = Array(powers.prefix(10))
            #expect(first10 == [1, 2, 4, 8, 16, 32, 64, 128, 256, 512])
        }

        @Test("head returns initial value")
        func headReturnsInitialValue() {
            let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
            #expect(naturals.head == 0)
        }

        @Test("tail advances by one application")
        func tailAdvancesByOneApplication() {
            let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
            #expect(naturals.tail.head == 1)
            #expect(naturals.tail.tail.head == 2)
        }

        @Test("head/tail matches iteration")
        func headTailMatchesIteration() {
            let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }

            var current = naturals
            var headValues: [Int] = []
            for _ in 0..<5 {
                headValues.append(current.head)
                current = current.tail
            }

            #expect(headValues == [0, 1, 2, 3, 4])
        }

        @Test("works with complex transform")
        func worksWithComplexTransform() {
            // Collatz-like sequence starting from 10
            let seq = Infinite.Iterate(initial: 10) { n in
                n % 2 == 0 ? n / 2 : 3 * n + 1
            }
            let first10 = Array(seq.prefix(10))
            #expect(first10 == [10, 5, 16, 8, 4, 2, 1, 4, 2, 1])
        }

        @Test("works with non-numeric types")
        func worksWithNonNumericTypes() {
            let strings = Infinite.Iterate(initial: "a") { $0 + "a" }
            let first5 = Array(strings.prefix(5))
            #expect(first5 == ["a", "aa", "aaa", "aaaa", "aaaaa"])
        }
    }
}
