#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#elseif os(iOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) || os(iOS) || os(visionOS)
@available(macOS 12.0, iOS 15.0, *)
extension NSTextLayoutManager {
	public func enumerateLineFragments(for rect: CGRect, strictIntersection: Bool = true, options: NSTextLayoutFragment.EnumerationOptions = [], block: (CGRect, NSRange, inout Bool) -> Void) {
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

			if frame.intersects(rect) == false {
				// if we don't intersect, perhaps we just haven't reached window yet?
				if reversed {
					return frame.minY < rect.minY
				} else {
					return frame.maxY < rect.maxY
				}
			}

			var keepGoing: Bool = true

			if strictIntersection {
				fragment.enumerateLineFragments(with: textContentManager, intersecting: rect) { _, lineFrame, elementRange in
					block(lineFrame, elementRange, &keepGoing)

					return keepGoing
				}
			} else {
				fragment.enumerateLineFragments(with: textContentManager) { _, lineFrame, elementRange in
					block(lineFrame, elementRange, &keepGoing)

					return keepGoing
				}
			}

			return keepGoing
		})
	}

	// the last index in the storage might not return a fragment, and the logic required
	// to figure out which one should be in effect is atually quite complex
	private func lastTextLayoutFragment() -> NSTextLayoutFragment? {
		guard let textContentManager else { return nil }

		if let fragment = textLayoutFragment(for: documentRange.endLocation) {
			return fragment
		}

		guard let locBefore = textContentManager.location(documentRange.endLocation, offsetBy: -1) else {
			return nil
		}

		return textLayoutFragment(for: locBefore)
	}

	private func enumerateTextLineFragments(
		in range: NSRange,
		options: NSTextLayoutFragment.EnumerationOptions = [],
		block: (NSTextLayoutFragment, NSTextLineFragment, CGRect, NSRange) -> Bool
	) {
		guard let textContentManager else { return }

		let docStart = documentRange.location
		guard
			let start = textContentManager.location(docStart, offsetBy: range.lowerBound),
			let end = textContentManager.location(docStart, offsetBy: range.upperBound)
		else {
			return
		}

		let reverse = options.contains(.reverse)

		if textContentManager.offset(from: start, to: documentRange.endLocation) == 0 {
			guard let fragment = lastTextLayoutFragment() else { return }

			fragment.enumerateLineFragments(in: range, with: textContentManager, reverse: reverse) { lineFragment, frame, elementRange in
				block(fragment, lineFragment, frame, elementRange)
			}

			return
		}

		enumerateTextLayoutFragments(from: start, options: options) { fragment in
			let fragmentRange = fragment.rangeInElement

			fragment.enumerateLineFragments(in: range, with: textContentManager, reverse: reverse) { lineFragment, frame, elementRange in
				block(fragment, lineFragment, frame, elementRange)
			}

			return fragmentRange.endLocation.compare(end) == .orderedAscending
		}
	}

	public func enumerateLineFragments(
		in range: NSRange,
		options: NSTextLayoutFragment.EnumerationOptions = [],
		block: (CGRect, NSRange, inout Bool) -> Void
	) {
		guard let textContentManager else { return }

		// pretty sure this is a bug, range.location needs to be used no?
		let start = documentRange.location
		guard let end = textContentManager.location(start, offsetBy: range.length) else {
			return
		}

		let reverse = options.contains(.reverse)

		enumerateTextLayoutFragments(from: documentRange.location, options: options) { fragment in
			let fragmentRange = fragment.rangeInElement

			var stop = false

			fragment.enumerateLineFragments(in: range, with: textContentManager, reverse: reverse) { _, frame, elementRange in
				block(frame, elementRange, &stop)

				return stop == false
			}


			return stop == false && fragmentRange.endLocation.compare(end) == .orderedAscending
		}
	}

	public func enumerateLineFragments(
		from index: Int,
		options: NSTextLayoutFragment.EnumerationOptions = [],
		block: (CGRect, NSRange, inout Bool) -> Void
	) {
		guard let textContentManager else { return }

		let docStart = documentRange.location
		guard let start = textContentManager.location(docStart, offsetBy: index) else {
			return
		}

		let reverse = options.contains(.reverse)

		enumerateTextLayoutFragments(from: start, options: options) { fragment in
			var stop = false

			fragment.enumerateLineFragments(with: textContentManager, reverse: reverse) { _, frame, elementRange in
				// unfortunately it is possible that our position is within a fragment, so we have to verify ranges here too. We mightnot yet actually be at a relevant fragment
				if reverse {
					if elementRange.lowerBound > index {
						return true
					}
				} else {
					if elementRange.upperBound < index {
						return true
					}
				}

				block(frame, elementRange, &stop)

				return stop == false
			}

			return stop == false
		}
	}

	public func boundingRect(for range: NSRange) -> CGRect? {
		var rect: CGRect? = nil

		enumerateTextLineFragments(in: range, options: [.ensuresLayout]) { fragment, lineFragment, lineRect, lineRange in
			let startIndex = max(range.lowerBound, lineRange.lowerBound) - lineRange.lowerBound
			let endIndex = min(range.upperBound, lineRange.upperBound) - lineRange.lowerBound

			// these are relative to the lineRange
			let startPos = lineFragment.locationForCharacter(at: startIndex)
			let endPos = lineFragment.locationForCharacter(at: endIndex)
			let originPadding = fragment.layoutFragmentFrame.origin.x

			let bounds = CGRect(
				x: startPos.x + originPadding,
				y: lineRect.origin.y,
				width: (endPos.x - startPos.x),
				height: lineRect.height
			)

			rect = rect?.union(bounds) ?? bounds

			return true
		}

		return rect
	}
}
#endif
