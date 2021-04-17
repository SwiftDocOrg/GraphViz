# GraphViz

![CI][ci badge]
[![Documentation][documentation badge]][documentation]

A Swift package for working with [GraphViz][graphviz].

## Requirements

- Swift 5.2+
- GraphViz

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

// Render image to SVG using dot layout algorithm
graph.render(using: .dot, to: .svg) { result in 
  guard .success(let data) = result,
        let svg = String(data: data, encoding: .utf8)
  else { return }

  print(svg)
}
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
> `render(using:to:)` and related methods require
> GraphViz to be installed on your system.

### Using Function Builders, Custom Operators, and Fluent Attribute Setters

```swift
import GraphViz

let graph = Graph(directed: true) {
    "a" --> "b"
    "a" --> "c"
    ("b" --> "c").constraint(false)
}
```

> **Note**:
> Swift 5.1 may require explicit typecast expressions in order to
> reconcile use of custom edge operators like `-->`.
> (`error: ambiguous reference to member '-->'`)

## Installation

### System Dependencies

You can install GraphViz on your system by running the following command:

```terminal
# macOS
$ brew install graphviz

# Linux (Ubuntu)
$ sudo apt-get install graphviz
```

### Swift Package Manager

Add the GraphViz package to your target dependencies in `Package.swift`:

```swift
import PackageDescription

let package = Package(
  name: "YourProject",
  dependencies: [
    .package(
        url: "https://github.com/SwiftDocOrg/GraphViz",
        from: "0.3.0"
    ),
  ]
)
```

Add `GraphViz` as a dependency to your target(s):

```swift
targets: [
.target(
    name: "YourTarget",
    dependencies: ["GraphViz"]),
```

## License

MIT

## Contact

Mattt ([@mattt](https://twitter.com/mattt))

[graphviz]: https://graphviz.org
[ci badge]: https://github.com/SwiftDocOrg/GraphViz/workflows/CI/badge.svg
[documentation badge]: https://github.com/SwiftDocOrg/GraphViz/workflows/Documentation/badge.svg
[documentation]: https://github.com/SwiftDocOrg/GraphViz/wiki
