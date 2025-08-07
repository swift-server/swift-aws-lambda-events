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

// https://docs.aws.amazon.com/lambda/latest/dg/urls-invocation.html

/// FunctionURLRequest contains data coming from a bare Lambda Function URL
public struct FunctionURLRequest: Codable, Sendable {
    public struct Context: Codable, Sendable {
        public struct Authorizer: Codable, Sendable {
            public struct IAMAuthorizer: Codable, Sendable {
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

        public struct HTTP: Codable, Sendable {
            public let method: HTTPRequest.Method
            public let path: String
            public let `protocol`: String
            public let sourceIp: String
            public let userAgent: String
        }

        public let accountId: String
        public let apiId: String
        public let authentication: String?
        public let authorizer: Authorizer?
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
    public let cookies: [String]?
    public let headers: HTTPHeaders
    public let queryStringParameters: [String: String]?

    public let requestContext: Context

    public let body: String?
    public let pathParameters: [String: String]?
    public let isBase64Encoded: Bool

    public let stageVariables: [String: String]?
}

extension FunctionURLRequest: DecodableRequest {}

// MARK: - Response -

public struct FunctionURLResponse: Codable, Sendable {
    public var statusCode: HTTPResponse.Status
    public var headers: HTTPHeaders?
    public var body: String?
    public let cookies: [String]?
    public var isBase64Encoded: Bool?

    @available(*, deprecated, message: "Use init(statusCode:headers:body:isBase64Encoded:cookies:) instead")
    @_disfavoredOverload
    public init(
        statusCode: HTTPResponse.Status,
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

    public init(
        statusCode: HTTPResponse.Status,
        headers: HTTPHeaders? = nil,
        body: String? = nil,
        isBase64Encoded: Bool? = nil,
        cookies: [String]? = nil
    ) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
        self.cookies = cookies
        self.isBase64Encoded = isBase64Encoded
    }
}

extension FunctionURLResponse: EncodableResponse {}
