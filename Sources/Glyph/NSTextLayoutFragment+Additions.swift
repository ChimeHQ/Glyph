#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#elseif os(iOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) || os(iOS) || os(visionOS)
@available(macOS 12.0, iOS 15.0, *)
extension NSTextLineFragment {
	/// span has to be within this fragment's coordinate system
	func rangeOfCharacters(intersecting span: Range<CGFloat>) -> NSRange? {
		let length = characterRange.length

		var start: Int?

		for index in 0..<length {
			let point = locationForCharacter(at: index)

			// we might need to back up unless we happen to be exactly on the boundary
			if span.lowerBound < point.x {
				start = max(index - 1, 0)
				break
			}

			if span.lowerBound == point.x {
				start = index
				break
			}
		}

		guard let start else { return nil }

		var end: Int?

		for index in (start..<length).reversed() {
			let point = locationForCharacter(at: index)

			if span.upperBound >= point.x {
				end = min(index + 1, length)
				break
			}
		}

		guard let end else { return nil }

		return NSRange(start..<end)
	}
}

@available(macOS 12.0, iOS 15.0, *)
extension NSTextLayoutFragment {
	/// Enumerate the line fragments making out the layout fragment.
	///
	/// > Note: Reverse enumeration is more expensive.
	///
	/// - Parameter provider: used to translate ranges.
	/// - Parameter reverse: perform enumeration in reverse, defaults to false.
	/// - Parameter block: invoked per line fragment with the fragment itself, its bounding rect, its range in the text, and its layout fragment-relative index offset for use with the `locationForCharacter(at:)` API.
	public func enumerateLineFragments(with provider: NSTextElementProvider, reverse: Bool = false, block: (NSTextLineFragment, CGRect, NSRange, Int) -> Bool) {
		let origin = layoutFragmentFrame.origin
		let location = provider.offset?(from: provider.documentRange.location, to: rangeInElement.location) ?? 0

		// check to ensure our shift will always be valid
		precondition(location >= 0)
		precondition(location != NSNotFound)

		let fragments = reverse ? textLineFragments.reversed() : textLineFragments
		var offset = 0

		for textLineFragment in fragments {
			let bounds = textLineFragment.typographicBounds.offsetBy(dx: origin.x, dy: origin.y)
			let range = NSRange(
				location: textLineFragment.characterRange.location + location,
				length: textLineFragment.characterRange.length
			)

			if block(textLineFragment, bounds, range, offset) == false {
				return
			}

			offset += textLineFragment.characterRange.length
		}
	}

	/// Enumerate the line fragments making out the layout fragment.
	///
	/// > Note: Reverse enumeration is more expensive.
	///
	/// - Parameter range: restrict the enumeration to line fragments within this range.
	/// - Parameter provider: used to translate ranges.
	/// - Parameter reverse: perform enumeration in reverse, defaults to false.
	/// - Parameter block: invoked per line fragment with the fragment itself, its bounding rect, its range in the text, and its layout fragment-relative index offset for use with the `locationForCharacter(at:)` API.
	public func enumerateLineFragments(
		in range: NSRange,
		with provider: NSTextElementProvider,
		reverse: Bool = false,
		block: (NSTextLineFragment, CGRect, NSRange, Int) -> Bool
	) {
		enumerateLineFragments(with: provider, reverse: reverse) { lineFragment, frame, elementRange, offset in
			// this enumeration is unconditional, but some line fragments might not be within our range

			if reverse {

			} else {
				if elementRange.upperBound <= range.lowerBound {
					return true
				}

				if elementRange.lowerBound > range.upperBound {
					return true
				}
			}

			return block(lineFragment, frame, elementRange, offset)
		}
	}

	func enumerateLineFragments(
		with provider: NSTextElementProvider,
		intersecting rect: CGRect,
		block: (NSTextLineFragment, CGRect, NSRange) -> Bool
	) {
		let origin = layoutFragmentFrame.origin
		let location = provider.offset?(from: provider.documentRange.location, to: rangeInElement.location) ?? 0

		// check to ensure our shift will always be valid
		precondition(location >= 0)
		precondition(location != NSNotFound)

		var locationOffset = location

		for textLineFragment in textLineFragments {
			// we have to shift to compute overlap, and then shift back to compute the span
			let bounds = textLineFragment.typographicBounds.offsetBy(dx: origin.x, dy: origin.y)
			let overlap = bounds.intersection(rect).offsetBy(dx: -origin.x, dy: -origin.y)
			let span: Range<CGFloat> = overlap.minX..<overlap.maxX

			// the locationOffset has to be computed even if we do not overlap
			let offset = locationOffset
			defer {
				locationOffset += textLineFragment.characterRange.length
			}

			guard let localRange = textLineFragment.rangeOfCharacters(intersecting: span) else { continue }

			let range = NSRange(
				location: localRange.location + offset,
				length: localRange.length
			)

			if block(textLineFragment, bounds, range) == false {
				return
			}
		}
	}
}
#endif
