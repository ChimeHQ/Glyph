#if canImport(AppKit)
import AppKit

typealias TextView = NSTextView
#elseif canImport(UIKit)
import UIKit

typealias TextView = UITextView
#endif

#if canImport(AppKit) || canImport(UIKit)
extension TextView {
	var visibleContainerRect: CGRect {
#if canImport(AppKit)
		let origin = textContainerOrigin
		return visibleRect.offsetBy(dx: -origin.x, dy: -origin.y)
#else
		return CGRect(origin: contentOffset, size: bounds.size)
#endif

	}

	/// Returns an IndexSet representing the content within `rect`.
	public func characterIndexes(within rect: CGRect) -> IndexSet {
#if canImport(AppKit)
		return textContainer?.characterIndexes(within: rect) ?? IndexSet()
#else
		return textContainer.characterIndexes(within: rect)
#endif
	}

	/// Returns an IndexSet representing the visible content.
	public var visibleCharacterIndexes: IndexSet {
		characterIndexes(within: visibleContainerRect)
	}

	/// Returns the bounding rectangle for the given text range.
	public func boundingRect(for range: NSRange) -> CGRect? {
#if canImport(AppKit)
		guard let rect = textContainer?.boundingRect(for: range) else {
			return nil
		}

		let origin = textContainerOrigin

		return rect.offsetBy(dx: origin.x, dy: origin.y)
#else
		return textContainer.boundingRect(for: range)
#endif
	}
}

extension TextView {
	/// Apply attributes that do not affect layout, if supported by the text system.
	public func setRenderingAttributes(_ attributes: [NSAttributedString.Key : Any], for range: NSRange) {
		// first determine if TK2 is enabled, so we do not downgrade
		if #available(macOS 12.0, iOS 16.0, *), let textLayoutManager = textLayoutManager {
			guard
				let contentManager = textLayoutManager.textContentManager,
				let textRange = NSTextRange(range, provider: contentManager)
			else {
				return
			}

			// apply a workaround to force rendering attributes to be applied immediately
#if canImport(AppKit)
			let selection = self.selectedRanges
#else
			let selection = self.selectedRange
#endif

			textLayoutManager.setRenderingAttributes(attributes, for: textRange)

#if canImport(AppKit)
			self.selectedRanges = [NSValue(range: range)]
			self.selectedRanges = selection
#else
			self.selectedRange = range
			self.selectedRange = selection
#endif
			return
		}

#if canImport(AppKit)
		layoutManager?.setTemporaryAttributes(attributes, forCharacterRange: range)
#endif
	}
}

#endif
