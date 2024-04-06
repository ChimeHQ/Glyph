// swift-tools-version: 5.10

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

let swiftSettings: [SwiftSetting] = [
	.enableExperimentalFeature("StrictConcurrency"),
]

for target in package.targets {
	var settings = target.swiftSettings ?? []
	settings.append(contentsOf: swiftSettings)
	target.swiftSettings = settings
}
