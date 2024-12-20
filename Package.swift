// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "Glyph",
	platforms: [
		.macOS(.v10_13),
		.macCatalyst(.v13),
		.iOS(.v12),
		.tvOS(.v12),
		.visionOS(.v1),

	],
	products: [
		.library(name: "Glyph", targets: ["Glyph"]),
	],
	targets: [
		.target(name: "Glyph"),
		.testTarget(name: "GlyphTests", dependencies: ["Glyph"]),
	]
)
