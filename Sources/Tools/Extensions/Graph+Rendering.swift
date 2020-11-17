import Foundation
import GraphViz

extension Graph {
    /**
     Renders the graph using the specified layout algorithm to the desired output format.

     - Parameters:
        - layout: The layout algorithm.
        - format: The output format.
     - Throws: `CocoaError` if the corresponding GraphViz tool isn't available.
     */
    public func render(using layout: LayoutAlgorithm, to format: Format) throws -> Data {
        return try Renderer(layout: layout).render(graph: self, to: format)
    }
}
