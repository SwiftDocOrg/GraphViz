import XCTest
@testable import GraphViz
@testable import DOT
import SnapshotTesting

#if os(macOS)
    typealias Image = NSImage
#elseif os(iOS) || os(tvOS)
    typealias Image = UIImage
#else
    #error("platform not supported")
#endif

final class RenderingTests: XCTestCase {
    let encoder = DOTEncoder()
    let graph: Graph = {
        var graph = Graph(directed: true)
        var edge = Edge(from: "a", to: "b")
        edge.decorate = true
        graph.append(edge)
        return graph
    }()

    func testSimpleGraphRendering() throws {
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

    func testSimpleGraphRenderingToPNG() throws {
        let data = try graph.render(using: .dot, to: .png)

        guard let image = Image(data: data) else {
            XCTFail("Could not convert data to NSImage")
            return
        }

        assertSnapshot(matching: image, as: .image)
    }
}
