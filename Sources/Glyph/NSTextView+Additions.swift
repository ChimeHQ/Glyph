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
	public func textSet(for rect: CGRect) -> IndexSet {
#if os(macOS) && !targetEnvironment(macCatalyst)
		return textContainer?.textSet(for: rect) ?? IndexSet()
#elseif os(iOS) || os(visionOS)
		return textContainer.textSet(for: rect)
#endif
	}

	/// Returns an IndexSet representing the visible content.
	public var visibleTextSet: IndexSet {
		textSet(for: visibleContainerRect)
	}
}
#endif
