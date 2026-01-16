// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-infinite-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Infinite Primitives",
            targets: ["Infinite Primitives"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-test-primitives"),
        .package(path: "../../swift-foundations/swift-testing-extras"),
    ],
    targets: [
        .target(
            name: "Infinite Primitives",
            dependencies: []
        ),
        .testTarget(
            name: "Infinite Primitives Tests",
            dependencies: [
                "Infinite Primitives",
                .product(name: "Test Primitives", package: "swift-test-primitives"),
                .product(name: "Testing Extras", package: "swift-testing-extras"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .strictMemorySafety(),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
