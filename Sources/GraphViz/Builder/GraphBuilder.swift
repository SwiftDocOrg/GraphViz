public protocol GraphMember {}

extension Subgraph: GraphMember {}
extension Node: GraphMember {}
extension Edge: GraphMember {}

// MARK: -

@_functionBuilder
public struct GraphBuilder {
    struct Fragment: GraphMember {
        var members: [GraphMember]

        init(_ members: [GraphMember] = []) {
            self.members = members.flatMap { member in
                (member as? Fragment)?.members ?? [member]
            }
        }
    }

    // MARK: -

    // MARK: buildBlock

    public static func buildBlock(_ members: GraphMember...) -> GraphMember {
        return Fragment(members)
    }

    // MARK: buildIf

    public static func buildIf(_ member: GraphMember?) -> GraphMember {
        return member ?? Fragment()
    }

    // MARK: buildEither

    public static func buildEither(first: GraphMember) -> GraphMember {
        return first
    }

    public static func buildEither(second: GraphMember) -> GraphMember {
        return second
    }
}
