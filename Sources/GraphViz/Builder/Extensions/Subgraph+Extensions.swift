extension Subgraph {
    typealias Fragment = SubgraphBuilder.Fragment

    public init(id: String? = nil, @SubgraphBuilder _ builder: () -> SubgraphMember) {
        self.init(id: id)
        append(typeErased: builder())
    }

    private mutating func append(_ fragment: Fragment) {
        for member in fragment.members {
            append(typeErased: member)
        }
    }

    private mutating func append(typeErased member: SubgraphMember) {
        switch member {
        case let fragment as Fragment:
            append(fragment)
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

public func Cluster(@SubgraphBuilder _ builder: () -> SubgraphMember) -> Subgraph {
    return Subgraph(id: "cluster", builder)
}
