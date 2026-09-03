// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-async-broadcast",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Async Broadcast",
            targets: ["Async Broadcast"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-molecules/swift-async", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-buffer", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-buffer-linear", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-buffer-ring", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-column", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-deque", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-dictionary", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-dictionary-ordered", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-hash", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-hash-table", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-index", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-memory-allocation", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-memory-heap", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-queue", branch: "main"),
    ],
    targets: [
        .target(
            name: "Async Broadcast",
            dependencies: [
                .product(name: "Async", package: "swift-async"),
                .product(name: "Buffer", package: "swift-buffer"),
                .product(name: "Buffer Linear", package: "swift-buffer-linear"),
                .product(name: "Buffer Ring", package: "swift-buffer-ring"),
                .product(name: "Column", package: "swift-column"),
                .product(name: "Deque", package: "swift-deque"),
                .product(name: "Dictionary", package: "swift-dictionary"),
                .product(name: "Dictionary Ordered", package: "swift-dictionary-ordered"),
                .product(name: "Hash", package: "swift-hash"),
                .product(name: "Hash Indexed", package: "swift-hash-table"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Memory Allocator", package: "swift-memory-allocation"),
                .product(name: "Memory Heap", package: "swift-memory-heap"),
                .product(name: "Queue", package: "swift-queue"),
            ]
        ),
        .testTarget(
            name: "Async Broadcast Tests",
            dependencies: [
                "Async Broadcast",
                .product(name: "Async", package: "swift-async"),
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
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = [
        .enableExperimentalFeature("RawLayout")
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
