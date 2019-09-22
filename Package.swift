// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppKitUtilOutlineSelectionTracking",
    platforms: [
        .macOS(.v10_12),
    ],
    products: [
        .library(
            name: "AppKitUtilOutlineSelectionTracking",
            targets: ["AppKitUtilOutlineSelectionTracking"]),
        .executable(
            name: "AppKitUtilOutlineSelectionTrackingFuzz",
            targets: ["AppKitUtilOutlineSelectionTrackingFuzz"]),
        .executable(
            name: "AppKitUtilOutlineSelectionTrackingFuzz2",
            targets: ["AppKitUtilOutlineSelectionTrackingFuzz2"]),
    ],
    dependencies: [
        .package(url: "https://github.com/eonil/swift-tree-v2", .branch("master")),
        .package(url: "https://github.com/eonil/swift-test-util", .branch("master")),
    ],
    targets: [
        .target(
            name: "AppKitUtilOutlineSelectionTracking",
            dependencies: ["Tree2"]),
        .target(
            name: "AppKitUtilOutlineSelectionTrackingTestUtil",
            dependencies: [
                "Tree2",
                "TestUtil"]),
        .target(
            name: "AppKitUtilOutlineSelectionTrackingFuzz",
            dependencies: [
                "AppKitUtilOutlineSelectionTracking",
                "AppKitUtilOutlineSelectionTrackingTestUtil",
                "Tree2",
                "TestUtil"]),
        .target(
            name: "AppKitUtilOutlineSelectionTrackingFuzz2",
            dependencies: [
                "AppKitUtilOutlineSelectionTracking",
                "AppKitUtilOutlineSelectionTrackingTestUtil",
                "Tree2",
                "TestUtil"]),
        .testTarget(
            name: "AppKitUtilOutlineSelectionTrackingTests",
            dependencies: [
                "AppKitUtilOutlineSelectionTracking",
                "AppKitUtilOutlineSelectionTrackingTestUtil",
                "Tree2"]),
    ]
)
