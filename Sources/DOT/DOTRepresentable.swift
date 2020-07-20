import GraphViz
import Foundation

protocol DOTRepresentable {
    func representation(in graph: Graph) -> String?
}

extension Attribute: DOTRepresentable where Value: DOTRepresentable {
    func representation(in graph: Graph) -> String? {
        wrappedValue?.representation(in: graph)
    }
}

// MARK: -

extension CustomStringConvertible {
    func representation(in graph: Graph) -> String? {
        return description
    }
}

extension RawRepresentable where RawValue: DOTRepresentable {
    func representation(in graph: Graph) -> String? {
        return rawValue.representation(in: graph)
    }
}

// MARK: -

// MARK: - Swift Standard Library Types

extension Bool: DOTRepresentable {}
extension Double: DOTRepresentable {}
extension Int: DOTRepresentable {}
extension String: DOTRepresentable {}

// MARK: - Foundation Types

extension URL: DOTRepresentable {
    public func representation(in graph: Graph) -> String? {
        return absoluteString
    }
}

// MARK: - GraphViz Types

extension AspectRatio: DOTRepresentable {
    func representation(in graph: Graph) -> String? {
        switch self {
        case .numeric(let number):
            return number.representation(in: graph)
        case .fill:
            return "fill"
        case .compress:
            return "compress"
        case .expand:
            return "expand"
        case .auto:
            return "auto"
        }
    }
}

extension Color: DOTRepresentable {
    func representation(in graph: Graph) -> String? {
        switch self {
        case .transparent:
            return "transparent"
        case let .named(name):
            return name.rawValue
        case let .rgb(red, green, blue):
            return String(format: "#%02x%02x%02x", red, green, blue)
        case let .rgba(red, green, blue, alpha):
            return String(format: "#%02x%02x%02x%02x", red, green, blue, alpha)
        case let .hsv(hue, saturation, value):
            return String(format: "%1.3f %1.3 %1.3", hue, saturation, value)
            //        case .gradient(style: let style, angle: let angle, colors: let colors):
            //            fatalError() // TODO
        case let .custom(string):
            return string
        }
    }
}

extension Location: DOTRepresentable {}

extension Ordering: DOTRepresentable {}

extension Point: DOTRepresentable {
    func representation(in graph: Graph) -> String? {
        if let z = z {
            return String(format: "%g,%g,%g", x, y, z) + (fixed ? "!" : "")
        } else {
            return String(format: "%g,%g", x, y) + (fixed ? "!" : "")
        }
    }
}

extension Position: DOTRepresentable {
    func representation(in graph: Graph) -> String? {
        switch self {
        case .point(point: let point):
            return point.representation(in: graph)
        case .spline:
            fatalError("unimplemented") // FIXME
        }
    }
}

extension Rectangle: DOTRepresentable {
    func representation(in graph: Graph) -> String? {
        return String(format: "%g,%g,%g,%g", origin.x, origin.y, origin.x + size.width, origin.y + size.height)
    }
}

extension Size: DOTRepresentable {
    func representation(in graph: Graph) -> String? {
        return String(format: "%g,%g", width, height)
    }
}

// MARK: Graph Subtypes

extension Graph.RankDirection: DOTRepresentable {}

extension Graph.PageDirection: DOTRepresentable {}

extension Graph.Orientation: DOTRepresentable {}

extension Graph.ClusterMode: DOTRepresentable {}

extension Graph.PackingMode: DOTRepresentable {}

extension Graph.Spline: DOTRepresentable {}

extension Graph.Mode: DOTRepresentable {}

extension Graph.QuadtreeScheme: DOTRepresentable {}

extension Graph.Smoothing: DOTRepresentable {}

extension Graph.InitialNodeLayoutStrategy: DOTRepresentable {
    func representation(in graph: Graph) -> String? {
        switch self {
        case .regular:
            return "regular"
        case .`self`:
            return "self"
        case .random(seed: let seed?):
            return "random\(seed)"
        case .random(_):
            return "random"
        }
    }
}

extension Graph.LabelScheme: DOTRepresentable {}

extension Graph.OutputOrder: DOTRepresentable {}

extension Graph.FontNamingConvention: DOTRepresentable {}

// MARK: Subgraph Subtypes

extension Subgraph.Rank: DOTRepresentable {}

extension Subgraph.Style: DOTRepresentable {
    func representation(in graph: Graph) -> String? {
        switch self {
        case .solid:
            return "solid"
        case .dashed:
            return "dashed"
        case .dotted:
            return "dotted"
        case .bold:
            return "bold"
        case .rounded:
            return "rounded"
        case .filled:
            return "filled"
        case .striped:
            return "striped"
        case .compound(let styles):
            return styles.compactMap { $0.representation(in: graph) }.joined(separator: ",")
        }
    }
}

// MARK: Node Subtypes

extension Node.Shape: DOTRepresentable {}

extension Node.ImagePosition: DOTRepresentable {}

extension Node.Style: DOTRepresentable {
    func representation(in graph: Graph) -> String? {
        switch self {
        case .solid:
            return "solid"
        case .dashed:
            return "dashed"
        case .dotted:
            return "dotted"
        case .bold:
            return "bold"
        case .rounded:
            return "rounded"
        case .diagonals:
            return "diagonals"
        case .filled:
            return "filled"
        case .striped:
            return "striped"
        case .wedged:
            return "wedged"
        case .compound(let styles):
            return styles.compactMap { $0.representation(in: graph) }.joined(separator: ",")
        }
    }
}

// MARK: Edge Subtypes

extension Edge.Arrow: DOTRepresentable {
    func representation(in graph: Graph) -> String? {
        fatalError("unimplemented") // FIXME
    }
}

extension Edge.Port: DOTRepresentable {}

extension Edge.Style: DOTRepresentable {}

