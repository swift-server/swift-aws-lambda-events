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

import Foundation
import Testing

@testable import AWSLambdaEvents

@Suite
struct DateWrapperTests {
    @Test func iSO8601CodingWrapperSuccess() throws {
        struct TestEvent: Decodable {
            @ISO8601Coding
            var date: Date
        }

        let json = #"{"date":"2020-03-26T16:53:05Z"}"#
        let event = try JSONDecoder().decode(TestEvent.self, from: json.data(using: .utf8)!)

        #expect(event.date == Date(timeIntervalSince1970: 1_585_241_585))
    }

    @Test func iSO8601CodingWrapperFailure() {
        struct TestEvent: Decodable {
            @ISO8601Coding
            var date: Date
        }

        let date = "2020-03-26T16:53:05"  // missing Z at end
        let json = #"{"date":"\#(date)"}"#
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(TestEvent.self, from: json.data(using: .utf8)!)
        }
    }

    @Test func iSO8601WithFractionalSecondsCodingWrapperSuccess() throws {
        struct TestEvent: Decodable {
            @ISO8601WithFractionalSecondsCoding
            var date: Date
        }

        let json = #"{"date":"2020-03-26T16:53:05.123Z"}"#
        let event = try JSONDecoder().decode(TestEvent.self, from: json.data(using: .utf8)!)

        #expect(abs(event.date.timeIntervalSince1970 - 1_585_241_585.123) < 0.001)
    }

    @Test func iSO8601WithFractionalSecondsCodingWrapperFailure() {
        struct TestEvent: Decodable {
            @ISO8601WithFractionalSecondsCoding
            var date: Date
        }

        let date = "2020-03-26T16:53:05Z"  // missing fractional seconds
        let json = #"{"date":"\#(date)"}"#
#if swift(<6.2)
        let error = (any Error).self
#else            
        let error = Never.self
#endif
        #expect(throws: error) {
                try JSONDecoder().decode(TestEvent.self, from: json.data(using: .utf8)!)
        }
    }

    @Test func rFC5322DateTimeCodingWrapperSuccess() throws {
        struct TestEvent: Decodable {
            @RFC5322DateTimeCoding
            var date: Date
        }

        let json = #"{"date":"Thu, 5 Apr 2012 23:47:37 +0200"}"#
        let event = try JSONDecoder().decode(TestEvent.self, from: json.data(using: .utf8)!)

        #expect(event.date.description == "2012-04-05 21:47:37 +0000")
    }

    @Test func rFC5322DateTimeCodingWrapperWithExtraTimeZoneSuccess() throws {
        struct TestEvent: Decodable {
            @RFC5322DateTimeCoding
            var date: Date
        }

        let json = #"{"date":"Fri, 26 Jun 2020 03:04:03 -0500 (CDT)"}"#
        let event = try JSONDecoder().decode(TestEvent.self, from: json.data(using: .utf8)!)

        #expect(event.date.description == "2020-06-26 08:04:03 +0000")
    }

    @Test func rFC5322DateTimeCodingWrapperWithAlphabeticTimeZoneSuccess() throws {
        struct TestEvent: Decodable {
            @RFC5322DateTimeCoding
            var date: Date
        }

        let json = #"{"date":"Fri, 26 Jun 2020 03:04:03 CDT"}"#
        let event = try JSONDecoder().decode(TestEvent.self, from: json.data(using: .utf8)!)

        #expect(event.date.description == "2020-06-26 08:04:03 +0000")
    }

    @Test func rFC5322DateTimeCodingWithoutDayWrapperSuccess() throws {
        struct TestEvent: Decodable {
            @RFC5322DateTimeCoding
            var date: Date
        }

        let json = #"{"date":"5 Apr 2012 23:47:37 +0200"}"#
        let event = try JSONDecoder().decode(TestEvent.self, from: json.data(using: .utf8)!)

        #expect(event.date.description == "2012-04-05 21:47:37 +0000")
    }

    @Test func rFC5322DateTimeCodingWrapperFailure() {
        struct TestEvent: Decodable {
            @RFC5322DateTimeCoding
            var date: Date
        }

        let date = "Thu, 5 Apr 2012 23:47 +0200"  // missing seconds
        let json = #"{"date":"\#(date)"}"#
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(TestEvent.self, from: json.data(using: .utf8)!)
        }
    }
}
