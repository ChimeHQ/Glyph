#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#elseif os(iOS) || os(tvOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) || os(iOS) || os(tvOS) || os(visionOS)
@available(macOS 12.0, iOS 15.0, tvOS 15.0, *)
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
				fragment.enumerateLineFragments(with: textContentManager) { _, lineFrame, elementRange, _ in
					block(lineFrame, elementRange, &keepGoing)

					return keepGoing
				}
			}

			return keepGoing
		})
	}

	private func enumerateTextLineFragments(
		in range: NSRange,
		options: NSTextLayoutFragment.EnumerationOptions = [],
		block: (NSTextLayoutFragment, NSTextLineFragment, CGRect, NSRange, Int) -> Bool
	) {
		guard
			let textContentManager,
			let textRange = NSTextRange(range, provider: textContentManager)
		else { return }


		let reverse = options.contains(.reverse)
		let location = reverse ? textRange.endLocation : textRange.location
		let endLocation = reverse ? textRange.location : textRange.endLocation
		let endComparsion = reverse ? ComparisonResult.orderedDescending : ComparisonResult.orderedAscending

		enumerateTextLayoutFragments(from: location, options: options) { fragment in
			let fragmentRange = fragment.rangeInElement

			fragment.enumerateLineFragments(
				in: range,
				with: textContentManager,
				reverse: reverse
			) { lineFragment, frame, elementRange, offset in
				return block(fragment, lineFragment, frame, elementRange, offset)
			}

			return fragmentRange.location.compare(endLocation) == endComparsion
		}

		// There are a number of situations where the above code will miss a fragment.
		//
		// - forward, at the end of the content
		// - reverse, at the beginning of *non-empty* content
		//
		// Interestingly, reverse with empty content will actually enumerate the extra line in that case.

		let limit = reverse ? documentRange.location : documentRange.endLocation
		let atLimit = textContentManager.offset(from: limit, to: location) == 0

		if atLimit == false { return }
		if reverse && documentRange.isEmpty { return }

		if reverse {
			guard let prevLoc = textContentManager.location(textRange.location, offsetBy: 1) else {
				assertionFailure("this location should always exist")
				return
			}

			let range = NSRange(location: 0, length: 1)

			enumerateTextLayoutFragments(from: prevLoc, options: options) { fragment in
				fragment.enumerateLineFragments(
					in: range,
					with: textContentManager,
					reverse: reverse
				) { lineFragment, frame, elementRange, offset in
					_ = block(fragment, lineFragment, frame, elementRange, offset)

					return false
				}

				return false
			}

			return
		}

		// This means we are iterating forward and are at the end of the document. It's kind of bizarre, but we can reliably get the last fragment, even in the extra line case, by enumerating in reverse from the end.

		enumerateTextLayoutFragments(from: documentRange.endLocation, options: options.union([.reverse])) { fragment in
			fragment.enumerateLineFragments(
				in: range,
				with: textContentManager,
				reverse: true
			) { lineFragment, frame, elementRange, offset in
				_ = block(fragment, lineFragment, frame, elementRange, offset)

				return false
			}

			return false
		}
	}

	/// Iterate over text line layout fragments.
	///
	/// This method handles a number of special-cases, particularly around locations at the very beginning and end of the content. These situations can be useful for dealing with selection.
	public func enumerateLineFragments(
		in range: NSRange,
		options: NSTextLayoutFragment.EnumerationOptions = [],
		block: (CGRect, NSRange, inout Bool) -> Void
	) {
		var stop = false

		enumerateTextLineFragments(in: range, options: options) { fragment, lineFragment, frame, elementRange, offset in
			block(frame, elementRange, &stop)

			return stop == false
		}
	}

	/// Iterate over text line layout fragments starting at a specific location.
	///
	/// This is a convenience interface to `enumerateLineFragments(in:options:block:)`.
	public func enumerateLineFragments(
		from index: Int,
		options: NSTextLayoutFragment.EnumerationOptions = [],
		block: (CGRect, NSRange, inout Bool) -> Void
	) {
		guard let textContentManager else { return }

		let docRange = NSRange(documentRange, provider: textContentManager)

		guard docRange.location != NSNotFound else { return }

		let range: NSRange

		if options.contains(.reverse) {
			range = NSRange(docRange.lowerBound..<index)
		} else {
			range = NSRange(index..<docRange.upperBound)
		}

		enumerateTextLineFragments(in: range, options: options) { fragment, lineFragment, frame, fragmentRange, offset in
			var stop = false

			block(frame, fragmentRange, &stop)

			return stop == false
		}
	}

	public func boundingRect(for range: NSRange) -> CGRect? {
		var rect: CGRect? = nil

		enumerateTextLineFragments(in: range, options: [.ensuresLayout, .ensuresExtraLineFragment]) { fragment, lineFragment, lineRect, lineRange, offset in
			// we need to limit the check to what overlaps `range`
			let startIndex = max(range.lowerBound, lineRange.lowerBound) - lineRange.lowerBound
			let endIndex = min(range.upperBound, lineRange.upperBound) - lineRange.lowerBound

			// these are relative to the lineRange's location within fragment
			let startPos = lineFragment.locationForCharacter(at: startIndex + offset)
			let endPos = lineFragment.locationForCharacter(at: endIndex + offset)
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
