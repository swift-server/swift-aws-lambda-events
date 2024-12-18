import XCTest
@testable import AWSLambdaEvents

final class IteratorProtocolTests: XCTestCase {
    func testExpect() {
        // Test matching character
        var iterator = "abc".utf8.makeIterator()
        XCTAssertTrue(iterator.expect(UInt8(ascii: "a")))
        XCTAssertEqual(iterator.next(), UInt8(ascii: "b"))
        
        // Test non-matching character
        iterator = "abc".utf8.makeIterator()
        XCTAssertFalse(iterator.expect(UInt8(ascii: "x")))
    }
    
    func testNextSkippingWhitespace() {
        // Test with leading spaces
        var iterator = "   abc".utf8.makeIterator()
        XCTAssertEqual(iterator.nextSkippingWhitespace(), UInt8(ascii: "a"))
        
        // Test with no spaces
        iterator = "abc".utf8.makeIterator()
        XCTAssertEqual(iterator.nextSkippingWhitespace(), UInt8(ascii: "a"))
        
        // Test with only spaces
        iterator = "   ".utf8.makeIterator()
        XCTAssertNil(iterator.nextSkippingWhitespace())
    }
    
    func testNextAsciiDigit() {
        // Test basic digit
        var iterator = "123".utf8.makeIterator()
        XCTAssertEqual(iterator.nextAsciiDigit(), UInt8(ascii: "1"))
        
        // Test with leading spaces and skipping whitespace
        iterator = "  123".utf8.makeIterator()
        XCTAssertEqual(iterator.nextAsciiDigit(skippingWhitespace: true), UInt8(ascii: "1"))
        
        // Test with leading spaces and not skipping whitespace
        iterator = "  123".utf8.makeIterator()
        XCTAssertNil(iterator.nextAsciiDigit())
        
        // Test with non-digit
        iterator = "abc".utf8.makeIterator()
        XCTAssertNil(iterator.nextAsciiDigit())
    }
    
    func testNextAsciiLetter() {
        // Test basic letter
        var iterator = "abc".utf8.makeIterator()
        XCTAssertEqual(iterator.nextAsciiLetter(), UInt8(ascii: "a"))
        
        // Test with leading spaces and skipping whitespace
        iterator = "  abc".utf8.makeIterator()
        XCTAssertEqual(iterator.nextAsciiLetter(skippingWhitespace: true), UInt8(ascii: "a"))
        
        // Test with leading spaces and not skipping whitespace
        iterator = "  abc".utf8.makeIterator()
        XCTAssertNil(iterator.nextAsciiLetter())
        
        // Test with non-letter
        iterator = "123".utf8.makeIterator()
        XCTAssertNil(iterator.nextAsciiLetter())
        
        // Test with uppercase
        iterator = "ABC".utf8.makeIterator()
        XCTAssertEqual(iterator.nextAsciiLetter(), UInt8(ascii: "A"))

        // Test with empty string
        iterator = "".utf8.makeIterator()
        XCTAssertNil(iterator.nextAsciiLetter())
    }
}