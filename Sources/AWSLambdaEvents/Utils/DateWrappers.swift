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

#if compiler(>=5.6)
@preconcurrency import struct Foundation.Date
#else
import struct Foundation.Date
#endif
import class Foundation.DateFormatter
import struct Foundation.Locale
import struct Foundation.TimeZone

@propertyWrapper
public struct ISO8601Coding: AWSLambdaEvent {
    public let wrappedValue: Date

    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        guard let date = Self.dateFormatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription:
                "Expected date to be in ISO8601 date format, but `\(dateString)` is not in the correct format")
        }
        self.wrappedValue = date
    }

    private static let dateFormatter: DateFormatter = Self.createDateFormatter()

    private static func createDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }
}

@propertyWrapper
public struct ISO8601WithFractionalSecondsCoding: AWSLambdaEvent {
    public let wrappedValue: Date

    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        guard let date = Self.dateFormatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription:
                "Expected date to be in ISO8601 date format with fractional seconds, but `\(dateString)` is not in the correct format")
        }
        self.wrappedValue = date
    }

    private static let dateFormatter: DateFormatter = Self.createDateFormatter()

    private static func createDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return formatter
    }
}

@propertyWrapper
public struct RFC5322DateTimeCoding: AWSLambdaEvent {
    public let wrappedValue: Date

    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        var string = try container.decode(String.self)
        // RFC5322 dates sometimes have the alphabetic version of the timezone in brackets after the numeric version. The date formatter
        // fails to parse this so we need to remove this before parsing.
        if let bracket = string.firstIndex(of: "(") {
            string = String(string[string.startIndex ..< bracket].trimmingCharacters(in: .whitespaces))
        }
        for formatter in Self.dateFormatters {
            if let date = formatter.date(from: string) {
                self.wrappedValue = date
                return
            }
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription:
            "Expected date to be in RFC5322 date-time format, but `\(string)` is not in the correct format")
    }

    private static let dateFormatters: [DateFormatter] = Self.createDateFormatters()
    private static func createDateFormatters() -> [DateFormatter] {
        // rfc5322 dates received in SES mails sometimes do not include the day, so need two dateformatters
        // one with a day and one without
        let formatterWithDay = DateFormatter()
        formatterWithDay.dateFormat = "EEE, d MMM yyy HH:mm:ss z"
        formatterWithDay.locale = Locale(identifier: "en_US_POSIX")
        let formatterWithoutDay = DateFormatter()
        formatterWithoutDay.dateFormat = "d MMM yyy HH:mm:ss z"
        formatterWithoutDay.locale = Locale(identifier: "en_US_POSIX")
        return [formatterWithDay, formatterWithoutDay]
    }
}
