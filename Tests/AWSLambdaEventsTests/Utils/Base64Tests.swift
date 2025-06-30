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

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

@Suite
struct Base64Tests {
    // MARK: - Decoding -

    @Test func decodeEmptyString() throws {
        let decoded = try "".base64decoded()
        #expect(decoded.count == 0)
    }

    @Test func base64DecodingArrayOfNulls() throws {
        let expected = Array(repeating: UInt8(0), count: 10)
        let decoded = try "AAAAAAAAAAAAAA==".base64decoded()
        #expect(decoded == expected)
    }

    @Test func base64DecodingAllTheBytesSequentially() throws {
        let base64 =
            "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn+AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq+wsbKztLW2t7i5uru8vb6/wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t/g4eLj5OXm5+jp6uvs7e7v8PHy8/T19vf4+fr7/P3+/w=="

        let expected = Array(UInt8(0)...UInt8(255))
        let decoded = try base64.base64decoded()

        #expect(decoded == expected)
    }

    @Test func base64UrlDecodingAllTheBytesSequentially() throws {
        let base64 =
            "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0-P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn-AgYKDhIWGh4iJiouMjY6PkJGSk5SVlpeYmZqbnJ2en6ChoqOkpaanqKmqq6ytrq-wsbKztLW2t7i5uru8vb6_wMHCw8TFxsfIycrLzM3Oz9DR0tPU1dbX2Nna29zd3t_g4eLj5OXm5-jp6uvs7e7v8PHy8_T19vf4-fr7_P3-_w=="

        let expected = Array(UInt8(0)...UInt8(255))
        let decoded = try base64.base64decoded(options: .base64UrlAlphabet)

        #expect(decoded == expected)
    }

    @Test func base64DecodingWithPoop() {
        #expect(throws: (any Error).self) {
            try "💩".base64decoded()
        }
    }

    @Test func base64DecodingWithInvalidLength() {
        #expect(throws: (any Error).self) {
            try "AAAAA".base64decoded()
        }
    }

    @Test func nSStringToDecode() {
        let test = "1234567"
        let nsstring = test.data(using: .utf8)!.base64EncodedString()

        #expect(throws: Never.self) { try nsstring.base64decoded() }
    }
}
