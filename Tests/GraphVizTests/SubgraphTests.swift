import XCTest
import GraphViz
@testable import DOT

final class SubgraphTests: XCTestCase {
    let encoder = DOTEncoder()
    let graph = Graph(directed: true, strict: true)

    func testEmptySubgraphWithoutAttributes() {
        let subgraph = Subgraph()

        let expected = "{ }"

        XCTAssertEqual(encoder.encode(subgraph, in: graph), expected)
    }
}
