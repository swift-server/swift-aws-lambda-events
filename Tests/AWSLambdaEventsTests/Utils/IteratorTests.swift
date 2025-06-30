//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) 2017-2020 Apple Inc. and the SwiftAWSLambdaRuntime project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAWSLambdaRuntime project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Testing

@testable import AWSLambdaEvents

@Suite
struct IteratorProtocolTests {
    @Test func expect() {
        // Test matching character
        var iterator = "abc".utf8.makeIterator()
        let result1 = iterator.expect(UInt8(ascii: "a"))
        #expect(result1)
        #expect(iterator.next() == UInt8(ascii: "b"))

        // Test non-matching character
        iterator = "abc".utf8.makeIterator()
        let result2 = iterator.expect(UInt8(ascii: "x"))
        #expect(!result2)
    }

    @Test func nextSkippingWhitespace() {
        // Test with leading spaces
        var iterator = "   abc".utf8.makeIterator()
        #expect(iterator.nextSkippingWhitespace() == UInt8(ascii: "a"))

        // Test with no spaces
        iterator = "abc".utf8.makeIterator()
        #expect(iterator.nextSkippingWhitespace() == UInt8(ascii: "a"))

        // Test with only spaces
        iterator = "   ".utf8.makeIterator()
        let result = iterator.nextSkippingWhitespace()
        #expect(result == nil)
    }

    @Test func nextAsciiDigit() {
        // Test basic digit
        var iterator = "123".utf8.makeIterator()
        #expect(iterator.nextAsciiDigit() == UInt8(ascii: "1"))

        // Test with leading spaces and skipping whitespace
        iterator = "  123".utf8.makeIterator()
        #expect(iterator.nextAsciiDigit(skippingWhitespace: true) == UInt8(ascii: "1"))

        // Test with leading spaces and not skipping whitespace
        iterator = "  123".utf8.makeIterator()
        let result1 = iterator.nextAsciiDigit()
        #expect(result1 == nil)

        // Test with non-digit
        iterator = "abc".utf8.makeIterator()
        let result2 = iterator.nextAsciiDigit()
        #expect(result2 == nil)
    }

    @Test func nextAsciiLetter() {
        // Test basic letter
        var iterator = "abc".utf8.makeIterator()
        #expect(iterator.nextAsciiLetter() == UInt8(ascii: "a"))

        // Test with leading spaces and skipping whitespace
        iterator = "  abc".utf8.makeIterator()
        #expect(iterator.nextAsciiLetter(skippingWhitespace: true) == UInt8(ascii: "a"))

        // Test with leading spaces and not skipping whitespace
        iterator = "  abc".utf8.makeIterator()
        let result1 = iterator.nextAsciiLetter()
        #expect(result1 == nil)

        // Test with non-letter
        iterator = "123".utf8.makeIterator()
        let result2 = iterator.nextAsciiLetter()
        #expect(result2 == nil)

        // Test with uppercase
        iterator = "ABC".utf8.makeIterator()
        #expect(iterator.nextAsciiLetter() == UInt8(ascii: "A"))

        // Test with empty string
        iterator = "".utf8.makeIterator()
        let result3 = iterator.nextAsciiLetter()
        #expect(result3 == nil)
    }
}
