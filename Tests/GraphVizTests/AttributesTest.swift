import XCTest
@testable import Core

final class AttributesTests: XCTestCase {
    func testGraphAttributesCompleteness() {
        let graph = Graph(directed: true)

        let reflected = Set(Mirror(reflecting: graph.attributes).children.compactMap { ($0.value as! Attributable).name })
        let represented = Set(graph.attributes.arrayValue.map { $0.name })

        for attribute in reflected {
            XCTAssert(represented.contains(attribute), "missing \(attribute)")
        }
    }

    func testSubgraphAttributesCompleteness() {
        let subgraph = Subgraph()

        let reflected = Set(Mirror(reflecting: subgraph.attributes).children.compactMap { ($0.value as! Attributable).name })
        let represented = Set(subgraph.attributes.arrayValue.map { $0.name })

        for attribute in reflected {
            XCTAssert(represented.contains(attribute), "missing \(attribute)")
        }
    }

    func testNodeAttributesCompleteness() {
        let node = Node("a")

        let reflected = Set(Mirror(reflecting: node.attributes).children.compactMap { ($0.value as! Attributable).name })
        let represented = Set(node.attributes.arrayValue.map { $0.name })

        for attribute in reflected {
            XCTAssert(represented.contains(attribute), "missing \(attribute)")
        }
    }
    
    func testEdgeAttributesCompleteness() {
        let edge = Edge(from: "a", to: "b")

        let reflected = Set(Mirror(reflecting: edge.attributes).children.compactMap { ($0.value as! Attributable).name })
        let represented = Set(edge.attributes.arrayValue.map { $0.name })

        for attribute in reflected {
            XCTAssert(represented.contains(attribute), "missing \(attribute)")
        }
    }
}
