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

// https://github.com/aws/aws-lambda-go/blob/main/events/alb.go
/// `ALBTargetGroupRequest` contains data originating from the ALB Lambda target group integration.
public struct ALBTargetGroupRequest: Codable, Sendable {
    /// `Context` contains information to identify the load balancer invoking the lambda.
    public struct Context: Codable, Sendable {
        public let elb: ELBContext
    }

    public let httpMethod: HTTPRequest.Method
    public let path: String
    public let queryStringParameters: [String: String]

    /// Depending on your configuration of your target group either ``headers`` or ``multiValueHeaders``
    /// are set.
    ///
    /// For more information visit:
    /// https://docs.aws.amazon.com/elasticloadbalancing/latest/application/lambda-functions.html#multi-value-headers
    public let headers: HTTPHeaders?

    /// Depending on your configuration of your target group either ``headers`` or ``multiValueHeaders``
    /// are set.
    ///
    /// For more information visit:
    /// https://docs.aws.amazon.com/elasticloadbalancing/latest/application/lambda-functions.html#multi-value-headers
    public let multiValueHeaders: HTTPMultiValueHeaders?
    public let requestContext: Context
    public let isBase64Encoded: Bool
    public let body: String?

    /// `ELBContext` contains information to identify the ARN invoking the lambda.
    public struct ELBContext: Codable, Sendable {
        public let targetGroupArn: String
    }
}

public struct ALBTargetGroupResponse: Codable, Sendable {
    public var statusCode: HTTPResponse.Status
    public var statusDescription: String?
    public var headers: HTTPHeaders?
    public var multiValueHeaders: HTTPMultiValueHeaders?
    public var body: String
    public var isBase64Encoded: Bool

    public init(
        statusCode: HTTPResponse.Status,
        statusDescription: String? = nil,
        headers: HTTPHeaders? = nil,
        multiValueHeaders: HTTPMultiValueHeaders? = nil,
        body: String = "",
        isBase64Encoded: Bool = false
    ) {
        self.statusCode = statusCode
        self.statusDescription = statusDescription
        self.headers = headers
        self.multiValueHeaders = multiValueHeaders
        self.body = body
        self.isBase64Encoded = isBase64Encoded
    }
}
