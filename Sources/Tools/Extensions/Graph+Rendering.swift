import Foundation
import GraphViz

extension Graph {
    public func render(using layout: LayoutAlgorithm, to format: Format) throws -> Data {
        return try Renderer(layout: layout).render(graph: self, to: format)
    }
}
