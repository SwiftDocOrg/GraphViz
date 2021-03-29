public enum Format: String, Hashable {
    /// Windows Bitmap Format
    case bmp

    /// Canon Image File Format (CIFF)
    case canon

    /// DOT
    case dot

    /// DOT
    case gv

    /// DOT
    case xdot

    /// DOT
    case xdot1_2 = "xdot1.2"

    /// DOT
    case xdot1_4 = "xdot1.4"

    /// CGImage bitmap format
    case cgimage

    /// Client-side imagemap (deprecated)
    case cmap

    /// Encapsulated PostScript
    case eps

    /// OpenEXR
    case exr

    /// FIG
    case fig

    /// GD
    case gd

    /// GD2
    case gd2

    /// GIF
    case gif

    /// GTK canvas
    case gtk

    /// Icon Image File Format
    case ico

    /// Server-side and client-side imagemaps
    case imap

    /// Server-side and client-side imagemaps
    case cmapx

    /// Server-side and client-side imagemaps
    case imap_np

    /// Server-side and client-side imagemaps
    case cmapx_np

    /// Server-side imagemap (deprecated)
    case ismap

    /// JPEG 2000
    case jp2

    /// JPEG
    case jpg

    /// JPEG
    case jpeg

    /// JPEG
    case jpe

    /// Dot graph represented in JSON format
    case json

    /// Dot graph represented in JSON format
    case json0

    /// Dot graph represented in JSON format
    case dot_json

    /// Dot graph represented in JSON format
    case xdot_json

    /// PICT
    case pct

    /// PICT
    case pict

    /// Portable Document Format (PDF)
    case pdf

    /// Kernighan's PIC graphics language
    case pic

    /// Text
    case plain

    /// Simple text format
    case plain_ext = "plain-ext"

    /// Portable Network Graphics format
    case png

    /// POV-Ray markup language (prototype)
    case pov

    /// PostScript
    case ps

    /// PostScript for PDF
    case ps2

    /// PSD
    case psd

    /// SGI
    case sgi

    /// Scalable Vector Graphics
    case svg

    /// Scalable Vector Graphics (Compressed)
    case svgz

    /// Truevision TGA
    case tga

    /// TIFF (Tag Image File Format)
    case tif

    /// TIFF (Tag Image File Format)
    case tiff

    /// TK graphics
    case tk

    /// Vector Markup Language (VML)
    case vml

    /// Vector Markup Language (VML)
    case vmlz

    /// VRML
    case vrml

    /// Wireless BitMap format
    case wbmp

    /// Image format for the Web
    case webp

    /// Xlib canvas
    case xlib

    /// Xlib canvas
    case x11
}
