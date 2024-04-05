#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#elseif os(iOS) || os(visionOS)
import UIKit
#endif

// Taken from https://github.com/chimeHQ/Rearrange

#if os(macOS) || os(iOS) || os(visionOS)
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
}
#endif
