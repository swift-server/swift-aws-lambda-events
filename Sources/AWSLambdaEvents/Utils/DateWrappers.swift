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

@propertyWrapper
public struct ISO8601Coding: Decodable, Sendable {
    public let wrappedValue: Date

    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)

        guard let date = Self.parseISO8601(dateString: dateString) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription:
                    "Expected date to be in ISO8601 date format, but `\(dateString)` is not in the correct format"
            )
        }

        self.wrappedValue = date
    }

    private static func parseISO8601(dateString: String) -> Date? {
        #if canImport(FoundationEssentials)
        return try? Date(dateString, strategy: .iso8601)
        #else
        return Self.dateFormatter.date(from: dateString)
        #endif
    }

    #if !canImport(FoundationEssentials)
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter
    }
    #endif
}

@propertyWrapper
public struct ISO8601WithFractionalSecondsCoding: Decodable, Sendable {
    public let wrappedValue: Date

    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)

        guard let date = Self.parseISO8601WithFractionalSeconds(dateString: dateString) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription:
                    "Expected date to be in ISO8601 date format with fractional seconds, but `\(dateString)` is not in the correct format"
            )
        }

        self.wrappedValue = date
    }

    private static func parseISO8601WithFractionalSeconds(dateString: String) -> Date? {
        #if canImport(FoundationEssentials)
        return try? Date(dateString, strategy: Self.iso8601WithFractionalSeconds)
        #else
        return Self.dateFormatter.date(from: dateString)
        #endif
    }

    #if canImport(FoundationEssentials)
    private static var iso8601WithFractionalSeconds: Date.ISO8601FormatStyle {
        Date.ISO8601FormatStyle(includingFractionalSeconds: true)
    }
    #else
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return formatter
    }
    #endif
}

@propertyWrapper
public struct RFC5322DateTimeCoding: Decodable, Sendable {
    public let wrappedValue: Date

    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        do {
            #if canImport(FoundationEssentials)
            self.wrappedValue = try Date(string, strategy: Self.rfc5322DateParseStrategy)
            #else
            self.wrappedValue = try Self.rfc5322DateParseStrategy.parse(string)
            #endif
        } catch {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription:
                    "Expected date to be in RFC5322 date-time format, but `\(string)` is not in the correct format"
            )
        }
    }

    private static var rfc5322DateParseStrategy: RFC5322DateParseStrategy {
        RFC5322DateParseStrategy(calendar: Calendar(identifier: .gregorian))
    }
}
