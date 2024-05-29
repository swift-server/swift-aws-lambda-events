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

// CloudFormation custom resource.
public enum CloudFormation: Sendable {
    // Request represents the request body of AWS::CloudFormation::CustomResource.
    // https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/crpg-ref-requests.html
    public struct Request<R: Decodable, O: Decodable>: Decodable {
        public enum RequestType: String, Decodable, Sendable {
            case create = "Create"
            case update = "Update"
            case delete = "Delete"
        }

        public let requestType: RequestType
        public let requestId: String
        public let responseURL: String
        public let physicalResourceId: String?
        public let logicalResourceId: String
        public let stackId: String
        public let resourceProperties: R?
        public let oldResourceProperties: O?

        enum CodingKeys: String, CodingKey {
            case requestType = "RequestType"
            case requestId = "RequestId"
            case responseURL = "ResponseURL"
            case physicalResourceId = "PhysicalResourceId"
            case logicalResourceId = "LogicalResourceId"
            case stackId = "StackId"
            case resourceProperties = "ResourceProperties"
            case oldResourceProperties = "OldResourceProperties"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.requestType = try container.decode(RequestType.self, forKey: .requestType)
            self.requestId = try container.decode(String.self, forKey: .requestId)
            self.responseURL = try container.decode(String.self, forKey: .responseURL)
            self.logicalResourceId = try container.decode(String.self, forKey: .logicalResourceId)
            self.stackId = try container.decode(String.self, forKey: .stackId)
            self.physicalResourceId = try container.decodeIfPresent(String.self, forKey: .physicalResourceId)
            self.resourceProperties = try container.decodeIfPresent(R.self, forKey: .resourceProperties)
            self.oldResourceProperties = try container.decodeIfPresent(O.self, forKey: .oldResourceProperties)
        }
    }

    // Response represents the response body of AWS::CloudFormation::CustomResource.
    // https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/crpg-ref-responses.html
    public struct Response<D: Encodable>: Encodable {
        public enum StatusType: String, Encodable, Sendable {
            case success = "SUCCESS"
            case failed = "FAILED"
        }

        public let status: StatusType
        public let requestId: String
        public let logicalResourceId: String
        public let stackId: String
        public let physicalResourceId: String?
        public let reason: String?
        public let noEcho: Bool?
        public let data: D?

        enum CodingKeys: String, CodingKey {
            case status = "Status"
            case requestId = "RequestId"
            case logicalResourceId = "LogicalResourceId"
            case stackId = "StackId"
            case physicalResourceId = "PhysicalResourceId"
            case reason = "Reason"
            case noEcho = "NoEcho"
            case data = "Data"
        }

        public init(
            status: StatusType,
            requestId: String,
            logicalResourceId: String,
            stackId: String,
            physicalResourceId: String?,
            reason: String?,
            noEcho: Bool?,
            data: D?
        ) {
            self.status = status
            self.requestId = requestId
            self.logicalResourceId = logicalResourceId
            self.stackId = stackId
            self.physicalResourceId = physicalResourceId
            self.reason = reason
            self.noEcho = noEcho
            self.data = data
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(self.status.rawValue, forKey: .status)
            try container.encode(self.requestId, forKey: .requestId)
            try container.encode(self.logicalResourceId, forKey: .logicalResourceId)
            try container.encode(self.stackId, forKey: .stackId)
            try container.encodeIfPresent(self.physicalResourceId, forKey: .physicalResourceId)
            try container.encodeIfPresent(self.reason, forKey: .reason)
            try container.encodeIfPresent(self.noEcho, forKey: .noEcho)
            try container.encodeIfPresent(self.data, forKey: .data)
        }
    }
}

extension CloudFormation.Request: Sendable where R: Sendable, O: Sendable {}
extension CloudFormation.Response: Sendable where D: Sendable {}
