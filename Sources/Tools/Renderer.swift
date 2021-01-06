import Foundation
import GraphViz
import DOT
import Clibgraphviz

/**
 A GraphViz renderer.

 - Important: GraphViz must be available on your system to use these APIs.
 */
public class Renderer {
    /// The layoutAlgorithm used.
    public var layout: LayoutAlgorithm

    /**
     Creates a renderer for the specified layout algorithm.

     - Throws: `CocoaError` if the corresponding GraphViz tool isn't available.
     */
    public init(layout: LayoutAlgorithm) {
        self.layout = layout
    }

    /**
     Renders a graph to the specified output format.

     - Parameters:
        - graph: The graph to be rendered.
        - format: The output format.
     - Throws: `Error` if GraphViz is unable to render.
     */
    public func render(graph: Graph, to format: Format) throws -> Data {
        let dot = DOTEncoder().encode(graph)
        return try render(dot: dot, to: format)
    }

    /**
     Renders a DOT-encoded string to the specified output format.

     - Parameters:
        - dot: A DOT-encoded string to be rendered.
        - format: The output format.
     - Throws: `Error` if GraphViz is unable to render.
     */
    public func render(dot: String, to format: Format) throws -> Data {
        let context = gvContext()
        defer { gvFreeContext(context)}

        let graph = try dot.withCString { cString in
            try attempt { agmemread(cString) }
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
}
