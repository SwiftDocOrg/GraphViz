# GraphViz

<!--
Pending Swift 5.2 support
![CI][ci badge]
[![Documentation][documentation badge]][documentation]
-->

A Swift package for working with [GraphViz][graphviz].

**This project is under active development and is not ready for production use.**

## Requirements

- Swift 5.2+ 👈❗️

## Usage

```swift
import GraphViz

var graph = Graph(directed: true)

let a = Node("a"), b = Node("b"), c = Node("c")

graph.append(Edge(from: a, to: b))
graph.append(Edge(from: a, to: c))

var b_c = Edge(from: b, to: c)
b_c.constraint = false
graph.append(b_c)

// Produce DOT language representation
let dot = DOTEncoder().encode(graph)

// Render image using dot layout algorithm
let data = try! graph.render(using: .dot, to: .svg)
let svg = String(data: data, encoding: .utf8)!
```

<img src="https://user-images.githubusercontent.com/7659/76256368-108d1600-620d-11ea-9263-d3ca3cc68d8d.png" alt="Example GraphViz Output" width="150" align="right">

```dot
digraph {
  a -> b
  a -> c
  b -> c [constraint=false]
}
```

> **Note**:
> The `render(using:to:)` method requires that
> the GraphViz binary corresponding to the specified layout algorithm
> is accessible from the current `$PATH`.

### Using Function Builders, Custom Operators, and Fluent Attribute Setters

To use the following interface,
add "GraphVizBuilder" to your package's dependencies
and replace `import GraphViz` with `import GraphVizBuilder` as needed.

```swift
import GraphVizBuilder

let graph = Graph(directed: true) {
    "a" --> "b"
    "a" --> "c"
    ("b" --> "c").constraint(false)
}
```

## Installation

### Swift Package Manager

Add the GraphViz package to your target dependencies in `Package.swift`:

```swift
import PackageDescription

let package = Package(
  name: "YourProject",
  dependencies: [
    .package(
        url: "https://github.com/SwiftDocOrg/GraphViz",
        from: "0.0.1"
    ),
  ]
)
```

Then run the `swift build` command to build your project.

## License

MIT

## Contact

Mattt ([@mattt](https://twitter.com/mattt))

[graphviz]: https://graphviz.org
[ci badge]: https://github.com/SwiftDocOrg/GraphViz/workflows/CI/badge.svg
[documentation badge]: https://github.com/SwiftDocOrg/GraphViz/workflows/Documentation/badge.svg
[documentation]: https://github.com/SwiftDocOrg/GraphViz/wiki
