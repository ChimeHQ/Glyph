#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#elseif os(iOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) || os(iOS) || os(visionOS)
@available(macOS 12.0, iOS 15.0, *)
extension NSTextLayoutManager {
	public func enumerateLineFragments(for rect: CGRect, options: NSTextLayoutFragment.EnumerationOptions = [], block: (CGRect, NSRange, inout Bool) -> Void) {
		guard let textContentManager else { return }

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

			var keepGoing: Bool

			if reversed {
				keepGoing = frame.minY < rect.minY
			} else {
				keepGoing = frame.maxY < rect.maxY
			}

			if keepGoing == false {
				return false
			}

			fragment.enumerateLineFragments(with: textContentManager) { _, frame, elementRange in
				block(frame, elementRange, &keepGoing)
			}

			return keepGoing
		})
	}

	public func enumerateLineFragments(in range: NSRange, options: NSTextLayoutFragment.EnumerationOptions = [], block: (CGRect, NSRange, inout Bool) -> Void) {
		guard let textContentManager else { return }

		let start = documentRange.location
		guard let end = textContentManager.location(start, offsetBy: range.length) else {
			return
		}

		enumerateTextLayoutFragments(from: documentRange.location, options: options) { fragment in
			let fragmentRange = fragment.rangeInElement

			var stop = false

			fragment.enumerateLineFragments(with: textContentManager) { _, frame, elementRange in
				block(frame, elementRange, &stop)
			}


			return stop == false && fragmentRange.endLocation.compare(end) == .orderedAscending
		}
	}
}
#endif
