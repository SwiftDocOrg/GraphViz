infix operator <-- : AdditionPrecedence

extension Node {
    public static func <-- (lhs: Node, rhs: Node) -> Edge {
        return Edge(from: lhs, to: rhs, direction: .backward)
    }
}

extension Edge {
    public static func <-- (lhs: Edge, rhs: Node) -> [Edge] {
        [lhs, Edge(from: lhs.to, to: rhs.id, direction: .backward)]
    }
}
