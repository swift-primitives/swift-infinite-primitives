// Infinite.Cycle Tests.swift

import Testing
import Testing

@testable import Infinite_Primitives

// Note: Generic types cannot use #Tests directly.
// We use @Suite with nested structure to match the organizational pattern.

@Suite("Infinite.Cycle")
struct InfiniteCycleTests {
    @Suite struct Unit {
        @Test("cycles through array")
        func cyclesThroughArray() {
            let colors = Infinite.Cycle(["red", "green", "blue"])!
            let first10 = Array(colors.prefix(10))
            #expect(first10 == ["red", "green", "blue", "red", "green", "blue", "red", "green", "blue", "red"])
        }

        @Test("cycles through single element")
        func cyclesThroughSingleElement() {
            let ones = Infinite.Cycle([1])!
            let first5 = Array(ones.prefix(5))
            #expect(first5 == [1, 1, 1, 1, 1])
        }

        @Test("unchecked init works for non-empty")
        func uncheckedInitWorks() {
            let cycle = Infinite.Cycle(__unchecked: (), [1, 2, 3])
            #expect(Array(cycle.prefix(6)) == [1, 2, 3, 1, 2, 3])
        }

        @Test("works with different collection types")
        func worksWithDifferentCollectionTypes() {
            // String (collection of characters)
            let chars = Infinite.Cycle("abc")!
            let first6 = Array(chars.prefix(6))
            #expect(first6 == ["a", "b", "c", "a", "b", "c"])
        }

        @Test("head returns first element")
        func headReturnsFirstElement() {
            let cycle = Infinite.Cycle([1, 2, 3])!
            #expect(cycle.head == 1)
        }

        @Test("tail head returns second element")
        func tailHeadReturnsSecondElement() {
            let cycle = Infinite.Cycle([1, 2, 3])!
            #expect(cycle.tail.head == 2)
        }

        @Test("tail wraps around")
        func tailWrapsAround() {
            let cycle = Infinite.Cycle([1, 2, 3])!
            #expect(cycle.tail.tail.tail.head == 1)
        }

        @Test("head/tail matches iteration for first few elements")
        func headTailMatchesIteration() {
            let cycle = Infinite.Cycle([1, 2, 3])!

            // Since tail type changes after first access (becomes Rotated),
            // we verify the first element and then verify iteration matches head
            #expect(cycle.head == 1)

            let iteratedValues = Array(cycle.prefix(6))
            #expect(iteratedValues == [1, 2, 3, 1, 2, 3])
        }

        @Test("equal bases are equal")
        func equalBasesAreEqual() {
            let a = Infinite.Cycle([1, 2, 3])!
            let b = Infinite.Cycle([1, 2, 3])!
            #expect(a == b)
        }

        @Test("different bases are not equal")
        func differentBasesAreNotEqual() {
            let a = Infinite.Cycle([1, 2, 3])!
            let b = Infinite.Cycle([1, 2, 4])!
            #expect(a != b)
        }
    }

    @Suite struct EdgeCase {
        @Test("init returns nil for empty collection")
        func initReturnsNilForEmpty() {
            let empty: Infinite.Cycle<[Int]>? = Infinite.Cycle([])
            #expect(empty == nil)
        }
    }
}
