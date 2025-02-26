#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#elseif os(iOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) || os(iOS) || os(visionOS)
extension NSTextContainer {
	/// Enumerate the line fragments that intersect a rect.
	///
	/// - Parameter strictIntersection: If true, the result will only be rect and range strictly within the `rect` parameter. This is more expensive to compute.
	public func enumerateLineFragments(for rect: CGRect, strictIntersection: Bool, block: (CGRect, NSRange, inout Bool) -> Void) {
		if #available(macOS 12.0, iOS 15.0, *), let textLayoutManager {
			textLayoutManager.enumerateLineFragments(for: rect, strictIntersection: strictIntersection, options: [.ensuresExtraLineFragment], block: block)

			return
		}

		layoutManager?.enumerateLineFragments(for: rect, in: self, strictIntersection: strictIntersection, block: block)
	}
}

extension NSTextContainer {
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

	private func tk1EnumerateLineFragments(from index: Int, forward: Bool, block: (CGRect, NSRange, inout Bool) -> Void) {
		// TODO
	}

	public func enumerateLineFragments(from index: Int, forward: Bool = true, block: (CGRect, NSRange, inout Bool) -> Void) {
		if #available(macOS 12.0, iOS 15.0, *), let textLayoutManager {
			let options: NSTextLayoutFragment.EnumerationOptions = forward ? [.ensuresLayout] : [.reverse, .ensuresLayout]

			textLayoutManager.enumerateLineFragments(from: index, options: options, block: block)

			return
		}

		tk1EnumerateLineFragments(from: index, forward: forward, block: block)
	}

	/// Find line fragment offset from the first fragment containing index.
	public func lineFragment(for index: Int, offset: Int) -> (CGRect, NSRange)? {
		var fragment: (CGRect, NSRange)?
		let forward = offset >= 0
		var count = abs(offset)

		enumerateLineFragments(from: index, forward: forward) { rect, range, stop in
			if count <= 0 {
				fragment = (rect, range)
				stop = true
				return
			}

			count -= 1
		}

		return fragment
	}
}

extension NSTextContainer {
	/// Compute a single rect that encloses all of the text within `range`.
	///
	/// This area can be much larger than considering each individual line fragment independently.
	public func boundingRect(for range: NSRange) -> CGRect? {
		if #available(macOS 12.0, iOS 15.0, *), let textLayoutManager {
			return textLayoutManager.boundingRect(for: range)
		}

		return tk1BoundingRect(for: range)
	}

	private func tk1BoundingRect(for range: NSRange) -> CGRect? {
		guard let layoutManager else { return nil }

		let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)

		return layoutManager.boundingRect(forGlyphRange: glyphRange, in: self)
	}
}
#endif
