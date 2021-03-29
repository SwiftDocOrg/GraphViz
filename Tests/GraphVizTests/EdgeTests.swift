import XCTest
import Core
@testable import DOT

final class EdgeTests: XCTestCase {
    let encoder = DOTEncoder()
    let graph = Graph(directed: true, strict: true)

    func testEdgeWithoutAttributes() {
        let edge = Edge(from: "a", to: "b")

        let expected = "a -> b"

        XCTAssertEqual(encoder.encode(edge, in: graph), expected)
    }

    func testEdgeWithSingleAttribute() {
        var edge = Edge(from: "a", to: "b")
        edge.style = .bold

        let expected = "a -> b [style=bold]"

        XCTAssertEqual(encoder.encode(edge, in: graph), expected)
    }

    func testEdgeWithMultipleAttributes() {
        var edge = Edge(from: "a", to: "b")
        edge.headLabel = "head"
        edge.tailLabel = "tail"

        let expected = "a -> b [headlabel=head taillabel=tail]"

        XCTAssertEqual(encoder.encode(edge, in: graph), expected)
    }
}
