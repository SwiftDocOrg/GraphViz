import XCTest
@testable import GraphViz

final class SubgraphTests: XCTestCase {
    let encoder = DOTEncoder()
    let graph = Graph(directed: true, strict: true)

    func testEmptySubgraphWithoutAttributes() {
        let subgraph = Subgraph()
        XCTAssertTrue(subgraph.isEmpty)

        let expected = "{ }"
        XCTAssertEqual(encoder.encode(subgraph, in: graph), expected)
    }

    func testSubgraphWithStyle() {
        var subgraph = Subgraph()

        do {
            subgraph.style = .striped([.named(.pink), .named(.white), .named(.chocolate)])

            let expected = #"""
            subgraph {
                fillcolor="pink,white,chocolate"
                style=striped
            }
            """#
            XCTAssertEqual(encoder.encode(subgraph, in: graph), expected)
        }

        do {
            subgraph.fillColor = .named(.red)

            let expected = #"""
            subgraph {
                fillcolor=red
                style=filled
            }
            """#
            XCTAssertEqual(encoder.encode(subgraph, in: graph), expected)
        }

        do {
            subgraph.fillColor = nil

            let expected = "{ }"
            XCTAssertEqual(encoder.encode(subgraph, in: graph), expected)
        }
    }
}
