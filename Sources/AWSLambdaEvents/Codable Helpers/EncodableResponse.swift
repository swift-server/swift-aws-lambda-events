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
import FoundationEssentials
#else
import Foundation
#endif

public protocol EncodableResponse {
    static func encoding<T>(
        _ encodable: T,
        status: HTTPResponse.Status,
        using encoder: JSONEncoder,
        headers: HTTPHeaders?,
        cookies: [String]?,
        onError: ((Error) -> Self)
    ) -> Self where T: Encodable

    init(
        statusCode: HTTPResponse.Status,
        headers: HTTPHeaders?,
        body: String?,
        isBase64Encoded: Bool?,
        cookies: [String]?
    )
}

extension EncodableResponse {
    /// Encodes a given encodable object into a response object.
    ///
    /// - Parameters:
    ///   - encodable: The object to encode.
    ///   - status: The status code to use. Defaults to `ok`.
    ///   - encoder: The encoder to use. Defaults to a new `JSONEncoder`.
    ///   - onError: A closure to handle errors, and transform them into a `APIGatewayV2Response`.
    /// Defaults to converting the error into a 500 (Internal Server Error) response with the error message as
    /// the body.
    ///
    /// - Returns: a response object whose body is the encoded `encodable` type and with the
    /// other response parameters
    public static func encoding<T>(
        _ encodable: T,
        status: HTTPResponse.Status = .ok,
        using encoder: JSONEncoder = JSONEncoder(),
        headers: HTTPHeaders? = nil,
        cookies: [String]? = nil,
        onError: ((Error) -> Self) = Self.defaultErrorHandler
    ) -> Self where T: Encodable {
        do {
            let encodedResponse = try encoder.encode(encodable)
            return Self(
                statusCode: status,
                headers: headers,
                body: String(data: encodedResponse, encoding: .utf8),
                isBase64Encoded: nil,
                cookies: cookies
            )
        } catch {
            return onError(error)
        }
    }

    public static var defaultErrorHandler: ((Error) -> Self) {
        { error in
            Self(
                statusCode: .internalServerError,
                headers: nil,
                body: "Internal Server Error: \(String(describing: error))",
                isBase64Encoded: nil,
                cookies: nil
            )
        }
    }
}
