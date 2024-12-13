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

			if span.upperBound > point.x {
				end = min(index + 1, length)
				break
			}

			if span.upperBound == point.x {
				end = index
				break
			}
		}

		guard let end else { return nil }

		return NSRange(start..<end)
	}
}

@available(macOS 12.0, iOS 15.0, *)
extension NSTextLayoutFragment {
	public func enumerateLineFragments(with provider: NSTextElementProvider, block: (NSTextLineFragment, CGRect, NSRange) -> Void) {
		let origin = layoutFragmentFrame.origin
		let location = provider.offset?(from: provider.documentRange.location, to: rangeInElement.location) ?? 0

		// check to ensure our shift will always be valid
		precondition(location >= 0)
		precondition(location != NSNotFound)

		for textLineFragment in textLineFragments {
			let bounds = textLineFragment.typographicBounds.offsetBy(dx: origin.x, dy: origin.y)
			let range = NSRange(
				location: textLineFragment.characterRange.location + location,
				length: textLineFragment.characterRange.length
			)

			block(textLineFragment, bounds, range)
		}
	}

	func enumerateLineFragments(
		with provider: NSTextElementProvider,
		intersecting rect: CGRect,
		block: (NSTextLineFragment, CGRect, NSRange) -> Void
	) {
		let origin = layoutFragmentFrame.origin
		let location = provider.offset?(from: provider.documentRange.location, to: rangeInElement.location) ?? 0

		// check to ensure our shift will always be valid
		precondition(location >= 0)
		precondition(location != NSNotFound)

		for textLineFragment in textLineFragments {
			let bounds = textLineFragment.typographicBounds.offsetBy(dx: origin.x, dy: origin.y)

			let overlap = bounds.intersection(rect)
			let span: Range<CGFloat> = overlap.minX..<overlap.maxX

			guard let localRange = textLineFragment.rangeOfCharacters(intersecting: span) else { continue }

			let range = NSRange(
				location: localRange.location + location,
				length: localRange.length
			)

			block(textLineFragment, bounds, range)
		}
	}
}
#endif
