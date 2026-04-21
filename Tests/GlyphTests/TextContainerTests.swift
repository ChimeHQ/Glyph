import Foundation
import Testing

import Glyph

@MainActor
struct NSTextContainerTests {
	@available(iOS 16.0, tvOS 16.0, *)
	@Test
	func lineFragmentWithZeroOffset() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb\nc\nd"

		let container = try #require(view.textContainer)

		let (_, range) = try #require(container.lineFragment(for: 0, offset: 0))

		#expect(range == NSRange(0..<2))
	}

	@available(iOS 16.0, tvOS 16.0, *)
	@Test
	func lineFragmentAtEndOfLineWithZeroOffset() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb\nc\nd"

		let container = try #require(view.textContainer)

		let (_, range) = try #require(container.lineFragment(for: 1, offset: 0))

		#expect(range == NSRange(0..<2))
	}

	@available(iOS 16.0, tvOS 16.0, *)
	@Test
	func lineFragmentForNextLineAtStart() throws {
		let view = TextView(usingTextLayoutManager: true)
		
		view.text = "a\nb\nc\nd"

		let container = try #require(view.textContainer)

		let (_, range) = try #require(container.lineFragment(for: 0, offset: 1))

		#expect(range == NSRange(2..<4))
	}

	@available(iOS 16.0, tvOS 16.0, *)
	@Test
	func lineFragmentForNextLineAtEndOfLine() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb\nc\nd"

		let container = try #require(view.textContainer)

		let (_, range) = try #require(container.lineFragment(for: 1, offset: 1))

		#expect(range == NSRange(2..<4))
	}

	@available(iOS 16.0, tvOS 16.0, *)
	@Test
	func lineFragmentForPreviousLineAtStartOfNext() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb\nc\nd"

		let container = try #require(view.textContainer)

		let (_, range) = try #require(container.lineFragment(for: 2, offset: -1))

		#expect(range == NSRange(0..<2))
	}

	@available(iOS 16.0, tvOS 16.0, *)
	@Test
	func lineFragmentForTwoPreviousLinesAtStartOfNext() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb\nc\nd"

		let container = try #require(view.textContainer)

		let (_, range) = try #require(container.lineFragment(for: 4, offset: -2))

		#expect(range == NSRange(0..<2))
	}

	@available(iOS 16.0, tvOS 16.0, *)
	@Test
	func lineFragmentForPreviousLineAtEndOfNext() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb\nc\nd"

		let container = try #require(view.textContainer)

		let (_, range) = try #require(container.lineFragment(for: 3, offset: -1))

		#expect(range == NSRange(0..<2))
	}

	@available(iOS 16.0, tvOS 16.0, *)
	@Test
	func lineFragmentForNextExtraLineExtra() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\n"

		let container = try #require(view.textContainer)

		let (_, range) = try #require(container.lineFragment(for: 1, offset: 1))

		#expect(range == NSRange(2..<2))
	}

	@available(iOS 16.0, tvOS 16.0, *)
	@Test
	func lineFragmentForPreviousLineAtExtraLine() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\n"

		let container = try #require(view.textContainer)

		let (_, range) = try #require(container.lineFragment(for: 2, offset: -1))

		#expect(range == NSRange(0..<2))
	}

	@available(iOS 16.0, tvOS 16.0, *)
	@Test
	func lineFragmentForPreviousLineAtEndOfContent() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb"

		let container = try #require(view.textContainer)

		let (_, range) = try #require(container.lineFragment(for: 3, offset: -1))

		#expect(range == NSRange(0..<2))
	}
}
