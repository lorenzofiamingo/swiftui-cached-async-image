// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CachedAsyncImage",
    products: [
        .library(
            name: "CachedAsyncImage",
            targets: ["CachedAsyncImage"]),
    ],
    targets: [
        .target(
            name: "CachedAsyncImage")
    ]
)
