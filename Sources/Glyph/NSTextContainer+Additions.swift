#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#elseif os(iOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) || os(iOS) || os(visionOS)
extension NSTextContainer {
	private func tk1EnumerateLineFragments(for rect: CGRect, strictIntersection: Bool, block: (CGRect, NSRange, inout Bool) -> Void) {
		guard let layoutManager = layoutManager else { return }

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
	public func characterIndexes(within rect: CGRect) -> IndexSet {
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

extension NSTextContainer {
	public func boundingRect(for range: NSRange) -> NSRect? {
		if #available(macOS 12.0, iOS 15.0, *), let textLayoutManager {
			return textLayoutManager.boundingRect(for: range)
		}

		return tk1BoundingRect(for: range)
	}

	private func tk1BoundingRect(for range: NSRange) -> NSRect? {
		guard let layoutManager else { return nil }

		let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)

		return layoutManager.boundingRect(forGlyphRange: glyphRange, in: self)
	}

	private func tk1TextRange(intersecting rect: CGRect) -> NSRange? {
		guard let layoutManager else { return nil }

		let glyphRange = layoutManager.glyphRange(forBoundingRect: rect, in: self)

		return layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
	}
}
#endif
