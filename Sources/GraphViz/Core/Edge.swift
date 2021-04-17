import struct Foundation.URL

/// An edge between two nodes.
@dynamicMemberLookup
public struct Edge: Hashable {
    public var from: Node.ID
    public var to: Node.ID

    public enum Direction: String, Hashable {
        case none = "--"
        case forward = "->"
        case backward = "<-"
        case both = "<->"
    }

    /// > Sets the edge type for drawing arrowheads (not for ranking purposes).
    public var direction: Direction?

    public var attributes: Attributes = .init()

    public init(from: Node, to: Node, direction: Direction? = nil) {
        self.init(from: from.id, to: to.id, direction: direction)
    }

    public init(from: Node.ID, to: Node.ID, direction: Direction? = nil) {
        self.from = from
        self.to = to
        self.direction = direction
    }

    public subscript<T>(dynamicMember member: WritableKeyPath<Edge.Attributes, T>) -> T {
        get {
            return attributes[keyPath: member]
        }

        set {
            attributes[keyPath: member] = newValue
        }
    }
}

// MARK: - Attributes

extension Edge {
    /// > https://www.graphviz.org/doc/info/arrows.html
    public struct Arrow: Hashable {
        public enum Shape: String {
            case none
            case normal
            case box
            case crow
            case curve
            case icurve
            case diamond
            case dot
            case inv
            case tee
            case vee
        }

        public enum Side: String {
            case left = "l"
            case right = "r"
        }

        public var shape: Shape?
        public var open: Bool?
        public var side: Side?
    }

    public enum Port: String {
        case automatic = "_"
        case center = "c"
        case north = "n"
        case northEast = "ne"
        case east = "e"
        case southEast = "se"
        case south = "s"
        case southWest = "sw"
        case west = "w"
        case northWest = "nw"
    }

    public enum Style: String, Hashable {
        case solid
        case dashed
        case dotted
        case bold
    }

    public struct Attributes: Hashable {
        /// Comments are inserted into output. Device-dependent
        @Attribute("comment")
        public var comment: String?

        /// Unofficial, but supported by certain output formats, like svg.
        @Attribute("class")
        public var `class`: String?

        /**
         If false, the edge is not used in ranking the nodes.

         Normally, edges are used to place the nodes on ranks. In the second graph below, all nodes were placed on different ranks. In the first example, the edge b -> c does not add a constraint during rank assignment, so the only constraints are that a be above b and c.

         If false, the edge is not used in ranking the nodes. For example, in the graph
         digraph G {
         a -> c;
         a -> b;
         b -> c [constraint=false];
         }

         the edge b -> c does not add a constraint during rank assignment, so the only constraints are that a be above b and c, yielding the graph:
         */
        @Attribute("constraint")
        public var constraint: Bool?

        /**
         If the value of the attribute is "out", then the outedges of a node, that is, edges with the node as its tail node, must appear left-to-right in the same order in which they are defined in the input. If the value of the attribute is "in", then the inedges of a node must appear left-to-right in the same order in which they are defined in the input. If defined as a graph or subgraph attribute, the value is applied to all nodes in the graph or subgraph. Note that the graph attribute takes precedence over the node attribute.
         */
        @Attribute("ordering")
        public var ordering: Ordering?

        /**
         Weight of edge. In dot, the heavier the weight, the shorter, straighter and more vertical the edge is. N.B. Weights in dot must be integers. For twopi, a weight of 0 indicates the edge should not be used in constructing a spanning tree from the root. For other layouts, a larger weight encourages the layout to make the edge length closer to that specified by the len attribute.

         weight    E    int
         double    1    0(dot,twopi)
         1(neato,fdp)
         */
        @Attribute("weight")
        public var weight: Double?

        // MARK: - Drawing Attributes


        /**
         Set style information for components of the graph. For cluster subgraphs, if style="filled", the cluster box's background is filled.
         If the default style attribute has been set for a component, an individual component can use style="" to revert to the normal default. For example, if the graph has

         edge [style="invis"]

         making all edges invisible, a specific edge can overrride this via:

         a -> b [style=""]

         Of course, the component can also explicitly set its style attribute to the desired value.
         */
        @Attribute("style")
        public var style: Style?

        /// > Basic drawing color for graphics.
        @Attribute("color")
        public var strokeColor: Color?

        /**
         penwidth
         Specifies the width of the pen, in points, used to draw lines and curves, including the boundaries of edges and clusters. The value is inherited by subclusters. It has no effect on text.
         */
        @Attribute("penwidth")
        public var strokeWidth: Double?

        /// Multiplicative scale factor for arrowheads.
        @Attribute("arrowsize")
        public var arrowSize: Double?


        // MARK: - Label Attributes

        /// > The name of the used font. (System dependend)
        /// > The font size for object labels.
        @Attribute("fontname")
        public var fontName: String?

        @Attribute("fontsize")
        public var fontSize: Double?

        /// > The font color for object labels.
        @Attribute("fontcolor")
        public var textColor: Color?

        @Attribute("labelURL")
        public var labelURL: URL?

        /**
         labeldistance
         Multiplicative scaling factor adjusting the distance that the headlabel(taillabel) is from the head(tail) node. The default distance is 10 points. See labelangle for more details.
         */
        @Attribute("labeldistance")
        public var labelDistance: Double?

        /**
         This, along with labeldistance, determine where the headlabel (taillabel) are placed with respect to the head (tail) in polar coordinates. The origin in the coordinate system is the point where the edge touches the node. The ray of 0 degrees goes from the origin back along the edge, parallel to the edge at the origin.
         The angle, in degrees, specifies the rotation from the 0 degree ray, with positive angles moving counterclockwise and negative angles moving clockwise.
         */
        @Attribute("labelangle")
        public var labelAngle: Double?

        //        /// Specifies a linearly ordered list of layer names attached to the graph The graph is then output in separate layers. Only those components belonging to the current output layer appear. For more information, see the page How to use drawing layers (overlays).
        //        /// http://graphviz.org/faq/#FaqOverlays
        //        var layers: [String]?

        /// Width of graph or cluster label, in inches.

        @Attribute("labelwidth")
        public var labelWidth: Double?

        //        /// Height of graph or cluster label, in inches.
        //        @Attribute("labelheight")
        //        public var labelHeight: Double?
        //



        /// > If true, allows edge labels to be less constrained in position. In particular, it may appear on top of other edges
        @Attribute("labelfloat")
        public var labelFloat: Bool?

        /**
         External label for a node or edge. For nodes, the label will be placed outside of the node but near it. For edges, the label will be placed near the center of the edge. This can be useful in dot to avoid the occasional problem when the use of edge labels distorts the layout. For other layouts, the xlabel attribute can be viewed as a synonym for the label attribute.
         These labels are added after all nodes and edges have been placed. The labels will be placed so that they do not overlap any node or label. This means it may not be possible to place all of them. To force placing all of them, use the forcelabels attribute.
         */
        @Attribute("xlabel")
        public var exteriorLabel: String?

        /**
         Position of an exterior label, in points. The position indicates the center of the label.
         */
        @Attribute("xlp")
        public var exteriorLabelPosition: Point?

        /**
         If true, attach edge label to edge by a 2-segment polyline, underlining the label, then going to the closest point of spline.
         */
        @Attribute("decorate")
        public var decorate: Bool?

        /**
         By default, the justification of multi-line labels is done within the largest context that makes sense. Thus, in the label of a polygonal node, a left-justified line will align with the left side of the node (shifted by the prescribed margin). In record nodes, left-justified line will line up with the left side of the enclosing column of fields. If nojustify is "true", multi-line labels will be justified in the context of itself. For example, if the attribute is set, the first label line is long, and the second is shorter and left-justified, the second will align with the left-most character in the first line, regardless of how large the node might be.
         */
        @Attribute("nojustify")
        public var noJustify: Bool?

        // MARK: - Link Attributes

        ///
        @Attribute("href")
        public var href: String?

        ///
        @Attribute("URL")
        public var url: URL?

        /// Tooltip annotation attached to the non-label part of an edge. This is used only if the edge has a URL or edgeURL attribute.
        /// > E    escString    ""        svg, cmap only
        @Attribute("tooltip")
        public var tooltip: String?

        // MARK: - Head Attributes

        @Attribute("arrowhead")
        public var head: Arrow?

        /**
         Indicates where on the head node to attach the head of the edge. In the default case, the edge is aimed towards the center of the node, and then clipped at the node boundary. See limitation.

         */
        @Attribute("headport")
        public var headPort: Port?

        @Attribute("headlabel")
        public var headLabel: String?

        /// Position of an edge's head label, in points. The position indicates the center of the label.
        @Attribute("head_lp")
        public var headLabelPosition: Point?

        /**
         If true, the head of an edge is clipped to the boundary of the head node; otherwise, the end of the edge goes to the center of the node, or the center of a port, if applicable.
         */
        @Attribute("headclip")
        public var headClip: Bool?

        @Attribute("headURL")
        public var headURL: URL?

        /**
         If the edge has a headURL, this attribute determines which window of the browser is used for the URL. Setting it to "_graphviz" will open a new window if it doesn't already exist, or reuse it if it does. If undefined, the value of the target is used.
         */
        @Attribute("headtarget")
        public var headTarget: String?

        /// Tooltip annotation attached to the head of an edge. This is used only if the edge has a headURL attribute.
        @Attribute("headtooltip")
        public var headTooltip: String?

        /**
         Logical head of an edge. When compound is true, if lhead is defined and is the name of a cluster containing the real head, the edge is clipped to the boundary of the cluster. See limitation.
         */
        @Attribute("lhead")
        public var logicalHead: String?


        /**
         Edges with the same head and the same samehead value are aimed at the same point on the head. This has no effect on loops. Each node can have at most 5 unique samehead values. See limitation.
         >     dot only
         */
        @Attribute("samehead")
        public var sameHead: String?

        // MARK: - Tail Attributes

        /**
         - SeeAlso: head
         */
        @Attribute("arrowtail")
        public var tail: Arrow?

        /**
         If true, the tail of an edge is clipped to the boundary of the tail node; otherwise, the end of the edge goes to the center of the node, or the center of a port, if applicable.

         - SeeAlso: headClip
         */
        @Attribute("tailclip")
        public var tailClip: Bool?

        /**
         - SeeAlso: headURL
         */
        @Attribute("tailURL")
        public var tailURL: URL?

        /**
         If the edge has a tailURL, this attribute determines which window of the browser is used for the URL. Setting it to "_graphviz" will open a new window if it doesn't already exist, or reuse it if it does. If undefined, the value of the target is used.

         - SeeAlso: headTarget
         */
        @Attribute("tailtarget")
        public var tailTarget: String?

        /**
         - SeeAlso: headTooltip
         */
        @Attribute("tailtooltip")
        public var tailTooltip: String?

        /**
         Logical tail of an edge. When compound is true, if ltail is defined and is the name of a cluster containing the real head, the edge is clipped to the boundary of the cluster. See limitation.
         */
        @Attribute("ltail")
        public var logicalTail: String?

        /**
         Edges with the same tail and the same sametail value are aimed at the same point on the tail. This has no effect on loops. Each node can have at most 5 unique sametail values. See limitation.
         >     dot only

         - SeeAlso: sameHead
         */
        @Attribute("sametail")
        public var sameTail: String?

        @Attribute("taillabel")
        public var tailLabel: String?


        // MARK: - Layout-specific Attributes

        // MARK: DOT Only

        /**
         minlen
         Minimum edge length (rank difference between head and tail).

         > E    int    1    0    dot only
         */
        @Attribute("minlen")
        public var minimumRankDifference: Int?

        /**
         showboxes
         Print guide boxes in PostScript at the beginning of routesplines if 1, or at the end if 2. (Debugging)
         >     ENG    int    0    0    dot only
         */
        @Attribute("showboxes")
        public var guideBoxLocation: Location?

        // MARK: FDP, neato

        /**
          len
          Preferred edge length, in inches.
          */
         @Attribute("len")
         public var preferredEdgeLength: Double?
    }
}

extension Edge.Attributes {
    var arrayValue: [Attributable] {
        return [
            _comment,
            _class,
            _constraint,
            _ordering,
            _weight,
            _style,
            _strokeColor,
            _strokeWidth,
            _arrowSize,
            _fontName,
            _fontSize,
            _textColor,
            _labelURL,
            _labelDistance,
            _labelAngle,
            _labelWidth,
            _labelFloat,
            _exteriorLabel,
            _exteriorLabelPosition,
            _decorate,
            _href,
            _url,
            _noJustify,
            _tooltip,
            _head,
            _headPort,
            _headLabel,
            _headLabelPosition,
            _headClip,
            _headURL,
            _headTarget,
            _headTooltip,
            _logicalHead,
            _sameHead,
            _tail,
            _tailClip,
            _tailURL,
            _tailTarget,
            _tailTooltip,
            _logicalTail,
            _sameTail,
            _tailLabel,
            _minimumRankDifference,
            _guideBoxLocation,
            _preferredEdgeLength
        ]
    }

    public var dictionaryValue: [String: Any] {
        return Dictionary(uniqueKeysWithValues: arrayValue.map { ($0.name, $0.typeErasedWrappedValue) }
        ).compactMapValues { $0 }
    }
}
