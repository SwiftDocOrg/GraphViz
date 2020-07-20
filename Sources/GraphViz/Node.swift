import struct Foundation.URL

/**
 A single node of the graph.

 If a node appears inside a record, it has only the both attributes id and label.
 */
@dynamicMemberLookup
public struct Node: Identifiable, Hashable {
    /**
     > A unique identifier for a node or a cluster.

     Node ids are referenced by the edge attributes from and to, cluster ids by ltail and lhead.

     If for a node the attribute label is not defined, the value of the attribute is used.

     Strings [A-Z,a-z,0-9,.,_]+
     */
    public var id: String

    public init(_ id: String) {
        self.id = id
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

// MARK: -

extension Node {
    public enum Shape: String, Hashable {
        case box, circle, ellipse, point, egg, triangle, plaintext, diamond, trapezium, parallelogram, house, hexagon, octagon, doublecircle, doubleoctagon, invtriangle, invtrapezium, invhouse, Mdiamond, Msquare, Mcircle
    }

    public enum ImagePosition: String {
        case topLeft = "tl"
        case topCenter = "tc"
        case topRight = "tr"
        case middleLeft = "ml"
        case middleCenter = "mc"
        case middleRight = "mr"
        case bottomLeft = "bl"
        case bottomCenter = "bc"
        case botttomRight = "br"
    }

    public enum FixedSize: String, Hashable, ExpressibleByBooleanLiteral {
        case `false`
        case `true`
        case shape

        public init(booleanLiteral value: BooleanLiteralType) {
            self = value ? .true : .false
        }
    }

    public enum Style: Hashable {
        case solid
        case dashed
        case dotted
        case bold
        case rounded
        case diagonals
        case filled
        case striped
        case wedged
        case compound([Style])
    }

    public struct Attributes: Hashable {
        /// Comments are inserted into output. Device-dependent
        @Attribute("comment")
        public var comment: String?

        /// Unofficial, but supported by certain output formats, like svg.
        @Attribute("class")
        public var `class`: String?

        /**
         If the value of the attribute is "out", then the outedges of a node, that is, edges with the node as its tail node, must appear left-to-right in the same order in which they are defined in the input. If the value of the attribute is "in", then the inedges of a node must appear left-to-right in the same order in which they are defined in the input. If defined as a graph or subgraph attribute, the value is applied to all nodes in the graph or subgraph. Note that the graph attribute takes precedence over the node attribute.
         */
        @Attribute("ordering")
        public var ordering: Ordering?


        /**
         If packmode indicates an array packing, this attribute specifies an insertion order among the components, with smaller values inserted first.
         > GCN    int    0    0
         */
        @Attribute("sortvalue")
        public var sortValue: Int?

        // MARK: - Drawing Attributes

        /**
         Width of node, in inches. This is taken as the initial, minimum width of the node. If fixedsize is true, this will be the final width of the node. Otherwise, if the node label requires more width to fit, the node's width will be increased to contain the label. Note also that, if the output format is dot, the value given to width will be the final value.

         If the node shape is regular, the width and height are made identical. In this case, if either the width or the height is set explicitly, that value is used. In this case, if both the width or the height are set explicitly, the maximum of the two values is used. If neither is set explicitly, the minimum of the two default values is used.
         */
        @Attribute("width")
        public var width: Double?

        /**
         Height of node, in inches. This is taken as the initial, minimum height of the node. If fixedsize is true, this will be the final height of the node. Otherwise, if the node label requires more height to fit, the node's height will be increased to contain the label. Note also that, if the output format is dot, the value given to height will be the final value.

         If the node shape is regular, the width and height are made identical. In this case, if either the width or the height is set explicitly, that value is used. In this case, if both the width or the height are set explicitly, the maximum of the two values is used. If neither is set explicitly, the minimum of the two default values is used.
         */
        @Attribute("height")
        public var height: Double?

        /**
         The node size set by height and width is kept fixed and not expanded to contain the text label.

         If false, the size of a node is determined by smallest width and height needed to contain its label and image, if any, with a margin specified by the margin attribute. The width and height must also be at least as large as the sizes specified by the width and height attributes, which specify the minimum values for these parameters.

         If true, the node size is specified by the values of the width and height attributes only and is not expanded to contain the text label. There will be a warning if the label (with margin) cannot fit within these limits.

         If the fixedsize attribute is set to shape, the width and height attributes also determine the size of the node shape, but the label can be much larger. Both the label and shape sizes are used when avoiding node overlap, but all edges to the node ignore the label and only contact the node shape. No warning is given if the label is too larg
         */
        @Attribute("fixedsize")
        public var fixedSize: FixedSize?

        /// > The shape of a node.
        @Attribute("shape")
        public var shape: Shape?

        /// > Defines the graphic style on an object.
        @Attribute("style")
        public var style: Style?

        /// > When attached to the root graph, this color is used as the background for entire canvas. For a cluster, it is used as the initial background for the cluster. If a cluster has a filled style, the cluster's fillcolor will overlay the background color.
        @Attribute("bgcolor")
        public var backgroundColor: Color?

        /// > Basic drawing color for graphics.
        @Attribute("color")
        public var strokeColor: Color?

        /**
         penwidth
         Specifies the width of the pen, in points, used to draw lines and curves, including the boundaries of edges and clusters. The value is inherited by subclusters. It has no effect on text.
         */
        @Attribute("penwidth")
        public var strokeWidth: Double?

        /// - Important: Setting fillColor sets `style` to .filled;
        ///              setting `nil` fillColor sets `style` to `nil`
        @Attribute("fillcolor")
        public var fillColor: Color? {
            willSet {
                style = newValue.map { _ in .filled }
            }
        }

        //        /// Specifies a linearly ordered list of layer names attached to the graph The graph is then output in separate layers. Only those components belonging to the current output layer appear. For more information, see the page How to use drawing layers (overlays).
        //        /// http://graphviz.org/faq/#FaqOverlays
        //        var layers: [String]?

        /**
         Gives the name of a file containing an image to be displayed inside a node. The image file must be in one of the recognized formats, typically JPEG, PNG, GIF, BMP, SVG or Postscript, and be able to be converted into the desired output format.
         The file must contain the image size information. This is usually trivially true for the bitmap formats. For PostScript, the file must contain a line starting with %%BoundingBox: followed by four integers specifying the lower left x and y coordinates and the upper right x and y coordinates of the bounding box for the image, the coordinates being in points. An SVG image file must contain width and height attributes, typically as part of the svg element. The values for these should have the form of a floating point number, followed by optional units, e.g., width="76pt". Recognized units are in, px, pc, pt, cm and mm for inches, pixels, picas, points, centimeters and millimeters, respectively. The default unit is points.

         Unlike with the shapefile attribute, the image is treated as node content rather than the entire node. In particular, an image can be contained in a node of any shape, not just a rectangle.
         */
        @Attribute("imagepath")
        public var imageURL: URL?

        /**
         Attribute controlling how an image is positioned within its containing node. This only has an effect when the image is smaller than the containing node. The default is to be centered both horizontally and vertically. Valid values:
         tl    Top Left
         tc    Top Centered
         tr    Top Right
         ml    Middle Left
         mc    Middle Centered (the default)
         mr    Middle Right
         bl    Bottom Left
         bc    Bottom Centered
         br    Bottom Right
         */
        @Attribute("imagepos")
        public var imagePosition: ImagePosition?

        // MARK: - Link Attributes

        ///
        @Attribute("href")
        public var href: String?

        ///
        @Attribute("URL")
        public var url: URL?

        // MARK: - Label Attributes

        @Attribute("label")
        public var label: String?

        /// > The name of the used font. (System dependend)
        /// > The font size for object labels.
        @Attribute("fontname")
        public var fontName: String?

        @Attribute("fontsize")
        public var fontSize: Double?

        /// > The font color for object labels.
        @Attribute("fontcolor")
        public var textColor: Color?


        /**
         By default, the justification of multi-line labels is done within the largest context that makes sense. Thus, in the label of a polygonal node, a left-justified line will align with the left side of the node (shifted by the prescribed margin). In record nodes, left-justified line will line up with the left side of the enclosing column of fields. If nojustify is "true", multi-line labels will be justified in the context of itself. For example, if the attribute is set, the first label line is long, and the second is shorter and left-justified, the second will align with the left-most character in the first line, regardless of how large the node might be.
         */
        @Attribute("nojustify")
        public var noJustify: Bool?

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

        //        /**
        //         Set number of peripheries used in polygonal shapes and cluster boundaries. Note that user-defined shapes are treated as a form of box shape, so the default peripheries value is 1 and the user-defined shape will be drawn in a bounding rectangle. Setting peripheries=0 will turn this off. Also, 1 is the maximum peripheries value for clusters.
        //         > NC    int    shape default(nodes)
        //         1(clusters)    0
        //         */
        //        @Attribute("peripheries")
        //        public var peripheries: Int?



        // TODO:
        //        /**
        //         Rectangles for fields of records, in points.
        //
        //         */
        //        public var recordFieldRectangles: [Point]?

        //        /**
        //         regular
        //         If true, force polygon to be regular, i.e., the vertices of the polygon will lie on a circle whose center is the center of the node.
        //         */
        //        @Attribute("regular")
        //        public var regular: Bool?



        //        /**
        //         If the input graph defines this attribute, the node is polygonal, and output is dot or xdot, this attribute provides the coordinates of the vertices of the node's polygon, in inches. If the node is an ellipse or circle, the samplepoints attribute affects the output.
        //         >     N    pointList            write only
        //         */
        //        public var verticies: [Point]?



        // MARK: - Layout-specific Attributes

        // MARK: dot

        /**
         If the end points of an edge belong to the same group, i.e., have the same group attribute, parameters are set to avoid crossings and keep the edges straight.
         >     N    string    ""        dot only
         */
        @Attribute("group")
        public var group: String?

        /**
         showboxes
         Print guide boxes in PostScript at the beginning of routesplines if 1, or at the end if 2. (Debugging)
         >     ENG    int    0    0    dot only
         */
        @Attribute("showboxes")
        public var guideBoxLocation: Location?


        // MARK: dot / neato

        /**
         If the input graph defines the vertices attribute, and output is dot or xdot, this gives the number of points used for a node whose shape is a circle or ellipse. It plays the same role in neato, when adjusting the layout to avoid overlapping nodes, and in image maps.

         > samplepoints    N    int    8(output)
         20(overlap and image maps)
         */
        @Attribute("samplepoints")
        public var samplePoints: Int?

        // MARK: neato / fdp

        /**
         If true and the node has a pos attribute on input, neato or fdp prevents the node from moving from the input position. This property can also be specified in the pos attribute itself (cf. the point type).
         Note: Due to an artifact of the implementation, previous to 27 Feb 2014, final coordinates are translated to the origin. Thus, if you look at the output coordinates given in the (x)dot or plain format, pinned nodes will not have the same output coordinates as were given on input. If this is important, a simple workaround is to maintain the coordinates of a pinned node. The vector difference between the old and new coordinates will give the translation, which can then be subtracted from all of the appropriate coordinates.

         After 27 Feb 2014, this translation can be avoided in neato by setting the notranslate to TRUE. However, if the graph specifies node overlap removal or a change in aspect ratio, node coordinates may still change.

         >    N    bool    false        fdp, neato only
         */
        @Attribute("pin")
        public var pin: Bool?

        /**
         Position of node, or spline control points. For nodes, the position indicates the center of the node. On output, the coordinates are in points.
         In neato and fdp, pos can be used to set the initial position of a node. By default, the coordinates are assumed to be in inches. However, the -s command line flag can be used to specify different units. As the output coordinates are in points, feeding the output of a graph laid out by a Graphviz program into neato or fdp will almost always require the -s flag.

         When the -n command line flag is used with neato, it is assumed the positions have been set by one of the layout programs, and are therefore in points. Thus, neato -n can accept input correctly without requiring a -s flag and, in fact, ignores any such flag.
         */
        @Attribute("position")
        public var position: Position?

        // MARK: circo / twopi

        /**
         This specifies nodes to be used as the center of the layout and the root of the generated spanning tree. As a graph attribute, this gives the name of the node. As a node attribute, it specifies that the node should be used as a central node. In twopi, this will actually be the central node. In circo, the block containing the node will be central in the drawing of its connected component. If not defined, twopi will pick a most central node, and circo will pick a random node.
         If the root attribute is defined as the empty string, twopi will reset it to name of the node picked as the root node.

         For twopi, it is possible to have multiple roots, presumably one for each component. If more than one node in a component is marked as the root, twopi will pick one.
         > root    GN    string
         bool    <none>(graphs)
         false(nodes)        circo, twopi only
         */
        @Attribute("root")
        public var root: Bool?

        // MARK: patchwork

        /// Indicates the preferred area for a node or empty cluster when laid out by patchwork.
        /// 1.0    >0    patchwork only
        @Attribute("area")
        public var area: Double?
    }
}

extension Node.Attributes {
    var arrayValue: [Attributable] {
        return [
            _comment,
            _class,
            _ordering,
            _sortValue,
            _width,
            _height,
            _fillColor,
            _fixedSize,
            _shape,
            _style,
            _backgroundColor,
            _strokeColor,
            _strokeWidth,
            _imageURL,
            _imagePosition,
            _href,
            _url,
            _label,
            _fontName,
            _fontSize,
            _textColor,
            _noJustify,
            _exteriorLabel,
            _exteriorLabelPosition,
            _group,
            _guideBoxLocation,
            _samplePoints,
            _pin,
            _position,
            _root,
            _area
        ]
    }

    public var dictionaryValue: [String: Any] {
        return Dictionary(uniqueKeysWithValues: arrayValue.map { ($0.name, $0.typeErasedWrappedValue) }
        ).compactMapValues { $0 }
    }
}

// MARK: - ExpressibleByStringLiteral

extension Node: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}
