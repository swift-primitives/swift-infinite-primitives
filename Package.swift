// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-infinite-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Infinite Primitives",
            targets: ["Infinite Primitives"]
        ),
        .library(
            name: "Infinite Primitives Test Support",
            targets: ["Infinite Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-collection-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-input-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-iterator-primitives.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Infinite Primitives",
            dependencies: [
                .product(name: "Collection Primitives", package: "swift-collection-primitives"),
                .product(name: "Input Primitives", package: "swift-input-primitives"),
                .product(name: "Iterator Protocol", package: "swift-iterator-primitives"),
            ]
        ),
        .target(
            name: "Infinite Primitives Test Support",
            dependencies: [
                "Infinite Primitives",
                .product(name: "Collection Primitives Test Support", package: "swift-collection-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Infinite Primitives Tests",
            dependencies: [
                "Infinite Primitives",
                "Infinite Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
