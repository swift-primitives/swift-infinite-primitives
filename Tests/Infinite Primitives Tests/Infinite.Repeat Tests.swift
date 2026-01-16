// Infinite.Repeat Tests.swift

import Testing
import Testing_Extras

@testable import Infinite_Primitives

// Note: Generic types cannot use #TestSuites directly.
// We use @Suite with nested structure to match the organizational pattern.

@Suite("Infinite.Repeat")
struct InfiniteRepeatTests {
    @Suite struct Unit {
        @Test("init stores value")
        func initStoresValue() {
            let repeat42 = Infinite.Repeat(42)
            #expect(repeat42.value == 42)
        }

        @Test("head returns stored value")
        func headReturnsStoredValue() {
            let repeat42 = Infinite.Repeat(42)
            #expect(repeat42.head == 42)
        }

        @Test("tail returns self")
        func tailReturnsSelf() {
            let repeat42 = Infinite.Repeat(42)
            #expect(repeat42.tail.value == 42)
            #expect(repeat42.tail.tail.value == 42)
        }

        @Test("iteration produces constant sequence")
        func iterationProducesConstantSequence() {
            let ones = Infinite.Repeat(1)
            let first10 = Array(ones.prefix(10))
            #expect(first10 == [1, 1, 1, 1, 1, 1, 1, 1, 1, 1])
        }

        @Test("works with different types")
        func worksWithDifferentTypes() {
            let strings = Infinite.Repeat("hello")
            #expect(Array(strings.prefix(3)) == ["hello", "hello", "hello"])

            let doubles = Infinite.Repeat(3.14)
            #expect(Array(doubles.prefix(2)) == [3.14, 3.14])
        }

        @Test("equal values are equal")
        func equalValuesAreEqual() {
            let a = Infinite.Repeat(42)
            let b = Infinite.Repeat(42)
            #expect(a == b)
        }

        @Test("different values are not equal")
        func differentValuesAreNotEqual() {
            let a = Infinite.Repeat(42)
            let b = Infinite.Repeat(43)
            #expect(a != b)
        }

        @Test("equal values have same hash")
        func equalValuesHaveSameHash() {
            let a = Infinite.Repeat(42)
            let b = Infinite.Repeat(42)
            #expect(a.hashValue == b.hashValue)
        }

        @Test("can be used in Set")
        func canBeUsedInSet() {
            let set: Set<Infinite.Repeat<Int>> = [
                Infinite.Repeat(1),
                Infinite.Repeat(2),
                Infinite.Repeat(1)
            ]
            #expect(set.count == 2)
        }
    }
}
