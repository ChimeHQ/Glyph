#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit

typealias TextView = NSTextView
#elseif os(iOS) || os(visionOS)
import UIKit

typealias TextView = UITextView
#endif

#if os(macOS) || os(iOS) || os(visionOS)
extension TextView {
	var visibleContainerRect: CGRect {
#if os(macOS) && !targetEnvironment(macCatalyst)
		let origin = textContainerOrigin
		return visibleRect.offsetBy(dx: -origin.x, dy: -origin.y)
#elseif os(iOS) || os(visionOS)
		return CGRect(origin: contentOffset, size: bounds.size)
#endif

	}

	/// Returns an IndexSet representing the content within `rect`.
	public func characterIndexes(within rect: CGRect) -> IndexSet {
#if os(macOS) && !targetEnvironment(macCatalyst)
		return textContainer?.characterIndexes(within: rect) ?? IndexSet()
#elseif os(iOS) || os(visionOS)
		return textContainer.characterIndexes(within: rect)
#endif
	}

	/// Returns an IndexSet representing the visible content.
	public var visibleCharacterIndexes: IndexSet {
		characterIndexes(within: visibleContainerRect)
	}
}
#endif
