#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#elseif os(iOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) || os(iOS) || os(visionOS)
@available(macOS 12.0, iOS 15.0, *)
extension NSTextLayoutManager {
	public func enumerateLineFragments(for rect: CGRect, options: NSTextLayoutFragment.EnumerationOptions = [], block: (CGRect, NSTextRange?, inout Bool) -> Void) {
		// if this is nil, our optmizations will have no effect
		let viewportRange = textViewportLayoutController.viewportRange ?? documentRange
		let viewportBounds = textViewportLayoutController.viewportBounds
		let reversed = options.contains(.reverse)

		// we're going to start at a document limit, which is definitely correct but suboptimal

		var location: NSTextLocation

		if reversed {
			location = documentRange.endLocation

			if rect.maxY <= viewportBounds.maxY {
				location = viewportRange.endLocation
			}

			if rect.maxY <= viewportBounds.minY {
				location = viewportRange.location
			}
		} else {
			location = documentRange.location

			if rect.minY >= viewportBounds.minY {
				location = viewportRange.location
			}

			if rect.minY >= viewportBounds.maxY {
				location = viewportRange.endLocation
			}
		}

		enumerateTextLayoutFragments(from: location, options: options, using: { fragment in
			let frame = fragment.layoutFragmentFrame
			let elementRange = fragment.textElement?.elementRange

			var keepGoing: Bool

			if reversed {
				keepGoing = frame.minY < rect.minY
			} else {
				keepGoing = frame.maxY < rect.maxY
			}

			if keepGoing == false {
				return false
			}

			block(frame, elementRange, &keepGoing)

			return keepGoing
		})
	}

}
#endif
