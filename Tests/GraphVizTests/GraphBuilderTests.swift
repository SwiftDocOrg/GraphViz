import XCTest
import GraphVizCore
import GraphVizDOT
@testable import GraphVizBuilder

// Workaround for "error: ambiguous reference to member '-->'" on Swift 5.1
#if swift(>=5.2)
final class GraphBuilderTests: XCTestCase {
    let encoder = DOTEncoder()

    func testEmptyGraph() {
        let graph = Graph {
            Node("a")
        }

        let expected = """
        graph { }
        """

        XCTAssertEqual(encoder.encode(graph), expected)
    }

    func testEmptyStrictDirectedGraph() {
        let graph = Graph(directed: true, strict: true) {
            Node("a")
        }

        let expected = """
        strict digraph { }
        """

        XCTAssertEqual(encoder.encode(graph), expected)
    }

    func testEmptyGraphWithSingleAttribute() {
        let graph = Graph {
            Node("a").backgroundColor(.named(.blue))
        }.pageSize(Size(width: 8.5, height: 11))

        let expected = """
        graph {
          size="8.5,11"
          a [bgcolor=blue]
        }
        """

        XCTAssertEqual(encoder.encode(graph), expected)
    }

    func testEmptyGraphWithMultipleAttributes() {
        let graph = Graph {
            Node("a")
        }.pageSize(Size(width: 8.5, height: 11))
            .center(true)

        let expected = """
        graph {
          center=true
          size="8.5,11"
        }
        """

        XCTAssertEqual(encoder.encode(graph), expected)
    }

    func testGraphWithNodesAndEdge() {
        let graph = Graph(directed: true) {
            ("a" --> "b").style(.bold)
        }

        let expected = """
            digraph {
              a -> b [style=bold]
            }
            """

        XCTAssertEqual(encoder.encode(graph), expected)
    }

    func testGraphWithSubgraph() {
        let graph = Graph(directed: true) {
            Subgraph {
                "a" --> "b"
                "a" --> "c"
                "a" --> "d"
            }.rank(.same)

            "b" --> ["e", "f", "g"]
        }

        let expected = """
            digraph {
              subgraph {
                  rank=same
                  a -> b
                  a -> c
                  a -> d
              }
              subgraph {
                  b -> e
                  b -> f
                  b -> g
              }
            }
            """

        XCTAssertEqual(encoder.encode(graph), expected)
    }

    func testExampleGraph() {
        let graph = Graph(directed: true) {
            "a" --> "b"
            "a" --> "c"
            ("b" --> "c").constraint(false)
        }

        let expected = """
        digraph {
          a -> b
          a -> c
          b -> c [constraint=false]
        }
        """

        XCTAssertEqual(encoder.encode(graph), expected)
    }
}

#endif
