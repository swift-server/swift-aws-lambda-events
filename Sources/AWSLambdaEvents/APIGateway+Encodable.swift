//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) 2017-2022 Apple Inc. and the SwiftAWSLambdaRuntime project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAWSLambdaRuntime project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import HTTPTypes

#if canImport(FoundationEssentials)
import class FoundationEssentials.JSONEncoder
import struct FoundationEssentials.Data
#else
import class Foundation.JSONEncoder
import struct Foundation.Data
#endif

extension Encodable {
    fileprivate func string() throws -> String {
        let encoded = try JSONEncoder().encode(self)
        return String(decoding: encoded, as: UTF8.self)
    }
}

extension APIGatewayResponse {

    public init<Input: Encodable>(
        body: Input,
        statusCode: HTTPResponse.Status,
        headers: HTTPHeaders? = nil,
        multiValueHeaders: HTTPMultiValueHeaders? = nil
    ) throws {
        self.init(
            statusCode: statusCode,
            headers: headers,
            multiValueHeaders: multiValueHeaders,
            body: try body.string(),
            isBase64Encoded: nil
        )
    }
}

extension APIGatewayV2Response {

    public init<Input: Encodable>(
        body: Input,
        statusCode: HTTPResponse.Status,
        headers: HTTPHeaders? = nil,
        cookies: [String]? = nil
    ) throws {
        self.init(
            statusCode: statusCode,
            headers: headers,
            body: try body.string(),
            isBase64Encoded: nil,
            cookies: cookies
        )
    }
}
