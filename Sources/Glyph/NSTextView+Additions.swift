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

	/// Returns the bounding rectangle for the given text range.
	public func boundingRect(for range: NSRange) -> CGRect? {
#if os(macOS) && !targetEnvironment(macCatalyst)
		guard let rect = textContainer?.boundingRect(for: range) else {
			return nil
		}

		let origin = textContainerOrigin

		return rect.offsetBy(dx: origin.x, dy: origin.y)
#elseif os(iOS) || os(visionOS)
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
#if os(macOS)
			let selection = self.selectedRanges
#else
			let selection = self.selectedRange
#endif

			textLayoutManager.setRenderingAttributes(attributes, for: textRange)

#if os(macOS)
			self.selectedRanges = [NSValue(range: range)]
			self.selectedRanges = selection
#else
			self.selectedRange = range
			self.selectedRange = selection
#endif
			return
		}

#if os(macOS)
		layoutManager?.setTemporaryAttributes(attributes, forCharacterRange: range)
#endif
	}
}

#endif
