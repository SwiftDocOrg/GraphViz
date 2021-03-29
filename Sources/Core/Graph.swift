import Foundation

@dynamicMemberLookup
public struct Graph: Equatable {
    /// Whether the graph is directed.
    public var directed: Bool

    /// Whether the graph is strict.
    public var strict: Bool

    /// The id of the graph, is any.
    public var id: String? = nil

    /// Creates a graph.
    /// - Parameters:
    ///   - directed: Whether the graph is directed; `false by default`.
    ///   - strict: Whether the graph is strict; `false` by default.
    public init(directed: Bool = false, strict: Bool = false) {
        self.directed = directed
        self.strict = strict
    }

    /// Subgraphs contained by the graph.
    public private(set) var subgraphs: [Subgraph] = []

    /// Nodes contained by the graph.
    public private(set) var nodes: [Node] = []

    /// Edges contained by the graph.
    public private(set) var edges: [Edge] = []

    /**
     Returns whether the graph is empty.

     A graph is considered to be empty if it
     has no subgraphs,
     has no edges,
     has no nodes with attributes, and
     has no attributes itself.
     */
    public var isEmpty: Bool {
        return subgraphs.isEmpty &&
            edges.isEmpty &&
            attributes.dictionaryValue.isEmpty &&
            nodes.filter { !$0.attributes.dictionaryValue.isEmpty }.isEmpty
    }

    public mutating func append(_ subgraph: Subgraph) {
        subgraphs.append(subgraph)
    }

    public mutating func append<S>(contentsOf subgraphs: S) where S.Element == Subgraph, S: Sequence {
        for subgraph in subgraphs {
            self.subgraphs.append(subgraph)
        }
    }

    public mutating func append(_ node: Node) {
        nodes.append(node)
    }

    public mutating func append<S>(contentsOf nodes: S) where S.Element == Node, S: Sequence {
        for node in nodes {
            self.nodes.append(node)
        }
    }

    public mutating func append(_ edge:Edge) {
        edges.append(edge)
    }

    public mutating func append<S>(contentsOf edges: S) where S.Element == Edge, S: Sequence {
        for edge in edges {
            self.edges.append(edge)
        }
    }

    public private(set) var attributes: Attributes = Attributes()

    public subscript<T>(dynamicMember member: WritableKeyPath<Attributes, T>) -> T {
        get {
            return attributes[keyPath: member]
        }

        set {
            attributes[keyPath: member] = newValue
        }
    }
}

// MARK: - Attributes

extension Graph {
    public enum RankDirection: String, Hashable {
        case topToBottom = "TB"
        case leftToRight = "LR"
    }

    /**
     "BL", "BR", "TL", "TR", "RB", "RT", "LB", "LT". These specify the 8 row or column major orders for traversing a rectangular array, the first character corresponding to the major order and the second to the minor order. Thus, for "BL", the major order is from bottom to top, and the minor order is from left to right. This means the bottom row is traversed first, from left to right, then the next row up, from left to right, and so on, until the topmost row is traversed.
     */
    public enum PageDirection: String, Hashable {
        case bottomToTopLeftToRight = "BL"
        case bottomToTopRightToLeft = "BR"
        case topToBottomLeftToRight = "TL"
        case topToBottomRightToLeft = "TR"
        case rightToLeftBottomToTop = "RB"
        case rightToLeftTopToBottom = "RT"
        case leftToRightBottomToTop = "LB"
        case leftToRightTopToBottom = "LT"
    }

    public enum Orientation: RawRepresentable, Hashable {
        case portrait
        case landscape
        case custom(degrees: Double)

        public init?(rawValue: Double) {
            self = .custom(degrees: rawValue)
        }

        public var rawValue: Double {
            switch self {
            case .portrait: return 0
            case .landscape: return 90
            case .custom(degrees: let degrees): return degrees
            }
        }
    }

    public enum ClusterMode: String, Hashable {
        case none
        case local
        case global
    }

    /**
     "node", "clust" , "graph"
     The modes "node", "clust" or "graph" specify that the components should be packed together tightly, using the specified granularity. A value of "node" causes packing at the node and edge level, with no overlapping of these objects. This produces a layout with the least area, but it also allows interleaving, where a node of one component may lie between two nodes in another component. A value of "graph" does a packing using the bounding box of the component. Thus, there will be a rectangular region around a component free of elements of any other component. A value of "clust" guarantees that top-level clusters are kept intact. What effect a value has also depends on the layout algorithm. For example, neato does not support clusters, so a value of "clust" will have the same effect as the default "node" value.

     - Important: The mode "array(_flag)?(%d)?" is unsupported.
     */
    public enum PackingMode: String {
        case node
        case cluster = "clust"
        case graph
    }

    public enum Spline: String, Hashable {
        case none
        case line
        case polyline
        case curved
        case orthogonal = "ortho"
        case spline
    }

    /**
     viewPort
     "%lf,%lf,%lf,%lf,%lf" or "%lf,%lf,%lf,'%s'"
     The viewPort W,H,Z,x,y or W,H,Z,N specifies a viewport for the final image. The pair (W,H) gives the dimensions (width and height) of the final image, in points. The optional Z is the zoom factor, i.e., the image in the original layout will be W/Z by H/Z points in size. By default, Z is 1. The optional last part is either a pair (x,y) giving a position in the original layout of the graph, in points, of the center of the viewport, or the name N of a node whose center should used as the focus. By default, the focus is the center of the graph bounding box, i.e., (bbx/2,bby/2), where "bbx,bby" is the value of the bounding box attribute bb.

     Sample values: 50,50,.5,'2.8 BSD' or 100,100,2,450,300. The first will take the 100x100 point square centered on the node 2.8 BSD and scale it down by 0.5, yielding a 50x50 point final image.
     */
    // TODO:
    public struct Viewport: Hashable {
        public var width: Double
        public var height: Double
        public var center: Center
        public var scale: Double

        public enum Center: Hashable {
            case point(x: Double, y: Double)
            case node(name: Node.ID)
        }

        public init(width: Double, height: Double, center: Center, scale: Double = 1.0) {
            self.width = width
            self.height = height
            self.center = center
            self.scale = scale
        }
    }

    /**
     Technique for optimizing the layout. For neato, if mode is "major", neato uses stress majorization. If mode is "KK", neato uses a version of the gradient descent method. The only advantage to the latter technique is that it is sometimes appreciably faster for small (number of nodes `<` 100) graphs. A significant disadvantage is that it may cycle.
     There are two experimental modes in neato, "hier", which adds a top-down directionality similar to the layout used in dot, and "ipsep", which allows the graph to specify minimum vertical and horizontal distances between nodes. (See the sep attribute.)

     For sfdp, the default mode is "spring", which corresponds to using a spring-electrical model. Setting mode to "maxent" causes a similar model to be run but one that also takes into account edge lengths specified by the "len" attribute.
     */
    public enum Mode: String {
        case major
        case kk = "KK"
        case hier
        case ipsep
        case spring
        case maxent
    }

    public enum QuadtreeScheme: String {
        case none
        case normal
        case fast
    }

    public enum Smoothing: String {
        case none
        case averageDist = "avg_dist"
        case graphDist = "graph_dist"
        case powerDist = "power_dist"
        case rng
        case spring
        case triangle
    }

    /**
     startType
     has the syntax (style)?(seed)?.
     If style is present, it must be one of the strings "regular", "self", or "random". In the first case, the nodes are placed regularly about a circle. In the second case, an abbreviated version of neato is run to obtain the initial layout. In the last case, the nodes are placed randomly in a unit square.

     If seed is present, it specifies a seed for the random number generator. If seed is a positive number, this is used as the seed. If it is anything else, the current time, and possibly the process id, is used to pick a seed, thereby making the choice more random. In this case, the seed value is stored in the graph.

     If the value is just "random", a time-based seed is chosen.

     Note that input positions, specified by a node's pos attribute, are only used when the style is "random"
     */
    public enum InitialNodeLayoutStrategy: Hashable {
        case regular
        case `self`
        case random(seed: Int? = nil)
    }

    /**
     label_scheme
     The value indicates whether to treat a node whose name has the form |edgelabel|* as a special node representing an edge label. The default (0) produces no effect. If the attribute is set to 1, sfdp uses a penalty-based method to make that kind of node close to the center of its neighbor. With a value of 2, sfdp uses a penalty-based method to make that kind of node close to the old center of its neighbor. Finally, a value of 3 invokes a two-step process of overlap removal and straightening.

     >     int    0    0    sfdp only
     */
    public enum LabelScheme: Int, Hashable {
        case `default` = 0
        case one = 1
        case two = 2
        case three = 3
    }

    /**
     "breadthfirst","nodesfirst","edgesfirst" These specify the order in which nodes and edges are drawn in concrete output. The default "breadthfirst" is the simplest, but when the graph layout does not avoid edge-node overlap, this mode will sometimes have edges drawn over nodes and sometimes on top of nodes. If the mode "nodesfirst" is chosen, all nodes are drawn first, followed by the edges. This guarantees an edge-node overlap will not be mistaken for an edge ending at a node. On the other hand, usually for aesthetic reasons, it may be desirable that all edges appear beneath nodes, even if the resulting drawing is ambiguous. This can be achieved by choosing "edgesfirst".
     */
    public enum OutputOrder: String, Hashable {
        case breadthFirst = "breadthfirst"
        case nodesFirst = "nodesfirst"
        case edgesFirst = "edgesfirst"
    }

    public enum FontNamingConvention: String, Hashable {
        case svg
        case postScript = "ps"
        case fontconfig = "gd"
    }

    public struct Attributes: Hashable {
        /// Comments are inserted into output. Device-dependent
        @Attribute("comment")
        public var comment: String?

        /// Unofficial, but supported by certain output formats, like svg.
        @Attribute("class")
        public var `class`: String?

        /**
         Specifies the name of the layout algorithm to use, such as "dot" or "neato". Normally, graphs should be kept independent of a type of layout. In some cases, however, it can be convenient to embed the type of layout desired within the graph. For example, a graph containing position information from a layout might want to record what the associated layout algorithm was.

         > This attribute takes precedence over the -K flag or the actual command name used.
         */
        @Attribute("layout")
        public var layoutAlgorithm: LayoutAlgorithm?

        /**
         If the value of the attribute is "out", then the outedges of a node, that is, edges with the node as its tail node, must appear left-to-right in the same order in which they are defined in the input. If the value of the attribute is "in", then the inedges of a node must appear left-to-right in the same order in which they are defined in the input. If defined as a graph or subgraph attribute, the value is applied to all nodes in the graph or subgraph. Note that the graph attribute takes precedence over the node attribute.
         */
        @Attribute("ordering")
        public var ordering: Ordering?

        /**
         outputorder    G    outputMode    breadthfirst

         outputorder
         Specify order in which nodes and edges are drawn.
         */
        @Attribute("outputorder")
        public var outputOrder: OutputOrder?

        /**
         Mode used for handling clusters. If clusterrank is "local", a subgraph whose name begins with "cluster" is given special treatment. The subgraph is laid out separately, and then integrated as a unit into its parent graph, with a bounding rectangle drawn about it. If the cluster has a label parameter, this label is displayed within the rectangle. Note also that there can be clusters within clusters. At present, the modes "global" and "none" appear to be identical, both turning off the special cluster processing.
         */
        @Attribute("rank")
        public var clusterRank: ClusterMode?


        /// If true, use edge concentrators. This merges multiedges into a single edge and causes partially parallel edges to share part of their paths. The latter feature is not yet available outside of dot.
        /// > concentrate    G    bool    false
        @Attribute("concentrate")
        public var concentrate: Bool?

        /**
         Determines if and how node overlaps should be removed. Nodes are first enlarged using the sep attribute. If "true" , overlaps are retained. If the value is "scale", overlaps are removed by uniformly scaling in x and y. If the value converts to "false", and it is available, Prism, a proximity graph-based algorithm, is used to remove node overlaps. This can also be invoked explicitly with "overlap=prism". This technique starts with a small scaling up, controlled by the overlap_scaling attribute, which can remove a significant portion of the overlap. The prism option also accepts an optional non-negative integer suffix. This can be used to control the number of attempts made at overlap removal. By default, overlap="prism" is equivalent to overlap="prism1000". Setting overlap="prism0" causes only the scaling phase to be run.
         If Prism is not available, or the version of Graphviz is earlier than 2.28, "overlap=false" uses a Voronoi-based technique. This can always be invoked explicitly with "overlap=voronoi".

         If the value is "scalexy", x and y are separately scaled to remove overlaps.

         If the value is "compress", the layout will be scaled down as much as possible without introducing any overlaps, obviously assuming there are none to begin with.

         N.B.The remaining allowed values of overlap correspond to algorithms which, at present, can produce bad aspect ratios. In addition, we deprecate the use of the "ortho*" and "portho*".

         If the value is "vpsc", overlap removal is done as a quadratic optimization to minimize node displacement while removing node overlaps.

         If the value is "orthoxy" or "orthoyx", overlaps are moved by optimizing two constraint problems, one for the x axis and one for the y. The suffix indicates which axis is processed first. If the value is "ortho", the technique is similar to "orthoxy" except a heuristic is used to reduce the bias between the two passes. If the value is "ortho_yx", the technique is the same as "ortho", except the roles of x and y are reversed. The values "portho", "porthoxy", "porthoxy", and "portho_yx" are similar to the previous four, except only pseudo-orthogonal ordering is enforced.

         If the layout is done by neato with mode="ipsep", then one can use overlap=ipsep. In this case, the overlap removal constraints are incorporated into the layout algorithm itself. N.B. At present, this only supports one level of clustering.

         Except for fdp and sfdp, the layouts assume overlap="true" as the default. Fdp first uses a number of passes using a built-in, force-directed technique to try to remove overlaps. Thus, fdp accepts overlap with an integer prefix followed by a colon, specifying the number of tries. If there is no prefix, no initial tries will be performed. If there is nothing following a colon, none of the above methods will be attempted. By default, fdp uses overlap="9:prism". Note that overlap="true", overlap="0:true" and overlap="0:" all turn off all overlap removal.

         By default, sfdp uses overlap="prism0".

         Except for the Voronoi and prism methods, all of these transforms preserve the orthogonal ordering of the original layout. That is, if the x coordinates of two nodes are originally the same, they will remain the same, and if the x coordinate of one node is originally less than the x coordinate of another, this relation will still hold in the transformed layout. The similar properties hold for the y coordinates. This is not quite true for the "porth*" cases. For these, orthogonal ordering is only preserved among nodes related by an edge.

         overlap    G    string
         bool    true        not dot
         */
        @Attribute("overlap")
        public var overlap: String? // FIXME

        /**
         normalize
         If set, normalize coordinates of final layout so that the first point is at the origin, and then rotate the layout so that the angle of the first edge is specified by the value of normalize in degrees. If normalize is not a number, it is evaluated as a bool, with true corresponding to 0 degrees. NOTE: Since the attribute is evaluated first as a number, 0 and 1 cannot be used for false and true.

         >    G    double
         bool    false        not dot
         */
        @Attribute("normalize")
        public var normalize: Double?

        /// > Minimum space between two adjacent nodes in the same rank, in inches.
        /**
         In dot, this specifies the minimum space between two adjacent nodes in the same rank, in inches.
         For other layouts, this affects the spacing between loops on a single node, or multiedges between a pair of nodes.
         */
        @Attribute("minlen")
        public var nodeSeparation: Double?


        // MARK: - Drawing Attributes

        /**
         Width and height of output pages, in inches. If only a single value is given, this is used for both the width and height.
         If this is set and is smaller than the size of the layout, a rectangular array of pages of the specified page size is overlaid on the layout, with origins aligned in the lower-left corner, thereby partitioning the layout into pages. The pages are then produced one at a time, in pagedir order.

         At present, this only works for PostScript output. For other types of output, one should use another tool to split the output into multiple output files. Or use the viewport to generate multiple files.
         */
        @Attribute("size")
        public var pageSize: Size?

        /**
         If the page attribute is set and applicable, this attribute specifies the order in which the pages are emitted. This is limited to one of the 8 row or column major orders.
         */
        @Attribute("page")
        public var pageDirection: PageDirection?

        /// Bounding box of drawing in points.
        /// bb    G    rect            write only
        @Attribute("bb")
        public var boundingBox: Rectangle?

        /**
         Margin used around polygons for purposes of spline edge routing. The interpretation is the same as given for sep. This should normally be strictly less than sep.
         G    addDouble
         addPoint    +3        not dot
         >
         */
        @Attribute("margin")
        public var margin: Double?

        /// If true, the drawing is centered in the output canvas.
        @Attribute("center")
        public var center: Bool?

        /**
         > Sets the aspect ratio (drawing height/drawing width) for the drawing. Note that this is adjusted before the size attribute constraints are enforced.

         If ratio is numeric, it is taken as the desired aspect ratio. Then, if the actual aspect ratio is less than the desired ratio, the drawing height is scaled up to achieve the desired ratio; if the actual ratio is greater than that desired ratio, the drawing width is scaled up.

         If ratio = "fill" and the size attribute is set, the drawing is scaled to achieve the aspect ratio implied by size. As size is set, when the drawing is later scaled to fit that rectangle, the resulting picture will fill the rectangle.

         If ratio = "compress" and the size attribute is set, dot attempts to compress the initial layout to fit in the given size. This achieves a tighter packing of nodes but reduces the balance and symmetry.
         */
        @Attribute("ratio")
        public var aspectRatio: AspectRatio?

        /**
         If 90, set drawing orientation to landscape.
         rotate    G    int    0
         */
        @Attribute("rotate")
        public var orientation: Orientation?

        // FIXME: reconcile these two properties
        /**
         Causes the final layout to be rotated counter-clockwise by the specified number of degrees.
         G    int    0
         rotation    G    double    0        sfdp only
         */
        @Attribute("rotation")
        public var rotation: Double?

        /**
         If set, after the initial layout, the layout is scaled by the given factors. If only a single number is given, this is used for both factors.
         >     not dot
         */
        @Attribute("scale")
        public var scale: Size?

        /**
         When attached to the root graph, this color is used as the background for entire canvas. When a cluster attribute, it is used as the initial background for the cluster. If a cluster has a filled style, the cluster's fillcolor will overlay the background color.

         If the value is a colorList, a gradient fill is used. By default, this is a linear fill; setting style=radial will cause a radial fill. At present, only two colors are used. If the second color (after a colon) is missing, the default color is used for it. See also the gradientangle attribute for setting the gradient angle.

         For certain output formats, such as PostScript, no fill is done for the root graph unless bgcolor is explicitly set. For bitmap formats, however, the bits need to be initialized to something, so the canvas is filled with white by default. This means that if the bitmap output is included in some other document, all of the bits within the bitmap's bounding box will be set, overwriting whatever color or graphics were already on the page. If this effect is not desired, and you only want to set bits explicitly assigned in drawing the graph, set bgcolor="transparent".
         */
        @Attribute("bgcolor")
        public var backgroundColor: Color?

        // MARK: - Link Attributes

        ///
        @Attribute("href")
        public var href: String?

        ///
        @Attribute("URL")
        public var url: URL?


        // MARK: - Label Attributes

        /**
         > Text label attached to objects. Different from ids labels can contain almost any special character, but not ".

         If a node does not have the attribute label, the value of the attribute id is used. If a node shall not have a label, label="" must be used.

         The escape sequences "\n", "\l" and "\r" divide the label into lines, centered, left-justified and right-justified, respectively.

         Change the appearance of the labels with the attributes fontname, fontcolor and fontsize.
         */
        @Attribute("label")
        public var label: String?


        /**
         If true, all xlabel attributes are placed, even if there is some overlap with nodes or other labels.
         */
        @Attribute("forcelabels")
        public var forceLabels: Bool?

        /// > The font color for object labels.
        @Attribute("fontcolor")
        public var textColor: Color?

        /// > The name of the used font. (System dependend)
        /// > The font size for object labels.
        @Attribute("fontname")
        public var fontName: String?

        @Attribute("fontsize")
        public var fontSize: Double?

        /**
         If quantum > 0.0, node label dimensions will be rounded to integral multiples of the quantum.
         > G    double    0.0    0.0
         */
        @Attribute("quantum")
        public var labelDimensionUnit: Double?

        /**
         By default, the justification of multi-line labels is done within the largest context that makes sense. Thus, in the label of a polygonal node, a left-justified line will align with the left side of the node (shifted by the prescribed margin). In record nodes, left-justified line will line up with the left side of the enclosing column of fields. If nojustify is "true", multi-line labels will be justified in the context of itself. For example, if the attribute is set, the first label line is long, and the second is shorter and left-justified, the second will align with the left-most character in the first line, regardless of how large the node might be.
         */
        @Attribute("nojustify")
        public var noJustify: Bool?




        // TODO:
        //        /**
        //         Specifies margin to leave around nodes when removing node overlap. This guarantees a minimal non-zero distance between nodes.
        //         If the attribute begins with a plus sign '+', an additive margin is specified. That is, "+w,h" causes the node's bounding box to be increased by w points on the left and right sides, and by h points on the top and bottom. Without a plus sign, the node is scaled by 1 + w in the x coordinate and 1 + h in the y coordinate.
        //
        //         If only a single number is given, this is used for both dimensions.
        //
        //         If unset but esep is defined, the sep values will be set to the esep values divided by 0.8. If esep is unset, the default value is used.
        //         > sep    G    addDouble
        //         addPoint    +4        not dot
        //         */
        //        public var sep: Double?



        /**
         showboxes
         Print guide boxes in PostScript at the beginning of routesplines if 1, or at the end if 2. (Debugging)
         >     ENG    int    0    0    dot only
         */
        @Attribute("showboxes")
        public var guideBoxLocation: Location?

        /**
         If packmode indicates an array packing, this attribute specifies an insertion order among the components, with smaller values inserted first.
         > GCN    int    0    0
         */
        @Attribute("sortvaue")
        public var sortValue: Int?

        /**
         Controls how, and if, edges are represented. If true, edges are drawn as splines routed around nodes; if false, edges are drawn as line segments. If set to none or "", no edges are drawn at all.
         (1 March 2007) The values line and spline can be used as synonyms for false and true, respectively. In addition, the value polyline specifies that edges should be drawn as polylines.

         (28 Sep 2010) The value ortho specifies edges should be routed as polylines of axis-aligned segments. Currently, the routing does not handle ports or, in dot, edge labels.

         (25 Sep 2012) The value curved specifies edges should be drawn as curved arcs.

         By default, the attribute is unset. How this is interpreted depends on the layout. For dot, the default is to draw edges as splines. For all other layouts, the default is to draw edges as line segments. Note that for these latter layouts, if splines="true", this requires non-overlapping nodes (cf. overlap). If fdp is used for layout and splines="compound", then the edges are drawn to avoid clusters as well as nodes.
         */
        @Attribute("splines")
        public var splines: Spline?

        /**
         Clipping window on final drawing. Note that this attribute supersedes any size attribute. The width and height of the viewport specify precisely the final size of the output.
         */
        @Attribute("viewport")
        public var viewport: Viewport?


        // MARK: Layout-specific Attributes

        // MARK: dot

        /**
         Sets direction of graph layout. For example, if rankdir="LR", and barring cycles, an edge T -> H; will go from left to right. By default, graphs are laid out from top to bottom.
         This attribute also has a side-effect in determining how record nodes are interpreted. See record shapes.

         > dot only
         */
        @Attribute("rankdir")
        public var rankDirection: RankDirection?

        ///// If true, allow edges between clusters. (See lhead and ltail below.)
        ///// > compound    G    bool    false        dot only
        @Attribute("compound")
        public var compound: Bool?

        /**
         If true and there are multiple clusters, run crossing minimization a second time.

         > remincross    G    bool    true        dot only
         */
        @Attribute("remincross")
        public var runCrossingMinimizationOnce: Bool?

        /**
         mclimit
         Multiplicative scale factor used to alter the MinQuit (default = 8) and MaxIter (default = 24) parameters used during crossing minimization. These correspond to the number of tries without improvement before quitting and the maximum number of iterations in each pass.

         G    double    1.0        dot only
         */
        @Attribute("mclimit")
        public var minimumScaleFactor: Double?

        /**

         newrank
         The original ranking algorithm in dot is recursive on clusters. This can produce fewer ranks and a more compact layout, but sometimes at the cost of a head node being place on a higher rank than the tail node. It also assumes that a node is not constrained in separate, incompatible subgraphs. For example, a node cannot be in a cluster and also be constrained by rank=same with a node not in the cluster.
         If newrank=true, the ranking algorithm does a single global ranking, ignoring clusters. This allows nodes to be subject to multiple constraints. Rank constraints will usually take precedence over edge constraints.

         >     G    bool    false        dot only
         */
        @Attribute("newrank")
        public var useNewRankingAlgorithm: Bool?

        /**
         searchsize
         During network simplex, maximum number of edges with negative cut values to search when looking for one with minimum cut value.

         >     dot only
         */
        @Attribute("searchsize")
        public var searchSize: Int?

        /**

         nslimit
         nslimit1    G    double            dot only

         nslimit ,
         nslimit1
         Used to set number of iterations in network simplex applications. nslimit is used in computing node x coordinates, nslimit1 for ranking nodes. If defined, # iterations = nslimit(1) * # nodes; otherwise, # iterations = MAXINT.
         */
        @Attribute("nslimit")
        public var maximumNetworkSimplexIterationsForComputingNodeCoordinates: Int?

        /**
         Used to set number of iterations in network simplex applications. nslimit is used in computing node x coordinates, nslimit1 for ranking nodes. If defined, # iterations = nslimit(1) * # nodes; otherwise, # iterations = MAXINT.
         */
        @Attribute("nslimit1")
        public var maximumNetworkSimplexIterationsForRankingNodes: Int?

        // MARK: dot, twopi

        /**
         In dot, this gives the desired rank separation, in inches. This is the minimum vertical distance between the bottom of the nodes in one rank and the tops of nodes in the next. If the value contains "equally", the centers of all ranks are spaced equally apart. Note that both settings are possible, e.g., ranksep = "1.2 equally".
         In twopi, this attribute specifies the radial separation of concentric circles. For twopi, ranksep can also be a list of doubles. The first double specifies the radius of the inner circle; the second double specifies the increase in radius from the first circle to the second; etc. If there are more circles than numbers, the last number is used as the increment for the remainder.

         > dot and twopi only
         */
        @Attribute("ranksep")
        public var rankSeparation: Double?


        // MARK: not dot

        /**
         Factor to scale up drawing to allow margin for expansion in Voronoi technique. dim' = (1+2*margin)*dim.
         > voro_margin    G    double    0.05    0.0    not dot
         */
        @Attribute("voro_margin")
        public var voronoiMargin: Double?

        // MARK: neato

        @Attribute("mode")
        public var mode: Mode?

        /**
         model
         This value specifies how the distance matrix is computed for the input graph. The distance matrix specifies the ideal distance between every pair of nodes. neato attemps to find a layout which best achieves these distances. By default, it uses the length of the shortest path, where the length of each edge is given by its len attribute. If model is "circuit", neato uses the circuit resistance model to compute the distances. This tends to emphasize clusters. If model is "subset", neato uses the subset model. This sets the edge length to be the number of nodes that are neighbors of exactly one of the end points, and then calculates the shortest paths. This helps to separate nodes with high degree.
         For more control of distances, one can use model=mds. In this case, the len of an edge is used as the ideal distance between its vertices. A shortest path calculation is only used for pairs of nodes not connected by an edge. Thus, by supplying a complete graph, the input can specify all of the relevant distances.

         model    G    string    shortpath        neato only

         */
        @Attribute("model")
        public var model: String?

        /**
         mosek
         If Graphviz is built with MOSEK defined, mode=ipsep and mosek=true, the Mosek software (www.mosek.com) is use to solve the ipsep constraints.

         mosek    G    bool    false        neato only
         */
        @Attribute("mosek")
        public var useMOSEK: Bool?
        //        {
        //            didSet {
        //                if useMOSEK == true {
        //                    mode = .ipsep
        //                }
        //            }
        //        }

        /**
         Terminating condition. If the length squared of all energy gradients are < epsilon, the algorithm stops.

         > epsilon    G    double    .0001 * # nodes(mode == KK)
         .0001(mode == major)        neato only
         */
        @Attribute("epsilon")
        public var epsilon: Double?

        ///**
        // This specifies the distance between nodes in separate connected components. If set too small, connected components may overlap. Only applicable if pack=false.
        // > defaultdist    G    double    1+(avg. len)*sqrt(|V|)    epsilon    neato only
        // */
        @Attribute("defaultdist")
        public var defaultDistance: Double?

        /**
         notranslate
         By default, the final layout is translated so that the lower-left corner of the bounding box is at the origin. This can be annoying if some nodes are pinned or if the user runs neato -n. To avoid this translation, set notranslate to true.
         > notranslate    G    bool    false        neato only
         */
        @Attribute("notranslate")
        public var noTranslate: Bool?

        /**
         Only valid when mode="ipsep". If true, constraints are generated for each edge in the largest (heuristic) directed acyclic subgraph such that the edge must point downwards. If "hier", generates level constraints similar to those used with mode="hier". The main difference is that, in the latter case, only these constraints are involved, so a faster solver can be used.

         > string
         bool    false        neato only
         */
        @Attribute("diredgeconstraints")
        public var generateDirectedEdgeConstraints: Bool?

        // MARK: neato, fdp, sfdp

        ///**
        // Set the number of dimensions used for rendering. The maximum value allowed is 10. If both dimen and dim are set, the latter specifies the dimension used for layout, and the former for rendering. If only dimen is set, this is used for both layout and rendering dimensions.
        // Note that, at present, all aspects of rendering are 2D. This includes the shape and size of nodes, overlap removal, and edge routing. Thus, for dimen > 2, the only valid information is the pos attribute of the nodes. All other coordinates will be 2D and, at best, will reflect a projection of a higher-dimensional point onto the plane.
        //
        // > dimen     int    2    2    sfdp, fdp, neato only
        // */
        @Attribute("dimen")
        public var renderingDimensions: Int?

        /**
         Set the number of dimensions used for the layout. The maximum value allowed is 10.

         > dim     int    2    2    sfdp, fdp, neato only
         */
        @Attribute("dim")
        public var layoutDimensions: Int?

        /**
         Specifies strictness of level constraints in neato when mode="ipsep" or "hier". Larger positive values mean stricter constraints, which demand more separation between levels. On the other hand, negative values will relax the constraints by allowing some overlap between the levels.
         */
        @Attribute("levelsgap")
        public var levelConstraintStrictness: Double?

        // MARK: neato, fdp

        /**
         start
         Parameter used to determine the initial layout of nodes. If unset, the nodes are randomly placed in a unit square with the same seed is always used for the random number generator, so the initial placement is repeatable.
         > start    G    startType    ""        fdp, neato only
         */
        @Attribute("start")
        public var initialNodeLayoutStrategy: InitialNodeLayoutStrategy?

        /**
         maxiter
         Sets the number of iterations used.
         int    100 * # nodes(mode == KK)
         200(mode == major)
         600(fdp)        fdp, neato only
         */
        @Attribute("maxiter")
        public var maximumNumberOfLayoutIterations: Int?

        /**
         inputscale
         For layout algorithms that support initial input positions (specified by the pos attribute), this attribute can be used to appropriately scale the values. By default, fdp and neato interpret the x and y values of pos as being in inches. (NOTE: neato -n(2) treats the coordinates as being in points, being the unit used by the layout algorithms for the pos attribute.) Thus, if the graph has pos attributes in points, one should set inputscale=72. This can also be set on the command line using the -s flag flag.
         If not set, no scaling is done and the units on input are treated as inches. A value of 0 is equivalent to inputscale=72.
         > G    double    <none>        fdp, neato only
         */
        @Attribute("inputscale")
        public var inputScale: Double?

        /**
         Factor damping force motions. On each iteration, a nodes movement is limited to this factor of its potential motion. By being less than 1.0, the system tends to ``cool'', thereby preventing cycling.
         */
        @Attribute("Damping")
        public var damping: Double?

        // MARK: sfdp

        /**
         label_scheme
         The value indicates whether to treat a node whose name has the form |edgelabel|* as a special node representing an edge label. The default (0) produces no effect. If the attribute is set to 1, sfdp uses a penalty-based method to make that kind of node close to the center of its neighbor. With a value of 2, sfdp uses a penalty-based method to make that kind of node close to the old center of its neighbor. Finally, a value of 3 invokes a two-step process of overlap removal and straightening.

         >     int    0    0    sfdp only

         */
        @Attribute("label_scheme")
        public var labelScheme: LabelScheme?

        /**
         Quadtree scheme to use.
         A TRUE bool value corresponds to "normal"; a FALSE bool value corresponds to "none". As a slight exception to the normal interpretation of bool, a value of "2" corresponds to "fast".

         G    quadType
         bool    normal        sfdp only
         */
        @Attribute("quadtree")
        public var quadtreeScheme: QuadtreeScheme?

        /**
         repulsiveforce
         The power of the repulsive force used in an extended Fruchterman-Reingold force directed model. Values larger than 1 tend to reduce the warping effect at the expense of less clustering.
         >     G    double    1.0    0.0    sfdp only
         */
        @Attribute("repulsiveforce")
        public var repulsiveForce: Double?

        /**
         smoothing
         Specifies a post-processing step used to smooth out an uneven distribution of nodes.
         >     G    smoothType    "none"        sfdp only
         */
        @Attribute("smoothing")
        public var smoothing: Smoothing?

        /**
         Number of levels allowed in the multilevel scheme.
         > levels    G    int    MAXINT    0.0    sfdp only
         */
        @Attribute("levels")
        public var numberOfLevels: Int?

        // MARK: sfdp, fdp

        /**
         Spring constant used in virtual physical model. It roughly corresponds to an ideal edge length (in inches), in that increasing K tends to increase the distance between nodes. Note that the edge attribute len can be used to override this value for adjacent nodes.
         K    GC    double    0.3    0    sfdp, fdp only
         */
        @Attribute("K")
        public var springConstant: Double?

        // MARK: prism

        /**
         overlap_scaling
         When overlap=prism, the layout is scaled by this factor, thereby removing a fair amount of node overlap, and making node overlap removal faster and better able to retain the graph's shape.
         If overlap_scaling is negative, the layout is scaled by -1*overlap_scaling times the average label size. If overlap_scaling is positive, the layout is scaled by overlap_scaling. If overlap_scaling is zero, no scaling is done.
         overlap_scaling    G    double    -4    -1.0e10    prism only
         */
        @Attribute("overlap_scaling")
        public var overlapScaling: Double?

        /**
         overlap_shrink
         If true, the overlap removal algorithm will perform a compression pass to reduce the size of the layout.
         overlap_shrink    G    bool    true        prism only
         */
        @Attribute("overlap_shrink")
        public var overlapShrink: Bool?

        // MARK: circo

        /**
         mindist
         Specifies the minimum separation between all nodes.
         > G    double    1.0    0.0    circo only
         */
        @Attribute("mindist")
        public var minimumNodeSeparation: Double?

        // MARK: - Output-specific Attributes

        /// This specifies the expected number of pixels per inch on a display device. For bitmap output, this guarantees that text rendering will be done more accurately, both in size and in placement. For SVG output, it is used to guarantee that the dimensions in the output correspond to the correct number of points or inches.

        @Attribute("resolution")
        var resolution: Double?

        /**
         Directory list used by libgd to search for bitmap fonts if Graphviz was not built with the fontconfig library. If fontpath is not set, the environment variable DOTFONTPATH is checked. If that is not set, GDFONTPATH is checked. If not set, libgd uses its compiled-in font path. Note that fontpath is an attribute of the root graph.
         */
        @Attribute("fontpath")
        public var fontPath: URL?


        /**
         Allows user control of how basic fontnames are represented in SVG output. If fontnames is undefined or "svg", the output will try to use known SVG fontnames. For example, the default font "Times-Roman" will be mapped to the basic SVG font "serif". This can be overridden by setting fontnames to "ps" or "gd". In the former case, known PostScript font names such as "Times-Roman" will be used in the output. In the latter case, the fontconfig font conventions are used. Thus, "Times-Roman" would be treated as "Nimbus Roman No9 L". These last two options are useful with SVG viewers that support these richer fontname spaces.
         > SVG only
         */
        @Attribute("fontnames")
        public var fontNamingConvention: FontNamingConvention?

        /**
         A URL or pathname specifying an XML style sheet, used in SVG output.
         G    string    ""        svg only
         */
        @Attribute("stylesheet")
        public var stylesheetURL: URL?

        /**
         Specifies a list of directories in which to look for image files as specified by the image attribute or using the IMG element in HTML-like labels. The string should be a list of (absolute or relative) pathnames, each separated by a semicolon (for Windows) or a colon (all other OS). The first directory in which a file of the given name is found will be used to load the image. If imagepath is not set, relative pathnames for the image file will be interpreted with respect to the current working directory.
         */
        @Attribute("imagepath")
        public var imagePath: URL?

        /**
         If set explicitly to true or false, the value determines whether or not internal bitmap rendering relies on a truecolor color model or uses a color palette. If the attribute is unset, truecolor is not used unless there is a shapefile property for some node in the graph. The output model will use the input model when possible.
         Use of color palettes results in less memory usage during creation of the bitmaps and smaller output files.

         Usually, the only time it is necessary to specify the truecolor model is if the graph uses more than 256 colors. However, if one uses bgcolor=transparent with a color palette, font antialiasing can show up as a fuzzy white area around characters. Using truecolor=true avoids this problem.
         > truecolor    G    bool            bitmap output only
         */
        @Attribute("truecolor")
        public var trueColor: Bool?
    }
}

extension Graph.Attributes {
    var arrayValue: [Attributable] {
        return [
            _aspectRatio,
            _backgroundColor,
            _boundingBox,
            _center,
            _class,
            _clusterRank,
            _comment,
            _compound,
            _concentrate,
            _damping,
            _defaultDistance,
            _epsilon,
            _fontName,
            _fontNamingConvention,
            _fontPath,
            _fontSize,
            _forceLabels,
            _generateDirectedEdgeConstraints,
            _guideBoxLocation,
            _href,
            _imagePath,
            _initialNodeLayoutStrategy,
            _inputScale,
            _label,
            _labelDimensionUnit,
            _labelScheme,
            _layoutAlgorithm,
            _layoutDimensions,
            _levelConstraintStrictness,
            _margin,
            _maximumNetworkSimplexIterationsForComputingNodeCoordinates,
            _maximumNetworkSimplexIterationsForRankingNodes,
            _maximumNumberOfLayoutIterations,
            _minimumNodeSeparation,
            _minimumScaleFactor,
            _mode,
            _model,
            _noJustify,
            _noTranslate,
            _nodeSeparation,
            _normalize,
            _numberOfLevels,
            _ordering,
            _orientation,
            _outputOrder,
            _overlap,
            _overlapScaling,
            _overlapShrink,
            _pageDirection,
            _pageSize,
            _quadtreeScheme,
            _rankDirection,
            _rankSeparation,
            _renderingDimensions,
            _repulsiveForce,
            _resolution,
            _rotation,
            _runCrossingMinimizationOnce,
            _scale,
            _searchSize,
            _smoothing,
            _sortValue,
            _splines,
            _springConstant,
            _stylesheetURL,
            _textColor,
            _trueColor,
            _url,
            _useMOSEK,
            _useNewRankingAlgorithm,
            _viewport,
            _voronoiMargin
        ]
    }

    public var dictionaryValue: [String: Any] {
        return Dictionary(uniqueKeysWithValues: arrayValue.map { ($0.name, $0.typeErasedWrappedValue) }
        ).compactMapValues { $0 }
    }
}
