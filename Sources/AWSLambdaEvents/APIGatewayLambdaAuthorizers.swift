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

/// `LambdaAuthorizerContext` contains authorizer informations passed to a Lambda function authorizer
public typealias LambdaAuthorizerContext = [String: String]

public struct APIGatewayLambdaAuthorizerRequest: Codable {
    let version: String
    let type: String
    let routeArn: String?
    let identitySource: [String]
    let routeKey: String
    let rawPath: String
    let rawQueryString: String
    let headers: [String: String]

    /// `Context` contains information to identify the AWS account and resources invoking the Lambda function.
    public struct Context: Codable {
        public struct HTTP: Codable {
            public let method: HTTPMethod
            public let path: String
            public let `protocol`: String
            public let sourceIp: String
            public let userAgent: String
        }

        public let accountId: String
        public let apiId: String
        public let domainName: String
        public let domainPrefix: String
        public let stage: String
        public let requestId: String

        public let http: HTTP

        /// The request time in format: 23/Apr/2020:11:08:18 +0000
        public let time: String
        public let timeEpoch: UInt64
    }

    let requestContext: Context?
}

public struct APIGatewayLambdaAuthorizerResponse: Codable {
    public let isAuthorized: Bool
    public let context: LambdaAuthorizerContext?
}

#if swift(>=5.6)
extension LambdaAuthorizerContext: Sendable {}
extension APIGatewayLambdaAuthorizerRequest: Sendable {}
extension APIGatewayLambdaAuthorizerRequest.Context: Sendable {}
extension APIGatewayLambdaAuthorizerRequest.Context.HTTP: Sendable {}
extension APIGatewayLambdaAuthorizerResponse: Sendable {}
#endif
