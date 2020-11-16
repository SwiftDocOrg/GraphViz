import XCTest
import GraphViz
@testable import DOT

final class NodeTests: XCTestCase {
    let encoder = DOTEncoder()
    let graph = Graph(directed: true, strict: true)

    func testNodeWithoutAttributes() {
        let node = Node("a")
        
        XCTAssertNil(encoder.encode(node, in: graph))
    }

    func testNodeWithSingleAttribute() {
        var node = Node("a")
        node.label = "A"

        let expected = "a [label=A]"

        XCTAssertEqual(encoder.encode(node, in: graph), expected)
    }

    func testNodeWithMultipleAttributes() {
        var node = Node("a")
        node.label = "A"
        node.shape = .box
        node.class = "entity"

        let expected = "a [class=entity label=A shape=box]"

        XCTAssertEqual(encoder.encode(node, in: graph), expected)
    }

    func testNodeWithFilledStyle() {
        var node = Node("a")
        node.style = .filled(.named(.red))

        let expected = "a [fillcolor=red style=filled]"

        XCTAssertEqual(encoder.encode(node, in: graph), expected)
    }

    func testNodeWithFillColor() {
        var node = Node("a")
        node.fillColor = .named(.red)

        let expected = "a [fillcolor=red style=filled]"

        XCTAssertEqual(encoder.encode(node, in: graph), expected)
    }

    func testNodeWithStyle() {
        var node = Node("a")
        node.style = .striped([.named(.pink), .named(.white), .named(.chocolate)])

        let expected = #"a [fillcolor="pink,white,chocolate" style=striped]"#

        XCTAssertEqual(encoder.encode(node, in: graph), expected)
    }

    func testNodeWithStyleOverwrittenByFillColor() {
        var node = Node("a")
        node.style = .striped([.named(.pink), .named(.white), .named(.chocolate)])
        node.fillColor = .named(.red)

        let expected = "a [fillcolor=red style=filled]"

        XCTAssertEqual(encoder.encode(node, in: graph), expected)
    }

    func testNodeWithKeywordID() {
        var node = Node("Node")
        node.label = "Node"

        let expected = #""Node" [label="Node"]"#

        XCTAssertEqual(encoder.encode(node, in: graph), expected)
    }
}
