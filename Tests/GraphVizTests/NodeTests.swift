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

    func testNodeWithKeywordID() {
        var node = Node("Node")
        node.label = "Node"

        let expected = #""Node" [label="Node"]"#

        XCTAssertEqual(encoder.encode(node, in: graph), expected)
    }
}
