import XCTest
@testable import GraphViz
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
        let renderer: Renderer

        do {
            renderer = try Renderer(layout: .dot)
        } catch {
            throw XCTSkip("Missing dot binary")
        }

        let data = try renderer.render(graph: graph, to: .svg)


        let svg = String(data: data, encoding: .utf8)!

        XCTAssert(svg.starts(with: "<?xml"))
        XCTAssertGreaterThan(svg.count, 100)
    }

    func testRendererWithURL() throws {
        let url: URL

        do {
            url = try which("dot")
        } catch {
            throw XCTSkip("Missing dot binary")
        }

        let renderer = try Renderer(url: url)
        let data = try renderer.render(graph: graph, to: .svg)

        let svg = String(data: data, encoding: .utf8)!

        XCTAssert(svg.starts(with: "<?xml"))
        XCTAssertGreaterThan(svg.count, 100)
    }

    func testGraphRendering() throws {
        let data: Data

        do {
            data = try graph.render(using: .dot, to: .svg)
        } catch {
            throw XCTSkip("Missing dot binary")
        }

        let svg = String(data: data, encoding: .utf8)!

        XCTAssert(svg.starts(with: "<?xml"))
        XCTAssertGreaterThan(svg.count, 100)
    }
}
