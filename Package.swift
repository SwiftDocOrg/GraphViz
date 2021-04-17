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
            dependencies: ["Clibgraphviz"]),
        .testTarget(
            name: "GraphVizTests",
            dependencies: ["GraphViz"]),
    ]
)
