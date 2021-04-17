public protocol SubgraphMember {}

extension Node: SubgraphMember {}
extension Edge: SubgraphMember {}

// MARK: -

@_functionBuilder
public struct SubgraphBuilder {
    struct Fragment: SubgraphMember {
        var members: [SubgraphMember]

        init(_ members: [SubgraphMember] = []) {
            self.members = members.flatMap { member in
                (member as? Fragment)?.members ?? [member]
            }
        }
    }

    // MARK: -

    // MARK: buildBlock

    public static func buildBlock(_ members: SubgraphMember...) -> SubgraphMember {
        return Fragment(members)
    }

    // MARK: buildIf

    public static func buildIf(_ member: SubgraphMember?) -> SubgraphMember {
        return member ?? Fragment()
    }

    // MARK: buildEither

    public static func buildEither(first: SubgraphMember) -> SubgraphMember {
        return first
    }

    public static func buildEither(second: SubgraphMember) -> SubgraphMember {
        return second
    }
}
