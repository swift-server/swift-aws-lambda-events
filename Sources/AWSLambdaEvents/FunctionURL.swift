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

import class Foundation.JSONEncoder

// https://docs.aws.amazon.com/lambda/latest/dg/urls-invocation.html

/// FunctionURLRequest contains data coming from a bare Lambda Function URL
public struct FunctionURLRequest: Codable {
    public struct Context: Codable {
        public struct Authorizer: Codable {
            public struct IAMAuthorizer: Codable {
                public let accessKey: String

                public let accountId: String
                public let callerId: String
                public let cognitoIdentity: String?

                public let principalOrgId: String?

                public let userArn: String
                public let userId: String
            }

            public let iam: IAMAuthorizer?
        }

        public struct HTTP: Codable {
            public let method: String
            public let path: String
            public let `protocol`: String
            public let sourceIp: String
            public let userAgent: String
        }

        public let accountId: String
        public let apiId: String
        public let authentication: String?
        public let authorizer: Authorizer
        public let domainName: String
        public let domainPrefix: String
        public let http: HTTP

        public let requestId: String
        public let routeKey: String
        public let stage: String

        public let time: String
        public let timeEpoch: Int
    }

    public let version: String

    public let routeKey: String
    public let rawPath: String
    public let rawQueryString: String
    public let cookies: [String]
    public let headers: HTTPHeaders
    public let queryStringParameters: [String: String]?

    public let requestContext: Context

    public let body: String?
    public let pathParameters: [String: String]?
    public let isBase64Encoded: Bool

    public let stageVariables: [String: String]?
}

// MARK: - Response -

public struct FunctionURLResponse: Codable {
    public var statusCode: HTTPResponseStatus
    public var headers: HTTPHeaders?
    public var body: String?
    public let cookies: [String]?
    public var isBase64Encoded: Bool?

    public init(
        statusCode: HTTPResponseStatus,
        headers: HTTPHeaders? = nil,
        body: String? = nil,
        cookies: [String]? = nil,
        isBase64Encoded: Bool? = nil
    ) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
        self.cookies = cookies
        self.isBase64Encoded = isBase64Encoded
    }
}

#if swift(>=5.6)
extension FunctionURLRequest: Sendable {}
extension FunctionURLRequest.Context: Sendable {}
extension FunctionURLRequest.Context.Authorizer: Sendable {}
extension FunctionURLRequest.Context.Authorizer.IAMAuthorizer: Sendable {}
extension FunctionURLRequest.Context.HTTP: Sendable {}
extension FunctionURLResponse: Sendable {}
#endif
