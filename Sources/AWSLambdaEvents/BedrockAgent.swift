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

// https://docs.aws.amazon.com/bedrock/latest/userguide/agents-lambda.html#agents-lambda-input
public struct BedrockAgentRequest: Codable, Sendable {
    public let messageVersion: String
    public let agent: Agent?
    public let sessionId: String?
    public let sessionAttributes: [String: String]?
    public let promptSessionAttributes: [String: String]?
    public let inputText: String?
    public let apiPath: String?
    public let actionGroup: String?
    public let httpMethod: HTTPRequest.Method?
    public let parameters: [Parameter]?
    public let requestBody: RequestBody?

    public struct Agent: Codable, Sendable {
        public let alias: String
        public let name: String
        public let version: String
        public let id: String
    }

    public struct Parameter: Codable, Sendable {
        public let name: String
        public let type: String
        public let value: String
    }

    public struct RequestBody: Codable, Sendable {
        public let content: [String: Content]
        public struct Content: Codable, Sendable {
            public let properties: [Parameter]
        }
    }
}
