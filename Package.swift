// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GraphViz",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "GraphViz",
            targets: ["GraphViz", "DOT"]),
        .library(
            name: "GraphVizBuilder",
            targets: ["GraphVizBuilder"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.7.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "GraphViz",
            dependencies: []),
        .target(
            name: "DOT",
            dependencies: ["GraphViz"]),
        .target(
            name: "GraphVizBuilder",
            dependencies: ["GraphViz"]),
        .testTarget(
            name: "GraphVizTests",
            dependencies: ["GraphViz", "DOT", "SnapshotTesting"]),
        .testTarget(
            name: "GraphVizBuilderTests",
            dependencies: ["GraphViz", "DOT", "GraphVizBuilder"])
    ]
)
