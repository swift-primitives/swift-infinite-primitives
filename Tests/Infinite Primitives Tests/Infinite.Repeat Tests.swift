// Infinite.Repeat Tests.swift

import Testing

@testable import Infinite_Primitives

// Note: Generic types cannot use #Tests directly.
// We use @Suite with nested structure to match the organizational pattern.

@Suite("Infinite.Repeat")
struct InfiniteRepeatTests {
    @Suite struct Unit {
        @Test
        func `init stores value`() {
            let repeat42 = Infinite.Repeat(42)
            #expect(repeat42.value == 42)
        }

        @Test
        func `head returns stored value`() {
            let repeat42 = Infinite.Repeat(42)
            #expect(repeat42.head == 42)
        }

        @Test
        func `tail returns self`() {
            let repeat42 = Infinite.Repeat(42)
            #expect(repeat42.tail.value == 42)
            #expect(repeat42.tail.tail.value == 42)
        }

        @Test
        func `iteration produces constant sequence`() {
            let ones = Infinite.Repeat(1)
            let first10 = Array(ones.prefix(10))
            #expect(first10 == [1, 1, 1, 1, 1, 1, 1, 1, 1, 1])
        }

        @Test
        func `works with different types`() {
            let strings = Infinite.Repeat("hello")
            #expect(Array(strings.prefix(3)) == ["hello", "hello", "hello"])

            let doubles = Infinite.Repeat(3.14)
            #expect(Array(doubles.prefix(2)) == [3.14, 3.14])
        }

        @Test
        func `equal values are equal`() {
            let a = Infinite.Repeat(42)
            let b = Infinite.Repeat(42)
            #expect(a == b)
        }

        @Test
        func `different values are not equal`() {
            let a = Infinite.Repeat(42)
            let b = Infinite.Repeat(43)
            #expect(a != b)
        }

        @Test
        func `equal values have same hash`() {
            let a = Infinite.Repeat(42)
            let b = Infinite.Repeat(42)
            #expect(a.hashValue == b.hashValue)
        }

        @Test
        func `can be used in Set`() {
            let set: Set<Infinite.Repeat<Int>> = [
                Infinite.Repeat(1),
                Infinite.Repeat(2),
                Infinite.Repeat(1),
            ]
            #expect(set.count == 2)
        }
    }
}
