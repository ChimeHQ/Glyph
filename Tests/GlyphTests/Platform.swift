#if os(macOS)
import AppKit

typealias TextView = NSTextView

extension NSTextView {
	var text: String {
		get { string }
		set { self.string = newValue }
	}
}

#elseif canImport(UIKit)
import UIKit

typealias TextView = UITextView

#endif
