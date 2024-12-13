#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#elseif os(iOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) || os(iOS) || os(visionOS)
extension NSLayoutManager {
	func enumerateLineFragments(for rect: CGRect, in container: NSTextContainer, strictIntersection: Bool, block: (CGRect, NSRange, inout Bool) -> Void) {
		let glRange = glyphRange(forBoundingRect: rect, in: container)

		withoutActuallyEscaping(block) { escapingBlock in
			enumerateLineFragments(forGlyphRange: glRange) { (fragmentRect, _, _, fragmentRange, stop) in
				var innerStop = false

				if strictIntersection {
					let intersectingRect = fragmentRect.intersection(rect)
					let intersectingGlyphRange = self.glyphRange(forBoundingRectWithoutAdditionalLayout: intersectingRect, in: container)
					let intersectingRange = self.characterRange(forGlyphRange: intersectingGlyphRange, actualGlyphRange: nil)

					escapingBlock(intersectingRect, intersectingRange, &innerStop)
				} else {
					escapingBlock(fragmentRect, fragmentRange, &innerStop)
				}

				stop.pointee = ObjCBool(innerStop)
			}
		}

	}
}
#endif
