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

// MARK: HTTPHeaders

import HTTPTypes

public typealias HTTPHeaders = [String: String]
public typealias HTTPMultiValueHeaders = [String: [String]]

extension HTTPHeaders {
    /// Retrieves the first value for a given header-field / dictionary-key (`name`) from the block.
    /// This method uses case-insensitive comparisons.
    ///
    /// - Parameter name: The header field name whose first value should be retrieved.
    /// - Returns: The first value for the header field name.
    public func first(name: String) -> String? {
        guard !self.isEmpty else {
            return nil
        }

        return self.first { header in header.0.isEqualCaseInsensitiveASCIIBytes(to: name) }?.1
    }
}

extension String {
    func isEqualCaseInsensitiveASCIIBytes(to: String) -> Bool {
        self.utf8.compareCaseInsensitiveASCIIBytes(to: to.utf8)
    }
}

extension String.UTF8View {
    /// Compares the collection of `UInt8`s to a case insensitive collection.
    ///
    /// This collection could be get from applying the `UTF8View`
    ///   property on the string protocol.
    ///
    /// - Parameter bytes: The string constant in the form of a collection of `UInt8`
    /// - Returns: Whether the collection contains **EXACTLY** this array or no, but by ignoring case.
    func compareCaseInsensitiveASCIIBytes(to: String.UTF8View) -> Bool {
        // fast path: we can get the underlying bytes of both
        let maybeMaybeResult = self.withContiguousStorageIfAvailable { lhsBuffer -> Bool? in
            to.withContiguousStorageIfAvailable { rhsBuffer in
                if lhsBuffer.count != rhsBuffer.count {
                    return false
                }

                for idx in 0 ..< lhsBuffer.count {
                    // let's hope this gets vectorised ;)
                    if lhsBuffer[idx] & 0xDF != rhsBuffer[idx] & 0xDF {
                        return false
                    }
                }
                return true
            }
        }

        if let maybeResult = maybeMaybeResult, let result = maybeResult {
            return result
        } else {
            return self.elementsEqual(to, by: { ($0 & 0xDF) == ($1 & 0xDF) })
        }
    }
}

extension HTTPResponse.Status: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.code)
    }

    public init(from decoder: any Decoder) throws {
        let code = try decoder.singleValueContainer().decode(Int.self)
        self.init(code: code)
    }
}

extension HTTPRequest.Method: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawMethod = try container.decode(String.self)
        guard let method = HTTPRequest.Method(rawMethod) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "\"\(rawMethod)\" is not a valid method")
        }

        self = method
    }
}
