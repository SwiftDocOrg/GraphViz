// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GraphViz",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "GraphViz",
            targets: ["GraphViz"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .systemLibrary(name: "Clibgraphviz", pkgConfig: "libcgraph", providers: [
            .brew(["graphviz"]),
            .apt(["graphviz-dev"])
        ]),
        .target(
            name: "GraphViz",
            dependencies: ["GraphVizCore", "GraphVizDOT", "GraphVizBuilder", "GraphVizTools"]),
        .target(
            name: "GraphVizCore",
            dependencies: [],
            path: "Sources/Core"),
        .target(
            name: "GraphVizDOT",
            dependencies: ["GraphVizCore"],
            path: "Sources/DOT"),
        .target(
            name: "GraphVizBuilder",
            dependencies: ["GraphVizCore"],
            path: "Sources/Builder"),
        .target(
            name: "GraphVizTools",
            dependencies: ["GraphVizCore", "GraphVizDOT", "Clibgraphviz"],
            path: "Sources/Tools"),
        .testTarget(
            name: "GraphVizTests",
            dependencies: ["GraphVizCore", "GraphVizDOT", "GraphVizBuilder", "GraphVizTools"]),
    ]
)
