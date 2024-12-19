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

struct RFC5322DateParsingError: Error {}

struct RFC5322DateParseStrategy {

    let calendar: Calendar

    init(calendar: Calendar = Calendar(identifier: .gregorian)) {
        self.calendar = calendar
    }

    func parse(_ input: String) throws -> Date {
        guard let components = self.components(from: input) else {
            throw RFC5322DateParsingError()
        }
        guard let date = components.date else {
            throw RFC5322DateParsingError()
        }
        return date
    }

    func components(from input: String) -> DateComponents? {
        var endIndex = input.endIndex
        // If the date string has a timezone in brackets, we need to remove it before parsing.
        if let bracket = input.firstIndex(of: "(") {
            endIndex = bracket
        }
        var s = input[input.startIndex..<endIndex]

        let asciiDigits = UInt8(ascii: "0")...UInt8(ascii: "9")

        return s.withUTF8 { buffer -> DateComponents? in
            func parseDay(_ it: inout UnsafeBufferPointer<UInt8>.Iterator) -> Int? {
                let first = it.next()
                let second = it.next()
                guard let first = first, let second = second else { return nil }

                guard asciiDigits.contains(first) else { return nil }

                let day: Int
                if asciiDigits.contains(second) {
                    day = Int(first - UInt8(ascii: "0")) * 10 + Int(second - UInt8(ascii: "0"))
                } else {
                    day = Int(first - UInt8(ascii: "0"))
                }

                guard self.calendar.maximumRange(of: .day)!.contains(day) else { return nil }

                return day
            }

            func parseMonth(_ it: inout UnsafeBufferPointer<UInt8>.Iterator) -> Int? {
                let first = it.nextAsciiLetter(skippingWhitespace: true)
                let second = it.nextAsciiLetter()
                let third = it.nextAsciiLetter()
                guard let first = first, let second = second, let third = third else { return nil }
                guard first.isAsciiLetter else { return nil }
                guard let month = monthMap[[first, second, third]] else { return nil }
                guard self.calendar.maximumRange(of: .month)!.contains(month) else { return nil }
                return month
            }

            func parseYear(_ it: inout UnsafeBufferPointer<UInt8>.Iterator) -> Int? {
                let first = it.nextAsciiDigit(skippingWhitespace: true)
                let second = it.nextAsciiDigit()
                let third = it.nextAsciiDigit()
                let fourth = it.nextAsciiDigit()
                guard let first = first,
                    let second = second,
                    let third = third,
                    let fourth = fourth
                else { return nil }
                return Int(first - UInt8(ascii: "0")) * 1000
                    + Int(second - UInt8(ascii: "0")) * 100
                    + Int(third - UInt8(ascii: "0")) * 10
                    + Int(fourth - UInt8(ascii: "0"))
            }

            func parseHour(_ it: inout UnsafeBufferPointer<UInt8>.Iterator) -> Int? {
                let first = it.nextAsciiDigit(skippingWhitespace: true)
                let second = it.nextAsciiDigit()
                guard let first = first, let second = second else { return nil }
                let hour = Int(first - UInt8(ascii: "0")) * 10 + Int(second - UInt8(ascii: "0"))
                guard self.calendar.maximumRange(of: .hour)!.contains(hour) else { return nil }
                return hour
            }

            func parseMinute(_ it: inout UnsafeBufferPointer<UInt8>.Iterator) -> Int? {
                let first = it.nextAsciiDigit(skippingWhitespace: true)
                let second = it.nextAsciiDigit()
                guard let first = first, let second = second else { return nil }
                let minute = Int(first - UInt8(ascii: "0")) * 10 + Int(second - UInt8(ascii: "0"))
                guard self.calendar.maximumRange(of: .minute)!.contains(minute) else { return nil }
                return minute
            }

            func parseSecond(_ it: inout UnsafeBufferPointer<UInt8>.Iterator) -> Int? {
                let first = it.nextAsciiDigit(skippingWhitespace: true)
                let second = it.nextAsciiDigit()
                guard let first = first, let second = second else { return nil }
                let value = Int(first - UInt8(ascii: "0")) * 10 + Int(second - UInt8(ascii: "0"))
                guard self.calendar.maximumRange(of: .second)!.contains(value) else { return nil }
                return value
            }

            func parseTimezone(_ it: inout UnsafeBufferPointer<UInt8>.Iterator) -> Int? {
                let plusMinus = it.nextSkippingWhitespace()
                if let plusMinus, plusMinus == UInt8(ascii: "+") || plusMinus == UInt8(ascii: "-") {
                    let hour = parseHour(&it)
                    let minute = parseMinute(&it)
                    guard let hour = hour, let minute = minute else { return nil }
                    return (hour * 60 + minute) * (plusMinus == UInt8(ascii: "+") ? 1 : -1)
                } else if let first = plusMinus {
                    let second = it.nextAsciiLetter()
                    let third = it.nextAsciiLetter()

                    guard let second = second, let third = third else { return nil }
                    let abbr = [first, second, third]
                    return timezoneOffsetMap[abbr]
                }

                return nil
            }

            var it = buffer.makeIterator()

            // if the 4th character is a comma, then we have a day of the week
            guard buffer.count > 5 else { return nil }

            if buffer[3] == UInt8(ascii: ",") {
                for _ in 0..<5 {
                    _ = it.next()
                }
            }

            guard let day = parseDay(&it) else { return nil }
            guard let month = parseMonth(&it) else { return nil }
            guard let year = parseYear(&it) else { return nil }

            guard let hour = parseHour(&it) else { return nil }
            guard it.expect(UInt8(ascii: ":")) else { return nil }
            guard let minute = parseMinute(&it) else { return nil }
            guard it.expect(UInt8(ascii: ":")) else { return nil }
            guard let second = parseSecond(&it) else { return nil }

            guard let timezoneOffsetMinutes = parseTimezone(&it) else { return nil }

            return DateComponents(
                calendar: self.calendar,
                timeZone: TimeZone(secondsFromGMT: timezoneOffsetMinutes * 60),
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second
            )
        }
    }
}

#if canImport(FoundationEssentials)
@available(macOS 12.0, *)
extension RFC5322DateParseStrategy: ParseStrategy {}
#endif

extension IteratorProtocol where Self.Element == UInt8 {
    mutating func expect(_ expected: UInt8) -> Bool {
        guard self.next() == expected else { return false }
        return true
    }

    mutating func nextSkippingWhitespace() -> UInt8? {
        while let c = self.next() {
            if c != UInt8(ascii: " ") {
                return c
            }
        }
        return nil
    }

    mutating func nextAsciiDigit(skippingWhitespace: Bool = false) -> UInt8? {
        while let c = self.next() {
            if skippingWhitespace {
                if c == UInt8(ascii: " ") {
                    continue
                }
            }
            switch c {
            case UInt8(ascii: "0")...UInt8(ascii: "9"): return c
            default: return nil
            }
        }
        return nil
    }

    mutating func nextAsciiLetter(skippingWhitespace: Bool = false) -> UInt8? {
        while let c = self.next() {
            if skippingWhitespace {
                if c == UInt8(ascii: " ") {
                    continue
                }
            }

            switch c {
            case UInt8(ascii: "A")...UInt8(ascii: "Z"),
                UInt8(ascii: "a")...UInt8(ascii: "z"):
                return c
            default: return nil
            }
        }
        return nil
    }
}

extension UInt8 {
    var isAsciiLetter: Bool {
        switch self {
        case UInt8(ascii: "A")...UInt8(ascii: "Z"),
            UInt8(ascii: "a")...UInt8(ascii: "z"):
            return true
        default: return false
        }
    }
}

let monthMap: [[UInt8]: Int] = [
    Array("Jan".utf8): 1,
    Array("Feb".utf8): 2,
    Array("Mar".utf8): 3,
    Array("Apr".utf8): 4,
    Array("May".utf8): 5,
    Array("Jun".utf8): 6,
    Array("Jul".utf8): 7,
    Array("Aug".utf8): 8,
    Array("Sep".utf8): 9,
    Array("Oct".utf8): 10,
    Array("Nov".utf8): 11,
    Array("Dec".utf8): 12,
]

let timezoneOffsetMap: [[UInt8]: Int] = [
    Array("UTC".utf8): 0,
    Array("GMT".utf8): 0,
    Array("EDT".utf8): -4 * 60,
    Array("CDT".utf8): -5 * 60,
    Array("MDT".utf8): -6 * 60,
    Array("PDT".utf8): -7 * 60,
]
