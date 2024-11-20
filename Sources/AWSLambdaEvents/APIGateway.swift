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

// https://docs.aws.amazon.com/lambda/latest/dg/services-apigateway.html
// https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html

/// `APIGatewayRequest` contains data coming from the API Gateway.
public struct APIGatewayRequest: Encodable, Sendable {
    public struct Context: Codable, Sendable {
        public struct Identity: Codable, Sendable {
            public let cognitoIdentityPoolId: String?

            public let apiKey: String?
            public let userArn: String?
            public let cognitoAuthenticationType: String?
            public let caller: String?
            public let userAgent: String?
            public let user: String?

            public let cognitoAuthenticationProvider: String?
            public let sourceIp: String?
            public let accountId: String?
        }

        public struct Authorizer: Codable, Sendable {
            public let claims: [String: String]?
        }

        public let resourceId: String
        public let apiId: String
        public let domainName: String?
        public let resourcePath: String
        public let httpMethod: String
        public let requestId: String
        public let accountId: String
        public let stage: String

        public let identity: Identity
        public let authorizer: Authorizer?
        public let extendedRequestId: String?
        public let path: String
    }

    public let resource: String
    public let path: String
    public let httpMethod: HTTPRequest.Method

    public let queryStringParameters: [String: String]
    public let multiValueQueryStringParameters: [String: [String]]
    public let headers: HTTPHeaders
    public let multiValueHeaders: HTTPMultiValueHeaders
    public let pathParameters: [String: String]
    public let stageVariables: [String: String]

    public let requestContext: Context
    public let body: String?
    public let isBase64Encoded: Bool
}

// MARK: - Response -

public struct APIGatewayResponse: Codable, Sendable {
    public var statusCode: HTTPResponse.Status
    public var headers: HTTPHeaders?
    public var multiValueHeaders: HTTPMultiValueHeaders?
    public var body: String?
    public var isBase64Encoded: Bool?

    public init(
        statusCode: HTTPResponse.Status,
        headers: HTTPHeaders? = nil,
        multiValueHeaders: HTTPMultiValueHeaders? = nil,
        body: String? = nil,
        isBase64Encoded: Bool? = nil
    ) {
        self.statusCode = statusCode
        self.headers = headers
        self.multiValueHeaders = multiValueHeaders
        self.body = body
        self.isBase64Encoded = isBase64Encoded
    }
}

extension APIGatewayRequest: Decodable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.resource = try container.decode(String.self, forKey: .resource)
        self.path = try container.decode(String.self, forKey: .path)
        self.httpMethod = try container.decode(HTTPRequest.Method.self, forKey: .httpMethod)

        self.queryStringParameters = try container.decodeIfPresent([String: String].self, forKey: .queryStringParameters) ?? [:]
        self.multiValueQueryStringParameters = try container.decodeIfPresent([String: [String]].self, forKey: .multiValueQueryStringParameters) ?? [:]
        self.headers = try container.decodeIfPresent(HTTPHeaders.self, forKey: .headers) ?? HTTPHeaders()
        self.multiValueHeaders = try container.decodeIfPresent(HTTPMultiValueHeaders.self, forKey: .multiValueHeaders) ?? HTTPMultiValueHeaders()
        self.pathParameters = try container.decodeIfPresent([String: String].self, forKey: .pathParameters) ?? [:]
        self.stageVariables = try container.decodeIfPresent([String: String].self, forKey: .stageVariables) ?? [:]

        self.requestContext = try container.decode(Context.self, forKey: .requestContext)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.isBase64Encoded = try container.decode(Bool.self, forKey: .isBase64Encoded)
    }
}
