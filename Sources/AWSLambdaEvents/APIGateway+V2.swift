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

/// `APIGatewayV2Request` contains data coming from the new HTTP API Gateway.
public struct APIGatewayV2Request: Encodable, Sendable {
    /// `Context` contains information to identify the AWS account and resources invoking the Lambda function.
    public struct Context: Codable, Sendable {
        public struct HTTP: Codable, Sendable {
            public let method: HTTPRequest.Method
            public let path: String
            public let `protocol`: String
            public let sourceIp: String
            public let userAgent: String
        }

        /// `Authorizer` contains authorizer information for the request context.
        public struct Authorizer: Codable, Sendable {
            /// `JWT` contains JWT authorizer information for the request context.
            public struct JWT: Codable, Sendable {
                public let claims: [String: String]?
                public let scopes: [String]?
            }

            public let jwt: JWT?

            // `IAM` contains AWS IAM authorizer information for the request context.
            public struct IAM: Codable, Sendable {
                public struct CognitoIdentity: Codable, Sendable {
                    public let amr: [String]?
                    public let identityId: String?
                    public let identityPoolId: String?
                }

                public let accessKey: String?
                public let accountId: String?
                public let callerId: String?
                public let cognitoIdentity: CognitoIdentity?
                public let principalOrgId: String?
                public let userArn: String?
                public let userId: String?
            }

            public let iam: IAM?

            public let lambda: LambdaAuthorizerContext?
        }

        public struct Authentication: Codable, Sendable {
            public struct ClientCert: Codable, Sendable {
                public struct Validity: Codable, Sendable {
                    public let notBefore: String
                    public let notAfter: String
                }

                public let clientCertPem: String
                public let subjectDN: String
                public let issuerDN: String
                public let serialNumber: String
                public let validity: Validity
            }

            public let clientCert: ClientCert?
        }

        public let accountId: String
        public let apiId: String
        public let domainName: String
        public let domainPrefix: String
        public let stage: String
        public let requestId: String

        public let http: HTTP
        public let authorizer: Authorizer?
        public let authentication: Authentication?

        /// The request time in format: 23/Apr/2020:11:08:18 +0000
        public let time: String
        public let timeEpoch: UInt64
    }

    public let version: String
    public let routeKey: String
    public let rawPath: String
    public let rawQueryString: String

    public let cookies: [String]
    public let headers: HTTPHeaders
    public let queryStringParameters: [String: String]
    public let pathParameters: [String: String]

    public let context: Context
    public let stageVariables: [String: String]

    public let body: String?
    public let isBase64Encoded: Bool

    enum CodingKeys: String, CodingKey {
        case version
        case routeKey
        case rawPath
        case rawQueryString

        case cookies
        case headers
        case queryStringParameters
        case pathParameters

        case context = "requestContext"
        case stageVariables

        case body
        case isBase64Encoded
    }
}

public struct APIGatewayV2Response: Codable, Sendable {
    public var statusCode: HTTPResponse.Status
    public var headers: HTTPHeaders?
    public var body: String?
    public var isBase64Encoded: Bool?
    public var cookies: [String]?

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
        self.isBase64Encoded = isBase64Encoded
        self.cookies = cookies
    }
}

extension APIGatewayV2Request: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.version = try container.decode(String.self, forKey: .version)
        self.routeKey = try container.decode(String.self, forKey: .routeKey)
        self.rawPath = try container.decode(String.self, forKey: .rawPath)
        self.rawQueryString = try container.decode(String.self, forKey: .rawQueryString)
    
        self.cookies = try container.decodeIfPresent([String].self, forKey: .cookies) ?? []
        self.headers = try container.decodeIfPresent(HTTPHeaders.self, forKey: .headers) ?? HTTPHeaders()
        self.queryStringParameters = try container.decodeIfPresent([String: String].self, forKey: .queryStringParameters) ?? [:]
        self.pathParameters = try container.decodeIfPresent([String: String].self, forKey: .pathParameters) ?? [:]
    
        self.context = try container.decode(Context.self, forKey: .context)
        self.stageVariables = try container.decodeIfPresent([String: String].self, forKey: .stageVariables) ?? [:]
    
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.isBase64Encoded = try container.decode(Bool.self, forKey: .isBase64Encoded)
    }
}
