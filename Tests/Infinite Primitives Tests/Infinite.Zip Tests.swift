// Infinite.Zip Tests.swift

import Testing

@testable import Infinite_Primitives

// Note: Generic types cannot use #Tests directly.
// We use @Suite with nested structure to match the organizational pattern.

@Suite("Infinite.Zip")
struct InfiniteZipTests {
    @Suite struct Unit {
        @Test
        func `zips naturals with squares`() {
            let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
            let squares = naturals.map { $0 * $0 }
            let zipped = Infinite.Zip(naturals, squares)

            let first5 = Array(zipped.prefix(5))
            #expect(first5.count == 5)
            #expect(first5[0].0 == 0 && first5[0].1 == 0)
            #expect(first5[1].0 == 1 && first5[1].1 == 1)
            #expect(first5[2].0 == 2 && first5[2].1 == 4)
            #expect(first5[3].0 == 3 && first5[3].1 == 9)
            #expect(first5[4].0 == 4 && first5[4].1 == 16)
        }

        @Test
        func `static convenience method`() {
            let ones = Infinite.Repeat(1)
            let twos = Infinite.Repeat(2)
            let zipped = Infinite.zip(ones, twos)

            let first3 = Array(zipped.prefix(3))
            #expect(first3.count == 3)
            #expect(first3[0].0 == 1 && first3[0].1 == 2)
            #expect(first3[1].0 == 1 && first3[1].1 == 2)
            #expect(first3[2].0 == 1 && first3[2].1 == 2)
        }

        @Test
        func `zips different types`() {
            let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
            let letters = Infinite.Cycle("abc")!
            let zipped = Infinite.Zip(naturals, letters)

            let first6 = Array(zipped.prefix(6))
            #expect(first6.count == 6)
            #expect(first6[0].0 == 0 && first6[0].1 == "a")
            #expect(first6[1].0 == 1 && first6[1].1 == "b")
            #expect(first6[2].0 == 2 && first6[2].1 == "c")
            #expect(first6[3].0 == 3 && first6[3].1 == "a")
        }

        @Test
        func `head returns paired heads`() {
            let ones = Infinite.Repeat(1)
            let twos = Infinite.Repeat(2)
            let zipped = Infinite.Zip(ones, twos)

            let head = zipped.head
            #expect(head.0 == 1)
            #expect(head.1 == 2)
        }

        @Test
        func `tail returns zipped tails`() {
            let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
            let squares = naturals.map { $0 * $0 }
            let zipped = Infinite.Zip(naturals, squares)

            let tailHead = zipped.tail.head
            #expect(tailHead.0 == 1)
            #expect(tailHead.1 == 1)

            let tailTailHead = zipped.tail.tail.head
            #expect(tailTailHead.0 == 2)
            #expect(tailTailHead.1 == 4)
        }

        @Test
        func `head/tail matches iteration`() {
            let naturals = Infinite.Iterate(initial: 0) { $0 + 1 }
            let squares = naturals.map { $0 * $0 }
            let zipped = Infinite.Zip(naturals, squares)

            var current = zipped
            var headValues: [(Int, Int)] = []
            for _ in 0..<5 {
                headValues.append(current.head)
                current = current.tail
            }

            let iteratedValues = Array(zipped.prefix(5))
            #expect(headValues.count == iteratedValues.count)
            for i in 0..<5 {
                #expect(headValues[i].0 == iteratedValues[i].0)
                #expect(headValues[i].1 == iteratedValues[i].1)
            }
        }
    }
}
