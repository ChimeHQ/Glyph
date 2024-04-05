<div align="center">

[![Build Status][build status badge]][build status]
[![Platforms][platforms badge]][platforms]
[![Documentation][documentation badge]][documentation]
[![Discord][discord badge]][discord]

</div>

# Glyph
Make life with TextKit better

This library adds functionality to TextKit to make it easier to use. It works with both TextKit 1 and 2, and will not downgrade TextKit 2 views. 

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/Glyph", branch: "main")
],
```

## Usage

### `NSTextContainer` Additions

```swift
func enumerateLineFragments(for rect: CGRect, strictIntersection: Bool, block: (CGRect, NSRange, inout Bool) -> Void)
```

### `NSTextLayoutManager` Additions

```swift
func enumerateLineFragments(for rect: CGRect, options: NSTextLayoutFragment.EnumerationOptions = [], block: (CGRect, NSTextRange?, inout Bool) -> Void)
```

### `NSTextView`/`UITextView` Additions

```swift
var visibleTextSet: IndexSet
```

## Contributing and Collaboration

I would love to hear from you! Issues or pull requests work great. A [Discord server][discord] is also available for live help, but I have a strong bias towards answering in the form of documentation.

I prefer collaboration, and would love to find ways to work together if you have a similar project.

I prefer indentation with tabs for improved accessibility. But, I'd rather you use the system you want and make a PR than hesitate because of whitespace.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

[build status]: https://github.com/ChimeHQ/Glyph/actions
[build status badge]: https://github.com/ChimeHQ/Glyph/workflows/CI/badge.svg
[platforms]: https://swiftpackageindex.com/ChimeHQ/Glyph
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FChimeHQ%2FGlyph%2Fbadge%3Ftype%3Dplatforms
[documentation]: https://swiftpackageindex.com/ChimeHQ/Glyph/main/documentation
[documentation badge]: https://img.shields.io/badge/Documentation-DocC-blue
[discord]: https://discord.gg/esFpX6sErJ
[discord badge]: https://img.shields.io/badge/Discord-purple?logo=Discord&label=Chat&color=%235A64EC
