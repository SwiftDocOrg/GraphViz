import Foundation
import Dispatch

import Clibgraphviz

/**
 A GraphViz renderer.

 - Important: GraphViz must be available on your system to use these APIs.
 */
public class Renderer {
    /// Rendering options.
    public struct Options: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /**
         tred  computes  the  transitive reduction of directed graphs, and
         prints the resulting graphs to  standard  output.   This  removes
         edges  implied by transitivity.  Nodes and subgraphs are not oth-
         erwise affected.  The ``meaning'' and  validity  of  the  reduced
         graphs  is application dependent.  tred is particularly useful as
         a preprocessor to dot to reduce clutter in dense layouts.

         Undirected graphs are silently ignored.
         */
        static let removeEdgesImpliedByTransitivity = Options(rawValue: 1 << 0)
    }

    private static let queue = DispatchQueue(label: "org.swiftdoc.GraphViz.rendering")

    /// The layout algorithm used.
    public var layout: LayoutAlgorithm

    /// The rendering options.
    public var options: Options = []

    /**
     Creates a renderer for the specified layout algorithm.

     - Throws: `CocoaError` if the corresponding GraphViz tool isn't available.
     */
    public init(layout: LayoutAlgorithm, options: Options = []) {
        self.layout = layout
        self.options = options
    }

    /**
     Renders a graph to the specified output format.

     - Parameters:
        - graph: The graph to be rendered.
        - format: The output format.
     - Throws: `Error` if GraphViz is unable to render.
     */
    public func render(graph: Graph,
                       to format: Format,
                       on queue: DispatchQueue = .main,
                       completion: (@escaping (Result<Data, Swift.Error>) -> Void))
    {
        let dot = DOTEncoder().encode(graph)
        render(dot: dot, to: format, on: queue, completion: completion)
    }

    /**
     Renders a DOT-encoded string to the specified output format.

     - Parameters:
        - dot: A DOT-encoded string to be rendered.
        - format: The output format.
     - Throws: `Error` if GraphViz is unable to render.
     */
    public func render(dot: String,
                       to format: Format,
                       on queue: DispatchQueue = .main,
                       completion: (@escaping (Result<Data, Swift.Error>) -> Void))
    {
        let options = self.options
        let layout = self.layout

        Renderer.queue.async {
            let result = Result { () throws -> Data in
                let context = gvContext()
                defer { gvFreeContext(context)}

                let graph = try dot.withCString { cString in
                    try attempt { agmemread(cString) }
                }

                if options.contains(.removeEdgesImpliedByTransitivity) {
                    try attempt { gvToolTred(graph) }
                }

                try layout.rawValue.withCString { cString in
                    try attempt { gvLayout(context, graph, cString) }
                }
                defer { gvFreeLayout(context, graph) }

                var data: UnsafeMutablePointer<Int8>?
                var length: UInt32 = 0
                try format.rawValue.withCString { cString in
                    try attempt { gvRenderData(context, graph, cString, &data, &length) }
                }
                defer { gvFreeRenderData(data) }
                guard let bytes = data else { return Data() }

                return Data(bytes: UnsafeRawPointer(bytes), count: Int(length))
            }

            completion(result)
        }
    }
}
