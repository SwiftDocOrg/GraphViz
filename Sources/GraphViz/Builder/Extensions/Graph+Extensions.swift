extension Graph {
    typealias Fragment = GraphBuilder.Fragment

    public init(directed: Bool = false, strict: Bool = false, @GraphBuilder _ builder: () -> GraphMember) {
        self.init(directed: directed, strict: strict)
        append(typeErased: builder())
    }

    private mutating func append(_ fragment: Fragment) {
        for member in fragment.members {
            append(typeErased: member)
        }
    }

    private mutating func append(typeErased member: GraphMember) {
        switch member {
        case let fragment as Fragment:
            append(fragment)
        case let subgraph as Subgraph:
            append(subgraph)
        case let node as Node:
            append(node)
        case let edge as Edge:
            append(edge)
        default:
            assertionFailure("unexpected member: \(member)")
            return
        }
    }

    public subscript<T>(dynamicMember member: WritableKeyPath<Attributes, T>) -> (T) -> Self {
        get {
            var mutableSelf = self
            return { newValue in
                mutableSelf[dynamicMember: member] = newValue
                return mutableSelf
            }
        }
    }
}
