#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#elseif os(iOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) || os(iOS) || os(visionOS)
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
}
#endif
