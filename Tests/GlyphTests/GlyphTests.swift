import Foundation
import Testing

import Glyph

@MainActor
struct TextLayoutManagerTests {
	@available(iOS 16.0, tvOS 15.0, *)
	@Test
	func forwardLineFragmentEnumeration() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb\nc\nd"

		let textLayoutManager = try #require(view.textLayoutManager)

		var ranges: [NSRange] = []
		textLayoutManager.enumerateLineFragments(
			in: NSRange(0..<7),
			options: [.ensuresExtraLineFragment, .ensuresLayout]
		) { _, range, _ in
			ranges.append(range)
		}

		let expected = [
			NSRange(0..<2),
			NSRange(2..<4),
			NSRange(4..<6),
			NSRange(6..<7),
		]

		#expect(ranges == expected)
	}

	@available(iOS 16.0, tvOS 15.0, *)
	@Test
	func reverseLineFragmentEnumeration() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb\nc\nd"

		let textLayoutManager = try #require(view.textLayoutManager)

		var ranges: [NSRange] = []
		textLayoutManager.enumerateLineFragments(
			in: NSRange(0..<7),
			options: [.ensuresExtraLineFragment, .ensuresLayout, .reverse]
		) { _, range, _ in
			ranges.append(range)
		}

		let expected = [
			NSRange(6..<7),
			NSRange(4..<6),
			NSRange(2..<4),
			NSRange(0..<2),
		]

		#expect(ranges == expected)
	}

	@available(iOS 16.0, tvOS 15.0, *)
	@Test
	func forwardLineFragmentEnumerationWithExtraLine() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb\nc\n"

		let textLayoutManager = try #require(view.textLayoutManager)

		var ranges: [NSRange] = []
		textLayoutManager.enumerateLineFragments(
			in: NSRange(0..<6),
			options: [.ensuresExtraLineFragment, .ensuresLayout]
		) { _, range, _ in
			ranges.append(range)
		}

		let expected = [
			NSRange(0..<2),
			NSRange(2..<4),
			NSRange(4..<6),
			NSRange(6..<6),
		]

		#expect(ranges == expected)
	}

	@available(iOS 16.0, tvOS 15.0, *)
	@Test
	func reverseLineFragmentEnumerationWithExtraLine() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb\nc\n"

		let textLayoutManager = try #require(view.textLayoutManager)

		var ranges: [NSRange] = []
		textLayoutManager.enumerateLineFragments(
			in: NSRange(0..<6),
			options: [.ensuresExtraLineFragment, .ensuresLayout, .reverse]
		) { _, range, _ in
			ranges.append(range)
		}

		let expected = [
			NSRange(6..<6),
			NSRange(4..<6),
			NSRange(2..<4),
			NSRange(0..<2),
		]

		#expect(ranges == expected)
	}

	@available(iOS 16.0, tvOS 15.0, *)
	@Test
	func forwardLineFragmentEnumerationWithEmptyContent() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = ""

		let textLayoutManager = try #require(view.textLayoutManager)

		var ranges: [NSRange] = []
		textLayoutManager.enumerateLineFragments(
			in: NSRange(0..<0),
			options: [.ensuresExtraLineFragment, .ensuresLayout]
		) { _, range, _ in
			ranges.append(range)
		}

		let expected = [
			NSRange(0..<0),
		]

		#expect(ranges == expected)
	}

	@available(iOS 16.0, tvOS 15.0, *)
	@Test
	func reverseLineFragmentEnumerationWithEmptyContent() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = ""

		let textLayoutManager = try #require(view.textLayoutManager)

		var ranges: [NSRange] = []
		textLayoutManager.enumerateLineFragments(
			in: NSRange(0..<0),
			options: [.ensuresExtraLineFragment, .ensuresLayout, .reverse]
		) { _, range, _ in
			ranges.append(range)
		}

		let expected = [
			NSRange(0..<0),
		]

		#expect(ranges == expected)
	}

	@available(iOS 16.0, tvOS 15.0, *)
	@Test
	func forwardLineFragmentEnumerationAtEndOfContentWithExtraLine() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb\nc\n"

		let textLayoutManager = try #require(view.textLayoutManager)

		var ranges: [NSRange] = []
		textLayoutManager.enumerateLineFragments(
			in: NSRange(6..<6),
			options: [.ensuresExtraLineFragment, .ensuresLayout]
		) { _, range, _ in
			ranges.append(range)
		}

		let expected = [
			NSRange(6..<6),
		]

		#expect(ranges == expected)
	}

	@available(iOS 16.0, tvOS 15.0, *)
	@Test
	func reverseLineFragmentEnumerationAtStartOfContentWithExtraLine() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb\nc\n"

		let textLayoutManager = try #require(view.textLayoutManager)

		var ranges: [NSRange] = []
		textLayoutManager.enumerateLineFragments(
			in: NSRange(0..<0),
			options: [.ensuresExtraLineFragment, .ensuresLayout]
		) { _, range, _ in
			ranges.append(range)
		}

		let expected = [
			NSRange(0..<2),
		]

		#expect(ranges == expected)
	}

	@available(iOS 16.0, tvOS 15.0, *)
	@Test
	func forwardLineFragmentEnumerationAtEndOfContent() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb\nc\nd"

		let textLayoutManager = try #require(view.textLayoutManager)

		var ranges: [NSRange] = []
		textLayoutManager.enumerateLineFragments(
			in: NSRange(7..<7),
			options: [.ensuresExtraLineFragment, .ensuresLayout]
		) { _, range, _ in
			ranges.append(range)
		}

		let expected = [
			NSRange(6..<7),
		]

		#expect(ranges == expected)
	}

	@available(iOS 16.0, tvOS 15.0, *)
	@Test
	func reverseLineFragmentEnumerationAtStartOfContent() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb\nc\nd"

		let textLayoutManager = try #require(view.textLayoutManager)

		var ranges: [NSRange] = []
		textLayoutManager.enumerateLineFragments(
			in: NSRange(0..<0),
			options: [.ensuresExtraLineFragment, .ensuresLayout, .reverse]
		) { _, range, _ in
			ranges.append(range)
		}

		let expected = [
			NSRange(0..<2),
		]

		#expect(ranges == expected)
	}

	@available(iOS 16.0, tvOS 15.0, *)
	@Test
	func forwardLineFragmentEnumerationFromIndex() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb\nc\nd"

		let textLayoutManager = try #require(view.textLayoutManager)

		var ranges: [NSRange] = []
		textLayoutManager.enumerateLineFragments(
			from: 0,
			options: [.ensuresExtraLineFragment, .ensuresLayout]
		) { _, range, _ in
			ranges.append(range)
		}

		let expected = [
			NSRange(0..<2),
			NSRange(2..<4),
			NSRange(4..<6),
			NSRange(6..<7),
		]

		#expect(ranges == expected)
	}

	@available(iOS 16.0, tvOS 15.0, *)
	@Test
	func reverseLineFragmentEnumerationFromIndex() throws {
		let view = TextView(usingTextLayoutManager: true)

		view.text = "a\nb\nc\nd"

		let textLayoutManager = try #require(view.textLayoutManager)

		var ranges: [NSRange] = []
		textLayoutManager.enumerateLineFragments(
			from: 7,
			options: [.ensuresExtraLineFragment, .ensuresLayout, .reverse]
		) { _, range, _ in
			ranges.append(range)
		}

		let expected = [
			NSRange(6..<7),
			NSRange(4..<6),
			NSRange(2..<4),
			NSRange(0..<2),
		]

		#expect(ranges == expected)
	}
}
