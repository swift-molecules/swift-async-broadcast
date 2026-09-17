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
        .library(name: "Async Broadcast", targets: ["Async Broadcast"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-async.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-buffer.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-buffer-linear.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-buffer-ring.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-column.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-deque.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-dictionary.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-dictionary-ordered.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-hash-table.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-index.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-memory.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-memory-allocation.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-queue.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-storage-memory.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Async Broadcast",
            dependencies: [
                .product(name: "Async Mutex", package: "swift-async"),
                .product(name: "Async Primitive", package: "swift-async"),
                .product(name: "Async Publication", package: "swift-async"),
                .product(name: "Buffer", package: "swift-buffer"),
                .product(name: "Buffer Linear Primitive", package: "swift-buffer-linear"),
                .product(name: "Buffer Ring Primitive", package: "swift-buffer-ring"),
                .product(name: "Column", package: "swift-column"),
                .product(name: "Deque", package: "swift-deque"),
                .product(name: "Dictionary", package: "swift-dictionary"),
                .product(name: "Dictionary Ordered", package: "swift-dictionary-ordered"),
                .product(name: "Hash Indexed Primitive", package: "swift-hash-table"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Memory Allocator", package: "swift-memory-allocation"),
                .product(name: "Queue", package: "swift-queue"),
                .product(name: "Storage Memory", package: "swift-storage-memory"),
            ],
            path: "Sources/Async Broadcast"
        ),
        .testTarget(
            name: "Async Broadcast Tests",
            dependencies: [
                .product(name: "Async", package: "swift-async"),
                .target(name: "Async Broadcast"),
            ],
            path: "Tests/Async Broadcast Tests"
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
