import GraphViz

/// Creates DOT language representations of GraphViz graphs.
///
/// For more information about the DOT language,
/// see <https://www.graphviz.org/doc/info/lang.html>.
public struct DOTEncoder {
    public enum Delimiter: String {
        case comma = ","
        case semicolon = ";"
    }

    /// The number of spaces used for indentation; `2` by default.
    public var indentation: Int = 2

    /// The delimiter used for statements.
    public var statementDelimiter: Delimiter?

    /// The delimiter used for attributes.
    public var attributeDelimiter: Delimiter?

    /// Whether to omit node statements that comprise only an ID.
    public var omitEmptyNodes: Bool = true

    public init() {}

    /// Encode the specified graph in DOT language.
    /// - Parameter graph: The graph to represent.
    /// - Returns: The DOT language representation.
    public func encode(_ graph: Graph) -> String {
        var lines: [String] = []

        do {
            var components: [String] = []
            if graph.strict {
                components.append("strict")
            }
            components.append(graph.directed ? "digraph" : "graph")

            if let id = graph.id {
                components.append(id)
            }

            components.append("{")

            lines.append(components.joined(separator: " "))
        }

        lines.append(contentsOf: encode(graph.attributes, in: graph).map{ $0.indented(by: indentation) })
        lines.append(contentsOf: graph.subgraphs.map { encode($0, in: graph).indented(by: indentation) })
        lines.append(contentsOf: graph.nodes.compactMap { encode($0, in: graph)?.indented(by: indentation) })
        lines.append(contentsOf: graph.edges.map { encode($0, in: graph).indented(by: indentation) })

        lines.append("}")

        let separator = lines.count > 2 ? "\n" : " "
        return lines.joined(separator: separator)
    }

    func encode(_ subgraph: Subgraph, in graph: Graph) -> String {
        var lines: [String] = []

        lines.append(contentsOf: encode(subgraph.attributes, in: graph).map{ $0.indented(by: indentation) })
        lines.append(contentsOf: subgraph.nodes.compactMap { encode($0, in: graph)?.indented(by: indentation) })
        lines.append(contentsOf: subgraph.edges.map { encode($0, in: graph).indented(by: indentation) })

        do {
            if lines.count < 2 {
                return ["{", lines.first, "}"].compactMap{ $0 }.joined(separator: " ")
            } else {
                lines = lines.map { $0.indented(by: indentation) }

                let start = [
                    "subgraph",
                    subgraph.id,
                    "{"
                ].compactMap { $0 }.joined(separator: " ")
                let end = "}"

                lines.prepend(start)
                lines.append(end)
            }
        }

        return lines.joined(separator: "\n")
    }

    func encode(_ node: Node, in graph: Graph) -> String? {
        let components: [String] = [
            node.id,
            encode(node.attributes, in: graph)
        ].compactMap{ $0 }

        if components.count == 1, omitEmptyNodes {
            return nil
        }

        var statement = components.joined(separator: " ")
        if let delimiter = statementDelimiter {
            statement += delimiter.rawValue
        }

        return statement
    }

    func encode(_ edge: Edge, in graph: Graph) -> String {
        let components: [String] = [
            edge.from.escaped,
            (edge.direction ?? (graph.directed ? .forward : .none)).rawValue,
            edge.to.escaped,
            encode(edge.attributes, in: graph)
        ].compactMap{ $0 }

        var statement = components.joined(separator: " ")
        if let delimiter = statementDelimiter {
            statement += delimiter.rawValue
        }

        return statement
    }

    func encode(_ attributes: Graph.Attributes, in graph: Graph) -> [String] {
        guard let encoded = encode(attributes.dictionaryValue, in: graph) else { return [] }
        return encoded.map { $0 + (statementDelimiter?.rawValue ?? "") }
    }

    func encode(_ attributes: Subgraph.Attributes, in graph: Graph) -> [String] {
        guard let encoded = encode(attributes.dictionaryValue, in: graph) else { return [] }
        return encoded.map { $0 + (statementDelimiter?.rawValue ?? "") }
    }

    func encode(_ attributes: Node.Attributes, in graph: Graph) -> String? {
        guard let encoded = encode(attributes.dictionaryValue, in: graph) else { return nil }
        return "[\(encoded.joined(separator: attributeDelimiter?.rawValue ?? " "))]"
    }

    func encode(_ attributes: Edge.Attributes, in graph: Graph) -> String? {
        guard let encoded = encode(attributes.dictionaryValue, in: graph) else { return nil }
        return "[\(encoded.joined(separator: attributeDelimiter?.rawValue ?? " "))]"
    }

    private func encode(_ attributes: [String: Any], in graph: Graph) -> [String]? {
        let attributes = attributes.compactMapValues { ($0 as? DOTRepresentable)?.representation(in: graph) }
        guard !attributes.isEmpty else { return nil }
        return attributes.map { "\($0.key)=\($0.value.escaped)" }.sorted()
    }
}
