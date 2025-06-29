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

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import Testing

@testable import AWSLambdaEvents

@Suite
struct RFC5322DateParseStrategyTests {
    let strategy = RFC5322DateParseStrategy(calendar: Calendar(identifier: .gregorian))

    @Test func success() {
        let input = "Fri, 26 Jun 2020 03:04:03 -0500 (CDT)"
        let date = try? strategy.parse(input)
        #expect(date != nil)
        #expect(date?.description == "2020-06-26 08:04:03 +0000")
    }

    @Test func someRandomDates() throws {
        let dates = [
            ("1 Jan 2020 00:00:00 +0000", "2020-01-01 00:00:00 +0000"),
            ("15 Feb 2020 01:02:03 GMT", "2020-02-15 01:02:03 +0000"),
            ("30 Mar 2020 02:03:04 UTC", "2020-03-30 02:03:04 +0000"),
            ("15 Apr 2020 03:04:05 -0500 (CDT)", "2020-04-15 08:04:05 +0000"),
            ("1 Jun 2020 04:05:06 -0600 (EDT)", "2020-06-01 10:05:06 +0000"),
            ("15 Jul 2020 05:06:07 -0700 (PDT)", "2020-07-15 12:06:07 +0000"),
            ("31 Aug 2020 12:07:08 -0200 (CEST)", "2020-08-31 14:07:08 +0000"),
            ("15 Sep 2020 07:08:09 -0900 (AKST)", "2020-09-15 16:08:09 +0000"),
            ("30 Oct 2020 08:09:10 -1000 (HST)", "2020-10-30 18:09:10 +0000"),
            ("15 Nov 2020 09:10:11 -1100 (AKST)", "2020-11-15 20:10:11 +0000"),
            ("30 Dec 2020 10:11:12 -1200 (HST)", "2020-12-30 22:11:12 +0000"),
        ]

        for (input, expected) in dates {
            let date = try strategy.parse(input)
            #expect(date.description == expected)
        }
    }

    @Test func withLeadingDayName() throws {
        let input = "Fri, 26 Jun 2020 03:04:03 -0500 (CDT)"
        let date = try strategy.parse(input)
        #expect("2020-06-26 08:04:03 +0000" == date.description)
    }

    @Test func emptyString() {
        let input = ""
        #expect(throws: (any Error).self) { try strategy.parse(input) }
    }

    @Test func withInvalidDay() {
        let input = "Fri, 36 Jun 2020 03:04:03 -0500 (CDT)"
        #expect(throws: (any Error).self) { try strategy.parse(input) }
    }

    @Test func withInvalidMonth() {
        let input = "Fri, 26 XXX 2020 03:04:03 -0500 (CDT)"
        #expect(throws: (any Error).self) { try strategy.parse(input) }
    }

    @Test func withInvalidHour() {
        let input = "Fri, 26 Jun 2020 48:04:03 -0500 (CDT)"
        #expect(throws: (any Error).self) { try strategy.parse(input) }
    }

    @Test func withInvalidMinute() {
        let input = "Fri, 26 Jun 2020 03:64:03 -0500 (CDT)"
        #expect(throws: (any Error).self) { try strategy.parse(input) }
    }

    @Test func withInvalidSecond() {
        let input = "Fri, 26 Jun 2020 03:04:64 -0500 (CDT)"
        #expect(throws: (any Error).self) { try strategy.parse(input) }
    }

    @Test func withGMT() throws {
        let input = "Fri, 26 Jun 2020 03:04:03 GMT"
        let date = try strategy.parse(input)
        #expect("2020-06-26 03:04:03 +0000" == date.description)
    }

    @Test func withUTC() throws {
        let input = "Fri, 26 Jun 2020 03:04:03 UTC"
        let date = try strategy.parse(input)
        #expect("2020-06-26 03:04:03 +0000" == date.description)
    }

    @Test func partialInput() {
        let input = "Fri, 26 Jun 20"
        #expect(throws: (any Error).self) { try strategy.parse(input) }
    }

    @Test func partialTimezone() {
        let input = "Fri, 26 Jun 2020 03:04:03 -05"
        #expect(throws: (any Error).self) { try strategy.parse(input) }
    }

    @Test func invalidTimezone() {
        let input = "Fri, 26 Jun 2020 03:04:03 -05CDT (CDT)"
        #expect(throws: (any Error).self) { try strategy.parse(input) }
    }
}
