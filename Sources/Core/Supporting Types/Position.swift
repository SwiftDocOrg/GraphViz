public enum Position: Hashable {
    /// "%f,%f('!')?" representing the point (x,y). The optional '!' indicates the node position should not change (input-only).
    /// If dim is 3, point may also have the format "%f,%f,%f('!')?" to represent the point (x,y,z).
    case point(point: Point)

    /**
     spline ( ';' spline )*
     where spline    =    (endp)? (startp)? point (triple)+
     and triple    =    point point point
     and endp    =    "e,%f,%f"
     and startp    =    "s,%f,%f"
     If a spline has points p1 p2 p3 ... pn, (n = 1 (mod 3)), the points correspond to the control points of a cubic B-spline from p1 to pn. If startp is given, it touches one node of the edge, and the arrowhead goes from p1 to startp. If startp is not given, p1 touches a node. Similarly for pn and endp.
     */
    case spline(points: [Point])
}
