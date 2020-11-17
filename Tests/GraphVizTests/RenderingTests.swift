import XCTest
@testable import GraphViz
@testable import DOT
@testable import Tools

#if !os(Linux)
final class RenderingTests: XCTestCase {
    let encoder = DOTEncoder()
    let graph: Graph = {
        var graph = Graph(directed: true)
        var edge = Edge(from: "a", to: "b")
        edge.class = "weighted"
        edge.decorate = true
        graph.append(edge)
        return graph
    }()

    func testSimpleGraphRendering() throws {
        let data: Data

        do {
            data = try graph.render(using: .dot, to: .svg)
        } catch {
            #if swift(>=5.2)
            throw XCTSkip("Missing dot binary")
            #else
            return
            #endif
        }

        let svg = String(data: data, encoding: .utf8)!

        XCTAssert(svg.starts(with: "<?xml"))
        XCTAssertGreaterThan(svg.count, 100)
    }
}
#endif
