// Enumerable Tests.swift

import Testing
@testable import Infinite_Primitives

@Suite("Infinite.Enumerable")
struct EnumerableTests {

    struct Naturals: Infinite.Enumerable {
        func makeIterator() -> Iterator { Iterator() }

        struct Iterator: IteratorProtocol, Sendable {
            var current = 0
            mutating func next() -> Int? {
                defer { current += 1 }
                return current
            }
        }
    }

    @Test("Infinite sequence can be prefixed")
    func prefixWorks() {
        let first10 = Array(Naturals().prefix(10))
        #expect(first10 == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    }

    @Test("Infinite sequence can be dropped and prefixed")
    func dropPrefixWorks() {
        let middle5 = Array(Naturals().dropFirst(5).prefix(5))
        #expect(middle5 == [5, 6, 7, 8, 9])
    }

    struct Fibonacci: Infinite.Enumerable {
        func makeIterator() -> Iterator { Iterator() }

        struct Iterator: IteratorProtocol, Sendable {
            var a = 0, b = 1
            mutating func next() -> Int? {
                let result = a
                (a, b) = (b, a + b)
                return result
            }
        }
    }

    @Test("Fibonacci sequence")
    func fibonacciWorks() {
        let first10 = Array(Fibonacci().prefix(10))
        #expect(first10 == [0, 1, 1, 2, 3, 5, 8, 13, 21, 34])
    }
}
