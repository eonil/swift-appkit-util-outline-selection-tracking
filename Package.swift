// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppKitUtilOutlineSelectionTracking",
    platforms: [
        .macOS(.v10_11),
    ],
    products: [
        .library(
            name: "AppKitUtilOutlineSelectionTracking",
            targets: ["AppKitUtilOutlineSelectionTracking"]),
    ],
    dependencies: [
        .package(url: "https://github.com/eonil/swift-tree-v2", .branch("master")),
    ],
    targets: [
        .target(
            name: "AppKitUtilOutlineSelectionTracking",
            dependencies: ["Tree2"]),
        .testTarget(
            name: "AppKitUtilOutlineSelectionTrackingTests",
            dependencies: ["AppKitUtilOutlineSelectionTracking","Tree2"]),
    ]
)
