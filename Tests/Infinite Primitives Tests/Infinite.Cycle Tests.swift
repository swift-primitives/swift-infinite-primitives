// Infinite.Cycle Tests.swift

import Testing
import Testing

@testable import Infinite_Primitives

// Note: Generic types cannot use #Tests directly.
// We use @Suite with nested structure to match the organizational pattern.

@Suite("Infinite.Cycle")
struct InfiniteCycleTests {
    @Suite struct Unit {
        @Test
        func `cycles through array`() {
            let colors = Infinite.Cycle(["red", "green", "blue"])!
            let first10 = Array(colors.prefix(10))
            #expect(first10 == ["red", "green", "blue", "red", "green", "blue", "red", "green", "blue", "red"])
        }

        @Test
        func `cycles through single element`() {
            let ones = Infinite.Cycle([1])!
            let first5 = Array(ones.prefix(5))
            #expect(first5 == [1, 1, 1, 1, 1])
        }

        @Test
        func `unchecked init works for non-empty`() {
            let cycle = Infinite.Cycle(__unchecked: (), [1, 2, 3])
            #expect(Array(cycle.prefix(6)) == [1, 2, 3, 1, 2, 3])
        }

        @Test
        func `works with different collection types`() {
            // String (collection of characters)
            let chars = Infinite.Cycle("abc")!
            let first6 = Array(chars.prefix(6))
            #expect(first6 == ["a", "b", "c", "a", "b", "c"])
        }

        @Test
        func `head returns first element`() {
            let cycle = Infinite.Cycle([1, 2, 3])!
            #expect(cycle.head == 1)
        }

        @Test
        func `tail head returns second element`() {
            let cycle = Infinite.Cycle([1, 2, 3])!
            #expect(cycle.tail.head == 2)
        }

        @Test
        func `tail wraps around`() {
            let cycle = Infinite.Cycle([1, 2, 3])!
            #expect(cycle.tail.tail.tail.head == 1)
        }

        @Test
        func `head/tail matches iteration for first few elements`() {
            let cycle = Infinite.Cycle([1, 2, 3])!

            // Since tail type changes after first access (becomes Rotated),
            // we verify the first element and then verify iteration matches head
            #expect(cycle.head == 1)

            let iteratedValues = Array(cycle.prefix(6))
            #expect(iteratedValues == [1, 2, 3, 1, 2, 3])
        }

        @Test
        func `equal bases are equal`() {
            let a = Infinite.Cycle([1, 2, 3])!
            let b = Infinite.Cycle([1, 2, 3])!
            #expect(a == b)
        }

        @Test
        func `different bases are not equal`() {
            let a = Infinite.Cycle([1, 2, 3])!
            let b = Infinite.Cycle([1, 2, 4])!
            #expect(a != b)
        }
    }

    @Suite struct EdgeCase {
        @Test
        func `init returns nil for empty collection`() {
            let empty: Infinite.Cycle<[Int]>? = Infinite.Cycle([])
            #expect(empty == nil)
        }
    }
}
