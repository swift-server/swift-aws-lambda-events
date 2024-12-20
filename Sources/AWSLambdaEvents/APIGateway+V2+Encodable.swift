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
import class FoundationEssentials.Data
#else
import class Foundation.JSONEncoder
import struct Foundation.Data
#endif

public enum APIGatewayResponseError: Error {
    case failedToEncodeBody(Error)
}

extension APIGatewayV2Response {

    public init<Input: Encodable>(
        statusCode: HTTPResponse.Status,
        headers: HTTPHeaders? = nil,
        body: Input,
        isBase64Encoded: Bool? = nil,
        cookies: [String]? = nil
    ) throws {
        let encodedBody: Data
        do {
            encodedBody = try JSONEncoder().encode(body)
        } catch {
            throw APIGatewayResponseError.failedToEncodeBody(error)
        }
        self.statusCode = statusCode
        self.headers = headers
        self.body = String(data: encodedBody, encoding: .utf8) ?? ""
        self.isBase64Encoded = isBase64Encoded
        self.cookies = cookies
    }
}
