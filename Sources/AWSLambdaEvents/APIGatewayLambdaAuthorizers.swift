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

/// `LambdaAuthorizerContext` contains authorizer informations passed to a Lambda function authorizer
public typealias LambdaAuthorizerContext = [String: String]

/// `APIGatewayLambdaAuthorizerRequest` contains the payload sent to a Lambda Authorizer function
public struct APIGatewayLambdaAuthorizerRequest: Codable {
    public let version: String
    public let type: String
    public let routeArn: String?
    public let identitySource: [String]
    public let routeKey: String
    public let rawPath: String
    public let rawQueryString: String
    public let headers: [String: String]

    /// `Context` contains information to identify the AWS account and resources invoking the Lambda function.
    public struct Context: Codable {
        public struct HTTP: Codable {
            public let method: HTTPRequest.Method
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

/// `APIGatewayLambdaAuthorizerSimpleResponse` contains a simple response (yes/no) returned by a Lambda authorizer function
public struct APIGatewayLambdaAuthorizerSimpleResponse: Codable {
    public let isAuthorized: Bool
    public let context: LambdaAuthorizerContext?

    public init(isAuthorized: Bool,
                context: LambdaAuthorizerContext?) {
        self.isAuthorized = isAuthorized
        self.context = context
    }
}

/// `APIGatewayLambdaAuthorizerPolicyResponse` contains a Policy response (inc. an IAM policy document) returned by a Lambda authorizer function
public struct APIGatewayLambdaAuthorizerPolicyResponse: Codable {
    public let principalId: String

    /// `PolicyDocument` contains an IAM policy document
    public struct PolicyDocument: Codable {
        public let version: String

        public struct Statement: Codable {
            public enum Effect: String, Codable {
                case allow = "Allow"
                case deny = "Deny"
            }

            public let action: String
            public let effect: Effect
            public let resource: String

            public init(action: String, effect: Effect, resource: String) {
                self.action = action
                self.effect = effect
                self.resource = resource
            }

            public enum CodingKeys: String, CodingKey {
                case action = "Action"
                case effect = "Effect"
                case resource = "Resource"
            }
        }

        public let statement: [Statement]

        public init(version: String = "2012-10-17", statement: [Statement]) {
            self.version = version
            self.statement = statement
        }

        public enum CodingKeys: String, CodingKey {
            case version = "Version"
            case statement = "Statement"
        }
    }

    public let policyDocument: PolicyDocument

    public let context: LambdaAuthorizerContext?

    public init(principalId: String, policyDocument: PolicyDocument, context: LambdaAuthorizerContext?) {
        self.principalId = principalId
        self.policyDocument = policyDocument
        self.context = context
    }
}

#if swift(>=5.6)
extension LambdaAuthorizerContext: Sendable {}
extension APIGatewayLambdaAuthorizerRequest: Sendable {}
extension APIGatewayLambdaAuthorizerRequest.Context: Sendable {}
extension APIGatewayLambdaAuthorizerRequest.Context.HTTP: Sendable {}
extension APIGatewayLambdaAuthorizerSimpleResponse: Sendable {}
extension APIGatewayLambdaAuthorizerPolicyResponse: Sendable {}
extension APIGatewayLambdaAuthorizerPolicyResponse.PolicyDocument: Sendable {}
extension APIGatewayLambdaAuthorizerPolicyResponse.PolicyDocument.Statement: Sendable {}
extension APIGatewayLambdaAuthorizerPolicyResponse.PolicyDocument.Statement.Effect: Sendable {}
#endif
