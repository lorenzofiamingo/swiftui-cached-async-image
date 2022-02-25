// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "swiftui-cached-async-image",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "CachedAsyncImage",
            targets: ["CachedAsyncImage"])v
    ],
    targets: [
        .target(
            name: "CachedAsyncImage")
    ]
)
