//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) 2017-2020 Apple Inc. and the SwiftAWSLambdaRuntime project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAWSLambdaRuntime project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Testing

@testable import AWSLambdaEvents

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

@Suite
struct CloudFormationTests {
    struct TestResourceProperties: Codable {
        let property1: String
        let property2: String
        let property3: [String]
        let property4: String?
    }

    struct EmptyTestResourceProperties: Codable {}

    static func eventBodyRequestRequiredFields() -> String {
        """
        {
          "RequestType": "Create",
          "RequestId": "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c",
          "StackId": "arn:aws:cloudformation:us-east-1:123456789:stack/TestStack",
          "ResponseURL": "http://localhost:7000/response/test",
          "LogicalResourceId": "TestLogicalResource"
        }
        """
    }

    static func eventBodyRequestCreate() -> String {
        """
        {
          "RequestType": "Create",
          "RequestId": "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c",
          "StackId": "arn:aws:cloudformation:us-east-1:123456789:stack/TestStack",
          "ResponseURL": "http://localhost:7000/response/test",
          "LogicalResourceId": "TestLogicalResource",
          "PhysicalResourceId": "TestPhysicalResource",
          "ResourceProperties": {
            "property1": "value1",
            "property2": "",
            "property3": ["1", "2", "3"],
            "property4": null,
          }
        }
        """
    }

    static func eventBodyRequestUpdate() -> String {
        """
        {
          "RequestType": "Update",
          "RequestId": "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c",
          "StackId": "arn:aws:cloudformation:us-east-1:123456789:stack/TestStack",
          "ResponseURL": "http://localhost:7000/response/test",
          "LogicalResourceId": "TestLogicalResource",
          "PhysicalResourceId": "TestPhysicalResource",
          "ResourceProperties": {
            "property1": "value1",
            "property2": "value2",
            "property3": ["1", "2", "3"],
            "property4": "value4",
          },
          "OldResourceProperties": {
            "property1": "value1",
            "property2": "",
            "property3": ["1", "2", "3"],
            "property4": null,
          }
        }
        """
    }

    static func eventBodyResponse() -> String {
        "{\"Data\":{\"property1\":\"value1\",\"property2\":\"\",\"property3\":[\"1\",\"2\",\"3\"]},\"LogicalResourceId\":\"TestLogicalResource\",\"NoEcho\":false,\"PhysicalResourceId\":\"TestPhysicalResource\",\"Reason\":\"See the details in CloudWatch Log Stream\",\"RequestId\":\"cdc73f9d-aea9-11e3-9d5a-835b769c0d9c\",\"StackId\":\"arn:aws:cloudformation:us-east-1:123456789:stack\\/TestStack\",\"Status\":\"SUCCESS\"}"
    }

    @Test func decodeRequestRequiredFieldsFromJSON() throws {
        let eventBody = CloudFormationTests.eventBodyRequestRequiredFields()
        let data = eventBody.data(using: .utf8)!
        let event: CloudFormation.Request<EmptyTestResourceProperties, EmptyTestResourceProperties>? = try JSONDecoder()
            .decode(CloudFormation.Request.self, from: data)

        guard let event else {
            Issue.record("Expected to have an event")
            return
        }

        #expect(event.requestId == "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        #expect(event.requestType == CloudFormation.Request.RequestType.create)
        #expect(event.stackId == "arn:aws:cloudformation:us-east-1:123456789:stack/TestStack")
        #expect(event.responseURL == "http://localhost:7000/response/test")
        #expect(event.logicalResourceId == "TestLogicalResource")
        #expect(event.physicalResourceId == nil)
        #expect(event.resourceProperties == nil)
        #expect(event.oldResourceProperties == nil)
    }

    @Test func decodeRequestCreateFromJSON() throws {
        let eventBody = CloudFormationTests.eventBodyRequestCreate()
        let data = eventBody.data(using: .utf8)!
        let event: CloudFormation.Request<TestResourceProperties, EmptyTestResourceProperties>? = try? JSONDecoder()
            .decode(CloudFormation.Request.self, from: data)

        guard let event else {
            Issue.record("Expected to have an event")
            return
        }

        #expect(event.requestId == "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        #expect(event.requestType == CloudFormation.Request.RequestType.create)
        #expect(event.stackId == "arn:aws:cloudformation:us-east-1:123456789:stack/TestStack")
        #expect(event.responseURL == "http://localhost:7000/response/test")
        #expect(event.logicalResourceId == "TestLogicalResource")
        #expect(event.physicalResourceId == "TestPhysicalResource")
        #expect(event.resourceProperties?.property1 == "value1")
        #expect(event.resourceProperties?.property2 == "")
        #expect(event.resourceProperties?.property3 == ["1", "2", "3"])
        #expect(event.resourceProperties?.property4 == nil)
        #expect(event.oldResourceProperties == nil)
    }

    @Test func decodeRequestUpdateFromJSON() throws {
        let eventBody = CloudFormationTests.eventBodyRequestUpdate()
        let data = eventBody.data(using: .utf8)!
        let event: CloudFormation.Request<TestResourceProperties, TestResourceProperties>? = try? JSONDecoder().decode(
            CloudFormation.Request.self,
            from: data
        )

        guard let event else {
            Issue.record("Expected to have an event")
            return
        }

        #expect(event.requestId == "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        #expect(event.requestType == CloudFormation.Request.RequestType.update)
        #expect(event.stackId == "arn:aws:cloudformation:us-east-1:123456789:stack/TestStack")
        #expect(event.responseURL == "http://localhost:7000/response/test")
        #expect(event.logicalResourceId == "TestLogicalResource")
        #expect(event.physicalResourceId == "TestPhysicalResource")
        #expect(event.resourceProperties?.property1 == "value1")
        #expect(event.resourceProperties?.property2 == "value2")
        #expect(event.resourceProperties?.property3 == ["1", "2", "3"])
        #expect(event.resourceProperties?.property4 == "value4")
        #expect(event.oldResourceProperties?.property1 == "value1")
        #expect(event.oldResourceProperties?.property2 == "")
        #expect(event.oldResourceProperties?.property3 == ["1", "2", "3"])
        #expect(event.oldResourceProperties?.property4 == nil)
    }

    @Test func encodeResponseToJSON() throws {
        let resp = CloudFormation.Response<TestResourceProperties>(
            status: CloudFormation.Response.StatusType.success,
            requestId: "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c",
            logicalResourceId: "TestLogicalResource",
            stackId: "arn:aws:cloudformation:us-east-1:123456789:stack/TestStack",
            physicalResourceId: "TestPhysicalResource",
            reason: "See the details in CloudWatch Log Stream",
            noEcho: false,
            data: TestResourceProperties(
                property1: "value1",
                property2: "",
                property3: ["1", "2", "3"],
                property4: nil
            )
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        let data = try #require(try? encoder.encode(resp))

        var stringData: String?
        #expect(throws: Never.self) {
            stringData = String(data: data, encoding: .utf8)
        }

        #expect(CloudFormationTests.eventBodyResponse() == stringData)
    }
}
