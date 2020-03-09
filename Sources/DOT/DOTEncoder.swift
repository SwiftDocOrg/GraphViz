import GraphViz

/// Creates DOT language representations of GraphViz graphs.
public struct DOTEncoder {

    /// The number of spaces used for indentation; `2` by default.
    public var indentation: Int = 2

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

        do {
            let attributes = graph.attributes.dictionaryValue.compactMapValues { ($0 as? DOTRepresentable)?.representation(in: graph) }
            lines.append(contentsOf: attributes.map { "\($0.key)=\($0.value.escaped)" }.sorted().map { $0.indented(by: indentation) })
        }

        lines.append(contentsOf: graph.subgraphs.map { encode($0, in: graph).indented(by: indentation) })
        lines.append(contentsOf: graph.nodes.compactMap { encode($0, in: graph)?.indented(by: indentation) })
        lines.append(contentsOf: graph.edges.map { encode($0, in: graph).indented(by: indentation) })

        lines.append("}")

        let separator = lines.count > 2 ? "\n" : " "
        return lines.joined(separator: separator)
    }

    func encode(_ subgraph: Subgraph, in graph: Graph) -> String {
        var lines: [String] = []

        do {
            let attributes = subgraph.attributes.dictionaryValue.compactMapValues { ($0 as? DOTRepresentable)?.representation(in: graph) }
            lines.append(contentsOf: attributes.map { "\($0.key)=\($0.value.escaped)" }.sorted().map { $0.indented(by: indentation) })
        }

        lines.append(contentsOf: subgraph.nodes.compactMap { encode($0, in: graph)?.indented(by: indentation) })
        lines.append(contentsOf: subgraph.edges.map { encode($0, in: graph).indented(by: indentation) })

        do {
            if lines.count < 2 {
                return (
                    CollectionOfOne("{") +
                        lines.map { $0 + ";" } +
                        CollectionOfOne("}")
                    ).joined(separator: " ")
            } else {
                lines = lines.map { $0.indented(by: indentation) }

                var components: [String] = [
                    "subgraph"
                ]

                if let id = subgraph.id {
                    components.append(id)
                }

                components.append("{")

                lines.prepend(components.joined(separator: " "))
                lines.append("}")
            }
        }

        return lines.joined(separator: "\n")
    }

    func encode(_ node: Node, in graph: Graph) -> String? {
        var components: [String] = [
            node.id
        ]

        do {
            let attributes = node.attributes.dictionaryValue.compactMapValues { ($0 as? DOTRepresentable)?.representation(in: graph) }
            guard !attributes.isEmpty else { return nil } // TODO: configurable
            components.append("[\(attributes.map { "\($0.key)=\($0.value.escaped)" }.sorted().joined(separator: " "))]")
        }

        return components.joined(separator: " ")
    }

    func encode(_ edge: Edge, in graph: Graph) -> String {
        var components: [String] = [
            edge.from.escaped,
            (edge.direction ?? (graph.directed ? .forward : .none)).rawValue,
            edge.to.escaped
        ]

        do {
            let attributes = edge.attributes.dictionaryValue.compactMapValues { ($0 as? DOTRepresentable)?.representation(in: graph) }
            if !attributes.isEmpty {
                components.append("[\(attributes.map { "\($0.key)=\($0.value.escaped)" }.sorted().joined(separator: " "))]")
            }
        }

        return components.joined(separator: " ")
    }
}
