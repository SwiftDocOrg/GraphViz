import XCTest
@testable import GraphVizCore
@testable import DOT
@testable import GraphVizTools

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

    func testGraphRendering() throws {
        graph.render(using: .dot, to: .svg) { result in
            switch result {
            case .success(let data):
                let svg = String(data: data, encoding: .utf8)!

                XCTAssert(svg.starts(with: "<?xml"))
                XCTAssertGreaterThan(svg.count, 100)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testRendererWithRenderer() throws {
        let renderer = Renderer(layout: .dot)
        renderer.render(graph: graph, to: .svg) { result in
            switch result {
            case .success(let data):
                let svg = String(data: data, encoding: .utf8)!

                XCTAssert(svg.starts(with: "<?xml"))
                XCTAssertGreaterThan(svg.count, 100)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
    }
}
