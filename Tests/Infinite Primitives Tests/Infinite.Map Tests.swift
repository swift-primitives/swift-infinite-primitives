// Infinite.Map Tests.swift

import Testing

@testable import Infinite_Primitives

// Note: Generic types cannot use #Tests directly.
// We use @Suite with nested structure to match the organizational pattern.

@Suite("Infinite.Map")
struct InfiniteMapTests {
    @Suite struct Unit {
        @Test
        func `maps naturals to squares`() {
            let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
            let squares = Infinite.Map(naturals) { $0 * $0 }
            let first10 = Array(squares.prefix(10))
            #expect(first10 == [0, 1, 4, 9, 16, 25, 36, 49, 64, 81])
        }

        @Test
        func `extension method works`() {
            let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
            let doubled = naturals.map { $0 * 2 }
            let first5 = Array(doubled.prefix(5))
            #expect(first5 == [0, 2, 4, 6, 8])
        }

        @Test
        func `chained maps`() {
            let naturals = Infinite.Iterate(initial: 1) { $0 + 1 }
            let result = naturals.map { $0 * 2 }.map { $0 + 1 }
            let first5 = Array(result.prefix(5))
            #expect(first5 == [3, 5, 7, 9, 11])
        }

        @Test
        func `type transformation`() {
            let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
            let strings = naturals.map { String($0) }
            let first5 = Array(strings.prefix(5))
            #expect(first5 == ["0", "1", "2", "3", "4"])
        }

        @Test
        func `head applies transform`() {
            let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
            let squares = Infinite.Map(naturals) { $0 * $0 }
            #expect(squares.head == 0)
        }

        @Test
        func `tail head applies transform to next`() {
            let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
            let squares = Infinite.Map(naturals) { $0 * $0 }
            #expect(squares.tail.head == 1)
            #expect(squares.tail.tail.head == 4)
        }

        @Test
        func `head/tail matches iteration`() {
            let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
            let squares = naturals.map { $0 * $0 }

            var current = squares
            var headValues: [Int] = []
            for _ in 0..<5 {
                headValues.append(current.head)
                current = current.tail
            }

            let iteratedValues = Array(squares.prefix(5))
            #expect(headValues == iteratedValues)
        }
    }
}
