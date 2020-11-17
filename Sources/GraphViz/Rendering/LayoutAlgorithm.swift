public enum LayoutAlgorithm: String {
    /// dot draws directed graphs. It works well on DAGs and other graphs that can be drawn as hierarchies.
    case dot

    /// neato draws undirected graphs using ``spring'' models (see Kamada and Kawai, Information Processing Letters 31:1, April 1989).
    case neato

    /// twopi draws graphs using a radial layout (see G. Wills, Symposium on Graph Drawing GD'97, September, 1997). Basically, one node is chosen as the center and put at the origin. The remaining nodes are placed on a sequence of concentric circles centered about the origin, each a fixed radial distance from the previous circle. All nodes distance 1 from the center are placed on the first circle; all nodes distance 1 from a node on the first circle are placed on the second circle; and so forth.
    case twopi

    /// circo draws graphs using a circular layout (see Six and Tollis, GD '99 and ALENEX '99, and Kaufmann and Wiese, GD '02.) The tool identifies biconnected components and draws the nodes of the component on a circle. The block‐cutpoint tree is then laid out using a recursive radial algorithm. Edge crossings within a circle are minimized by placing as many edges on the circle's perimeter as possible. In particular, if the component is outerplanar, the component will have a planar layout.
    /// If a node belongs to multiple non‐trivial biconnected components, the layout puts the node in one of them. By default, this is the first non‐trivial component found in the search from the root component.
    case circo

    /// fdp draws undirected graphs using a ``spring'' model. It relies on a force‐directed approach in the spirit of Fruchterman and Reingold (cf. Software‐Practice & Experience 21(11), 1991, pp. 1129‐1164).
    case fdp

    /// sfdp also draws undirected graphs using the ``spring'' model described above, but it uses a multi-scale approach to produce layouts of large graphs in a reasonably short time.
    case sfdp

    /// patchwork draws the graph as a squarified treemap (see M. Bruls et al., "Squarified treemaps", Proc. Joint Eurographics and IEEE TCVG Symp. on Visualization, 2000, pp. 33-42). The clusters of the graph are used to specify the tree.
    case patchwork
}
