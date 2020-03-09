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

        let expected = "a [label=A shape=box]"

        XCTAssertEqual(encoder.encode(node, in: graph), expected)
    }
}
