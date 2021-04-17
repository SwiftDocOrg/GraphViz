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

    private static let shared = DOTEncoder()

    /// Creates a new DOT encoder.
    public init() {}

    /// Encode the specified graph in DOT language.
    /// - Parameter graph: The graph to represent.
    /// - Returns: The DOT language representation.
    public static func encode(_ graph: Graph) -> String {
        return shared.encode(graph)
    }

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
                components.append(escape(id))
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

                var components = ["subgraph"]
                if let id = subgraph.id {
                    components.append(escape(id))
                }
                components.append("{")

                lines.prepend(components.joined(separator: " "))
                lines.append("}")
            }
        }

        return lines.joined(separator: "\n")
    }

    func encode(_ node: Node, in graph: Graph) -> String? {
        let components: [String] = [
            escape(node.id),
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
            escape(edge.from),
            (edge.direction ?? (graph.directed ? .forward : .none)).rawValue,
            escape(edge.to),
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
        return attributes.map { "\(escape($0.key))=\(escape($0.value))" }.sorted()
    }

    private func escape(_ string: String) -> String {
        var escapedString = string.replacingOccurrences(of: "\"", with: #"\""#)
        if string.contains(where: { !$0.isLetter && !$0.isNumber && $0 != "_" }) ||
            DOT.keywords.contains(where: { escapedString.caseInsensitiveCompare($0) == .orderedSame })
        {
            escapedString = #""\#(escapedString)""#
        }

        return escapedString
    }
}

// MARK: -

fileprivate extension Array {
    mutating func prepend(_ newElement: Element) {
        self.insert(newElement, at: startIndex)
    }
}

fileprivate extension String {
    func indented(by spaces: Int = 2) -> String {
        return split(separator: "\n", omittingEmptySubsequences: false)
                .map { String(repeating: " ", count: spaces) + $0 }
                .joined(separator: "\n")
    }
}

