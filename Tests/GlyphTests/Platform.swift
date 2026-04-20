#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit

typealias TextView = NSTextView

extension NSTextView {
	var text: String {
		get { string }
		set { self.string = newValue }
	}
}
#elseif os(iOS) || os(tvOS) || os(visionOS)
import UIKit

typealias TextView = UITextView
#endif
