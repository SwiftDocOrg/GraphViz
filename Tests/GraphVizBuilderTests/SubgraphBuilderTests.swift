import XCTest
import GraphViz
@testable import DOT
@testable import GraphVizBuilder

final class SubgraphBuilderTests: XCTestCase {
    let encoder = DOTEncoder()
    let graph = Graph(directed: true, strict: true)

    func testSubgraph() {
        let subgraph = Subgraph {
            "a" --> "b"
            "a" --> "c"
            "a" --> "d"
        }.rank(.same)

        let expected = """
        subgraph {
            rank=same
            a -> b
            a -> c
            a -> d
        }
        """

        XCTAssertEqual(encoder.encode(subgraph, in: graph), expected)
    }
}
