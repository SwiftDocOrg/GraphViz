infix operator --> : AdditionPrecedence

extension Node {
    public static func --> (lhs: Node, rhs: Node) -> Edge {
        return Edge(from: lhs, to: rhs, direction: .forward)
    }
}

extension Node {
    public static func --> (lhs: Node, rhs: [Node]) -> Subgraph {
        var subgraph = Subgraph()
        
        subgraph.append(lhs)
        
        for node in rhs {
            subgraph.append(Edge(from: lhs, to: node, direction: .forward))
        }
        
        return subgraph
    }
}

extension Edge {
    public static func --> (lhs: Edge, rhs: Node) -> [Edge] {
        [lhs, Edge(from: lhs.to, to: rhs.id, direction: .forward)]
    }
}
