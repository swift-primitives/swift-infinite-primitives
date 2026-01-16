// Unfold Tests.swift

import Testing
@testable import Infinite_Primitives

@Suite("Infinite.Unfold")
struct UnfoldTests {

    @Test("natural numbers via unfold")
    func naturalNumbersViaUnfold() {
        let naturals = Infinite.Unfold(seed: 0) { n in (n, n + 1) }
        let first10 = Array(naturals.prefix(10))
        #expect(first10 == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    }

    @Test("Fibonacci sequence")
    func fibonacciSequence() {
        let fib = Infinite.Unfold(seed: (0, 1)) { (a, b) in
            (a, (b, a + b))
        }
        let first10 = Array(fib.prefix(10))
        #expect(first10 == [0, 1, 1, 2, 3, 5, 8, 13, 21, 34])
    }

    @Test("head returns first emitted value")
    func headReturnsFirstEmittedValue() {
        let naturals = Infinite.Unfold(seed: 0) { n in (n, n + 1) }
        #expect(naturals.head == 0)
    }

    @Test("tail advances state")
    func tailAdvancesState() {
        let naturals = Infinite.Unfold(seed: 0) { n in (n, n + 1) }
        #expect(naturals.tail.head == 1)
        #expect(naturals.tail.tail.head == 2)
    }

    @Test("separate state and element types")
    func separateStateAndElementTypes() {
        // State is (counter, multiplier), element is just the product
        let products = Infinite.Unfold(seed: (1, 2)) { (count, mult) in
            (count * mult, (count + 1, mult))
        }
        let first5 = Array(products.prefix(5))
        #expect(first5 == [2, 4, 6, 8, 10])
    }

    @Test("alternating sequence via tuple state")
    func alternatingSequenceViaTupleState() {
        // Demonstrate unfold with tuple state: alternating between two values
        let seq = Infinite.Unfold(seed: (true, 1, 2)) { (toggle, a, b) in
            if toggle {
                return (a, (false, a, b))
            } else {
                return (b, (true, a, b))
            }
        }
        let first6 = Array(seq.prefix(6))
        #expect(first6 == [1, 2, 1, 2, 1, 2])
    }
}
