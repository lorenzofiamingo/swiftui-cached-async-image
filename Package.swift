// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "swiftui-cached-async-image",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "CachedAsyncImage",
            targets: ["CachedAsyncImage"])
    ],
    targets: [
        .target(name: "CachedAsyncImage")
    ]
)

#if swift(>=5.6)
// Add the documentation compiler plugin if possible
package.dependencies.append(
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
)
#endif
