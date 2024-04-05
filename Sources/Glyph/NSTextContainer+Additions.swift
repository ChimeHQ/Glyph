#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#elseif os(iOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) || os(iOS) || os(visionOS)
extension NSTextContainer {
	var nonDowngradingLayoutManager: NSLayoutManager? {
		if #available(macOS 12.0, iOS 15.0, *), textLayoutManager != nil {
			return nil
		}

		return layoutManager
	}

	func textRange(for rect: CGRect) -> NSRange? {
		guard let layoutManager = nonDowngradingLayoutManager else { return nil }

		let glyphRange = layoutManager.glyphRange(forBoundingRect: rect, in: self)

		return layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
	}

	func tk1EnumerateLineFragments(for rect: CGRect, strictIntersection: Bool, block: (CGRect, NSRange, inout Bool) -> Void) {
		guard let layoutManager = nonDowngradingLayoutManager else { return }

		let glyphRange = layoutManager.glyphRange(forBoundingRect: rect, in: self)

		withoutActuallyEscaping(block) { escapingBlock in
			layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { (fragmentRect, _, _, fragmentRange, stop) in
				var innerStop = false

				if strictIntersection {
					let intersectingRect = fragmentRect.intersection(rect)
					let intersectingGlyphRange = layoutManager.glyphRange(forBoundingRectWithoutAdditionalLayout: intersectingRect, in: self)
					let intersectingRange = layoutManager.characterRange(forGlyphRange: intersectingGlyphRange, actualGlyphRange: nil)

					escapingBlock(intersectingRect, intersectingRange, &innerStop)
				} else {
					escapingBlock(fragmentRect, fragmentRange, &innerStop)
				}

				stop.pointee = ObjCBool(innerStop)
			}
		}
	}

	/// Enumerate the line fragments that intersect a rect.
	///
	/// - Parameter strictIntersection: If true, the result will only be rect and range strictly within the `rect` parameter. This is more expensive to compute.
	public func enumerateLineFragments(for rect: CGRect, strictIntersection: Bool, block: (CGRect, NSRange, inout Bool) -> Void) {
		if #available(macOS 12.0, iOS 15.0, *), let textLayoutManager {
			guard let textContentManager = textLayoutManager.textContentManager else {
				return
			}

			textLayoutManager.enumerateLineFragments(for: rect) { fragmentRect, textRange, stop in
				guard let textRange else { return }

				let range = NSRange(textRange, provider: textContentManager)

				block(fragmentRect, range, &stop)
			}

			return
		}

		tk1EnumerateLineFragments(for: rect, strictIntersection: strictIntersection, block: block)
	}
}
#endif
