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

	private func tk1EnumerateLineFragments(for rect: CGRect, strictIntersection: Bool, block: (CGRect, NSRange, inout Bool) -> Void) {
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
			textLayoutManager.enumerateLineFragments(for: rect) { fragmentRect, range, stop in
				block(fragmentRect, range, &stop)
			}

			return
		}

		tk1EnumerateLineFragments(for: rect, strictIntersection: strictIntersection, block: block)
	}

	/// Returns an IndexSet representing the content within `rect`.
	public func textSet(for rect: CGRect) -> IndexSet {
		var set = IndexSet()

		enumerateLineFragments(for: rect, strictIntersection: true) { _, range, _ in
			set.insert(integersIn: range.lowerBound..<range.upperBound)
		}

		return set
	}
}

extension NSTextContainer {
	private func tk1EnumerateLineFragments(in range: NSRange, block: (CGRect, NSRange, inout Bool) -> Void) {
		guard let glyphRange = layoutManager?.glyphRange(forCharacterRange: range, actualCharacterRange: nil) else {
			return
		}

		withoutActuallyEscaping(block) { escapingBlock in
			layoutManager?.enumerateLineFragments(forGlyphRange: glyphRange) { (fragmentRect, _, _, fragmentRange, stop) in
				var innerStop = false

				escapingBlock(fragmentRect, fragmentRange, &innerStop)

				stop.pointee = ObjCBool(innerStop)
			}
		}
	}

	/// Enumerate the line fragments that intersect `range`.
	public func enumerateLineFragments(in range: NSRange, block: (CGRect, NSRange, inout Bool) -> Void) {
		if #available(macOS 12.0, iOS 15.0, *), let textLayoutManager {
			textLayoutManager.enumerateLineFragments(in: range) { fragmentRect, fragmentRange, stop in
				block(fragmentRect, fragmentRange, &stop)
			}

			return
		}

		tk1EnumerateLineFragments(in: range, block: block)
	}
}
#endif
