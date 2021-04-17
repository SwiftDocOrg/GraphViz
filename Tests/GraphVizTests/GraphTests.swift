import XCTest
import GraphVizCore
import GraphVizDOT

final class GraphTests: XCTestCase {
    let encoder = DOTEncoder()

    func testGraph() {
        let graph = Graph()

        let expected = "graph { }"

        XCTAssertTrue(graph.isEmpty)
        XCTAssertEqual(encoder.encode(graph), expected)
    }

    func testStrictDigraph() {
        let graph = Graph(directed: true, strict: true)

        let expected = "strict digraph { }"

        XCTAssertTrue(graph.isEmpty)
        XCTAssertEqual(encoder.encode(graph), expected)
    }

    func testGraphWithNodesAndEdge() {
        var graph = Graph(directed: true, strict: false)

        let a = Node("a")
        let b = Node("b")
        var edge = Edge(from: a, to: b, direction: .forward)
        edge.decorate = true

        graph.append(edge)

        let expected = """
        digraph {
          a -> b [decorate=true]
        }
        """

        XCTAssertFalse(graph.isEmpty)
        XCTAssertEqual(encoder.encode(graph), expected)
    }

    func testExampleGraph() {
        var graph = Graph(directed: true)

        let a = Node("a"), b = Node("b"), c = Node("c")

        graph.append(Edge(from: a, to: b))
        graph.append(Edge(from: a, to: c))

        var b_c = Edge(from: b, to: c)
        b_c.constraint = false
        graph.append(b_c)

        let expected = """
        digraph {
          a -> b
          a -> c
          b -> c [constraint=false]
        }
        """

        XCTAssertFalse(graph.isEmpty)
        XCTAssertEqual(encoder.encode(graph), expected)
    }
}
