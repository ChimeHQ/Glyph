<div align="center">

[![Build Status][build status badge]][build status]
[![Platforms][platforms badge]][platforms]
[![Documentation][documentation badge]][documentation]
[![Matrix][matrix badge]][matrix]

</div>

# Glyph
Make life with TextKit better

Glyph adds features and abstractions for working with TextKit. Some are for performance, some for convenience. You don't even need to know whether your system using 1 or 2. Glyph will not downgrade TextKit 2 views. But, it can be awful nice to swap between 1 and 2 quickly when debugging.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/Glyph", branch: "main")
],
```

## Usage

### `NSTextContainer` Additions

```swift
func characterIndexes(within rect: CGRect) -> IndexSet
func enumerateLineFragments(for rect: CGRect, strictIntersection: Bool, block: (CGRect, NSRange, inout Bool) -> Void)
func enumerateLineFragments(in range: NSRange, block: (CGRect, NSRange, inout Bool) -> Void)
func boundingRect(for range: NSRange) -> CGRect?
```

### `NSTextLayoutManager` Additions

```swift
func enumerateLineFragments(for rect: CGRect, options: NSTextLayoutFragment.EnumerationOptions = [], block: (CGRect, NSRange, inout Bool) -> Void)
func enumerateLineFragments(in range: NSRange, options: NSTextLayoutFragment.EnumerationOptions = [], block: (CGRect, NSRange, inout Bool) -> Void)
```

### `NSTextLayoutFragment` Additions

```swift
func enumerateLineFragments(with provider: NSTextElementProvider, block: (NSTextLineFragment, CGRect, NSRange) -> Void)
```

### `NSTextView`/`UITextView` Additions

```swift
func characterIndexes(within rect: CGRect) -> IndexSet
var visibleCharacterIndexes: IndexSet
func boundingRect(for range: NSRange) -> CGRect?

func setRenderingAttributes(_ attributes: [NSAttributedString.Key : Any], for range: NSRange)
```

### `NSRange` and `NSTextRange` Additions

```swift
NSRange.init?(_ textRange: NSTextRange)
NSTextRange.init?(_ range: NSRange)
```

## Contributing and Collaboration

I would love to hear from you! Issues or pull requests work great. A [Matrix space][matrix] is also available for live help, but I have a strong bias towards answering in the form of documentation.

I prefer collaboration, and would love to find ways to work together if you have a similar project.

I prefer indentation with tabs for improved accessibility. But, I'd rather you use the system you want and make a PR than hesitate because of whitespace.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

[build status]: https://github.com/ChimeHQ/Glyph/actions
[build status badge]: https://github.com/ChimeHQ/Glyph/workflows/CI/badge.svg
[platforms]: https://swiftpackageindex.com/ChimeHQ/Glyph
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FChimeHQ%2FGlyph%2Fbadge%3Ftype%3Dplatforms
[documentation]: https://swiftpackageindex.com/ChimeHQ/Glyph/main/documentation
[documentation badge]: https://img.shields.io/badge/Documentation-DocC-blue
[matrix]: https://matrix.to/#/%23chimehq%3Amatrix.org
[matrix badge]: https://img.shields.io/matrix/chimehq%3Amatrix.org?label=Matrix
