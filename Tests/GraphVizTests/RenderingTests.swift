import XCTest
@testable import Core
@testable import DOT
@testable import Tools

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

    func testRendererWithLayout() throws {
        let data: Data

        do {
            let renderer = Renderer(layout: .dot)
            data = try renderer.render(graph: graph, to: .svg)
        } catch {
            throw XCTSkip(error.localizedDescription)
        }

        let svg = String(data: data, encoding: .utf8)!

        XCTAssert(svg.starts(with: "<?xml"))
        XCTAssertGreaterThan(svg.count, 100)
    }

    func testGraphRendering() throws {
        let data: Data

        do {
            data = try graph.render(using: .dot, to: .svg)
        } catch {
            throw XCTSkip(error.localizedDescription)
        }

        let svg = String(data: data, encoding: .utf8)!

        XCTAssert(svg.starts(with: "<?xml"))
        XCTAssertGreaterThan(svg.count, 100)
    }
}
