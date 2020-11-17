# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2020-11-17

### Added

- Added support for `style` and `fillcolor` attributes.
  #11 by @mattt and @fwcd.
- Added a `Renderer` class that can render DOT-encoded strings directly.
  #5 by @fwcd and @mattt.

### Removed

- Removed support for Swift 5.1.
  #10 by @mattt.

## [0.1.3] - 2020-07-20

### Changed

- Changed `Edge.strokeColor` property
  to use `'color'` attribute instead of `'pencolor'`.
  #4 by @fwcd.

## [0.1.2] - 2020-07-15

### Fixed

- Fixed runtime issue in Ubuntu Linux.
  #2 by @JaapWijnen.

## [0.1.1] - 2020-03-27

### Added

- Added undocumented, but supported DOT attribute `'class'` to all types.
- Added `width`, `height`, and `fixedSize` attributes to `Node`

### Fixed

- Fixed encoder to escape DOT language keywords.

### Changed

- Changed `overlap` attribute to use `String` type.
- Changed `AspectRatio.custom` case, renaming to `.numeric`.
- Changed `AspectRatio` to implement `DOTRepresentable`.
- Changed `preferredEdgelength` property, moving it from `Graph` to `Edge`.

## [0.1.0] - 2020-03-27

### Added

- Added `href` attributes to all types.

### Fixed

- Fixed how DOT ids and attributes are quoted.
- Fixed error: `argument type 'String' does not conform to expected type 'CVarArg'`

### Changed

- Changed determination of path to `dot` executable to use `which`.
- Changed `Graph.PackingMode` to implement `DOTRepresentable`.
- Changed `Graph.InitialNodeLayoutStrategy` to implement `DOTRepresentable`.
- Changed `Subgraph.Style` to implement `DOTRepresentable`.
- Changed `Node.Style` to implement `DOTRepresentable`.

## [0.0.4] - 2020-03-16

- Added `URL` attribute to all types.

## [0.0.3] - 2020-03-14

### Added

- Added `append(contentsOf:)` methods to `Graph`.
- Added `isEmpty` properties to `Graph` and `Subgraph`.
- Added `.custom` case to `Color`.

### Changed

- Changed `import` of `DOT` to be exported to `GraphViz` module.

## [0.0.2] - 2020-03-11

### Added

- Added `statementDelimiter` and `attributeDelimiter` properties to `DOTEncoder`.
- Added static `encode` method to `DOTEncoder`.
- Added `omitEmptyNodes` property to `DOTEncoder`.
- Added link to DOT language reference.

## [0.0.1] - 2020-03-09

Initial release.

[unreleased]: https://github.com/SwiftDocOrg/GraphViz/compare/0.2.0...master
[0.2.0]: https://github.com/SwiftDocOrg/GraphViz/releases/tag/0.2.0
[0.1.3]: https://github.com/SwiftDocOrg/GraphViz/releases/tag/0.1.3
[0.1.2]: https://github.com/SwiftDocOrg/GraphViz/releases/tag/0.1.2
[0.1.1]: https://github.com/SwiftDocOrg/GraphViz/releases/tag/0.1.1
[0.1.0]: https://github.com/SwiftDocOrg/GraphViz/releases/tag/0.1.0
[0.0.4]: https://github.com/SwiftDocOrg/GraphViz/releases/tag/0.0.4
[0.0.3]: https://github.com/SwiftDocOrg/GraphViz/releases/tag/0.0.3
[0.0.2]: https://github.com/SwiftDocOrg/GraphViz/releases/tag/0.0.2
[0.0.1]: https://github.com/SwiftDocOrg/GraphViz/releases/tag/0.0.1
