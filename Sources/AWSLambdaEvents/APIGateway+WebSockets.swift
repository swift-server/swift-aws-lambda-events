//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) YEARS Apple Inc. and the SwiftAWSLambdaRuntime project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAWSLambdaRuntime project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

/// `APIGatewayWebSocketRequest` is a variation of the`APIGatewayV2Request`
/// and contains data coming from the WebSockets API Gateway.
public struct APIGatewayWebSocketRequest: Codable {
    /// `Context` contains information to identify the AWS account and resources invoking the Lambda function.
    public struct Context: Codable {
        public struct Identity: Codable {
            let sourceIp: String
        }

        let routeKey: String
        let eventType: String
        let extendedRequestId: String
        /// The request time in format: 23/Apr/2020:11:08:18 +0000
        let requestTime: String
        let messageDirection: String
        let stage: String
        let connectedAt: UInt64
        let requestTimeEpoch: UInt64
        let identity: Identity
        let requestId: String
        let domainName: String
        let connectionId: String
        let apiId: String
    }

    public let headers: HTTPHeaders?
    public let multiValueHeaders: HTTPMultiValueHeaders?
    public let context: Context
    public let body: String?
    public let isBase64Encoded: Bool?

    enum CodingKeys: String, CodingKey {
        case headers
        case multiValueHeaders
        case context = "requestContext"
        case body
        case isBase64Encoded
    }
}

/// `APIGatewayWebSocketResponse` is a type alias for `APIGatewayV2Request`.
/// Typically, lambda WebSockets servers send clients data via
/// the ApiGatewayManagementApi mechanism. However, APIGateway does require
/// lambda servers to return some kind of status when APIGateway invokes them.
/// This can be as simple as always returning a 200 "OK" response for all
/// WebSockets requests (the ApiGatewayManagementApi can return any errors to
/// WebSockets clients).
public typealias APIGatewayWebSocketResponse = APIGatewayV2Response

#if swift(>=5.6)
extension APIGatewayWebSocketRequest: Sendable {}
extension APIGatewayWebSocketRequest.Context: Sendable {}
extension APIGatewayWebSocketRequest.Context.Identity: Sendable {}
#endif
