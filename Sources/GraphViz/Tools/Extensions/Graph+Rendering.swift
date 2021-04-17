import Foundation
import Dispatch

extension Graph {
    /**
     Renders the graph using the specified layout algorithm to the desired output format.

     - Parameters:
        - layout: The layout algorithm.
        - format: The output format.
        - options: The rendering options.
     - Throws: `CocoaError` if the corresponding GraphViz tool isn't available.
     */
    public func render(using layout: LayoutAlgorithm,
                       to format: Format,
                       with options: Renderer.Options = [],
                       on queue: DispatchQueue = .main,
                       completion: (@escaping (Result<Data, Swift.Error>) -> Void))
    {
        Renderer(layout: layout).render(graph: self, to: format, completion: completion)
    }
}
