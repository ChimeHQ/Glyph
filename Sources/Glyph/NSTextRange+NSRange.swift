#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#elseif os(iOS) || os(visionOS)
import UIKit
#endif

// Taken from https://github.com/chimeHQ/Rearrange

#if os(macOS) || os(iOS) || os(visionOS)
@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
final class UTF16TextLocation: NSObject, NSTextLocation {
	let value: Int

	init(value: Int) {
		self.value = value
	}

	func compare(_ location: any NSTextLocation) -> ComparisonResult {
		guard let utf16Loc = location as? UTF16TextLocation else {
			return .orderedSame
		}

		if value < utf16Loc.value {
			return .orderedAscending
		}

		if value > utf16Loc.value {
			return .orderedDescending
		}

		return .orderedSame
	}
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
extension NSRange {
	init(_ textRange: NSTextRange, provider: NSTextElementProvider) {
		let docLocation = provider.documentRange.location

		let start = provider.offset?(from: docLocation, to: textRange.location) ?? NSNotFound
		if start == NSNotFound {
			self.init(location: start, length: 0)
			return
		}

		let end = provider.offset?(from: docLocation, to: textRange.endLocation) ?? NSNotFound
		if end == NSNotFound {
			self.init(location: NSNotFound, length: 0)
			return
		}

		self.init(start..<end)
	}

	public init?(_ textRange: NSTextRange) {
		guard
			let start = textRange.location as? UTF16TextLocation,
			let end = textRange.endLocation as? UTF16TextLocation
		else {
			return nil
		}

		self.init(start.value..<end.value)
	}
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
@available(watchOS, unavailable)
extension NSTextRange {
	public convenience init?(_ range: NSRange) {
		let start = UTF16TextLocation(value: range.lowerBound)
		let end = UTF16TextLocation(value: range.upperBound)

		self.init(location: start, end: end)
	}

	convenience init?(_ range: NSRange, provider: NSTextElementProvider) {
		let docLocation = provider.documentRange.location

		guard let start = provider.location?(docLocation, offsetBy: range.location) else {
			return nil
		}

		guard let end = provider.location?(start, offsetBy: range.length) else {
			return nil
		}

		self.init(location: start, end: end)
	}
}

#endif
