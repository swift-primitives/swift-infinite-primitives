// Observable Tests.swift

import Testing
@testable import Infinite_Primitives

@Suite("Infinite.Observable")
struct ObservableTests {

    // Use Repeat as the simplest Observable to test the protocol
    @Test("head returns current element")
    func headReturnsCurrentElement() {
        let ones = Infinite.Repeat(42)
        #expect(ones.head == 42)
    }

    @Test("tail returns same sequence for Repeat")
    func tailReturnsSameSequence() {
        let ones = Infinite.Repeat(42)
        #expect(ones.tail.head == 42)
        #expect(ones.tail.tail.head == 42)
    }

    @Test("head/tail decomposition matches iteration")
    func decompositionMatchesIteration() {
        let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }

        // Manual head/tail traversal
        var current = naturals
        var headValues: [Int] = []
        for _ in 0..<5 {
            headValues.append(current.head)
            current = current.tail
        }

        // Iterator traversal
        let iteratedValues = Array(naturals.prefix(5))

        #expect(headValues == iteratedValues)
    }

    @Test("Observable types are Sendable")
    func observableIsSendable() {
        let repeat1 = Infinite.Repeat(1)
        let iterate = Infinite.Iterate(initial: 0) { $0 + 1 }
        let unfold = Infinite.Unfold(seed: 0) { ($0, $0 + 1) }

        // Verify Sendable by using in concurrent context
        Task {
            _ = repeat1.head
            _ = iterate.head
            _ = unfold.head
        }
    }
}
