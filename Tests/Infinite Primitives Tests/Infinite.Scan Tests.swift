// Infinite.Scan Tests.swift

import Testing
import Testing_Extras

@testable import Infinite_Primitives

// Note: Generic types cannot use #TestSuites directly.
// We use @Suite with nested structure to match the organizational pattern.

@Suite("Infinite.Scan")
struct InfiniteScanTests {
    @Suite struct Unit {
        @Test("running sum")
        func runningSum() {
            let naturals = Infinite.Iterate(initial: 1) { $0 + 1 }
            let runningSums = Infinite.Scan(initial: 0, source: naturals) { acc, n in acc + n }
            let first6 = Array(runningSums.prefix(6))
            // 0, 0+1=1, 1+2=3, 3+3=6, 6+4=10, 10+5=15
            #expect(first6 == [0, 1, 3, 6, 10, 15])
        }

        @Test("running product (factorials)")
        func runningProduct() {
            let naturals = Infinite.Iterate(initial: 1) { $0 + 1 }
            let factorials = Infinite.Scan(initial: 1, source: naturals) { acc, n in acc * n }
            let first6 = Array(factorials.prefix(6))
            // 1, 1*1=1, 1*2=2, 2*3=6, 6*4=24, 24*5=120
            #expect(first6 == [1, 1, 2, 6, 24, 120])
        }

        @Test("extension method")
        func extensionMethod() {
            let ones = Infinite.Repeat(1)
            let runningSums = ones.scan(initial: 0) { acc, _ in acc + 1 }
            let first5 = Array(runningSums.prefix(5))
            #expect(first5 == [0, 1, 2, 3, 4])
        }

        @Test("starts with initial value")
        func startsWithInitialValue() {
            let naturals = Infinite.Iterate(initial: 100) { $0 + 1 }
            let scanned = Infinite.Scan(initial: 42, source: naturals) { acc, _ in acc }
            let first1 = Array(scanned.prefix(1))
            #expect(first1 == [42])
        }

        @Test("type transformation in scan")
        func typeTransformationInScan() {
            let naturals = Infinite.Iterate(initial: 1) { $0 + 1 }
            let strings = Infinite.Scan(initial: "", source: naturals) { acc, n in
                acc.isEmpty ? String(n) : acc + "," + String(n)
            }
            let first4 = Array(strings.prefix(4))
            #expect(first4 == ["", "1", "1,2", "1,2,3"])
        }

        @Test("scan with complex accumulator")
        func scanWithComplexAccumulator() {
            struct Stats: Equatable, Sendable {
                var sum: Int
                var count: Int
            }

            let naturals = Infinite.Iterate(initial: 1) { $0 + 1 }
            let stats = Infinite.Scan(initial: Stats(sum: 0, count: 0), source: naturals) { acc, n in
                Stats(sum: acc.sum + n, count: acc.count + 1)
            }

            let first4 = Array(stats.prefix(4))
            #expect(first4[0] == Stats(sum: 0, count: 0))
            #expect(first4[1] == Stats(sum: 1, count: 1))
            #expect(first4[2] == Stats(sum: 3, count: 2))
            #expect(first4[3] == Stats(sum: 6, count: 3))
        }
    }
}
