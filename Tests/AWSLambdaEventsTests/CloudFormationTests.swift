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

@testable import AWSLambdaEvents
import XCTest

class CloudFormationTests: XCTestCase {
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

    func testDecodeRequestRequiredFieldsFromJSON() {
        let eventBody = CloudFormationTests.eventBodyRequestRequiredFields()
        let data = eventBody.data(using: .utf8)!
        var event: CloudFormation.Request<EmptyTestResourceProperties, EmptyTestResourceProperties>?
        XCTAssertNoThrow(event = try JSONDecoder().decode(CloudFormation.Request.self, from: data))

        guard let event = event else {
            return XCTFail("Expected to have an event")
        }

        XCTAssertEqual(event.requestId, "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        XCTAssertEqual(event.requestType, CloudFormation.Request.RequestType.create)
        XCTAssertEqual(event.stackId, "arn:aws:cloudformation:us-east-1:123456789:stack/TestStack")
        XCTAssertEqual(event.responseURL, "http://localhost:7000/response/test")
        XCTAssertEqual(event.logicalResourceId, "TestLogicalResource")
        XCTAssertNil(event.physicalResourceId)
        XCTAssertNil(event.resourceProperties)
        XCTAssertNil(event.oldResourceProperties)
    }

    func testDecodeRequestCreateFromJSON() {
        let eventBody = CloudFormationTests.eventBodyRequestCreate()
        let data = eventBody.data(using: .utf8)!
        var event: CloudFormation.Request<TestResourceProperties, EmptyTestResourceProperties>?
        XCTAssertNoThrow(event = try JSONDecoder().decode(CloudFormation.Request.self, from: data))

        guard let event = event else {
            return XCTFail("Expected to have an event")
        }

        XCTAssertEqual(event.requestId, "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        XCTAssertEqual(event.requestType, CloudFormation.Request.RequestType.create)
        XCTAssertEqual(event.stackId, "arn:aws:cloudformation:us-east-1:123456789:stack/TestStack")
        XCTAssertEqual(event.responseURL, "http://localhost:7000/response/test")
        XCTAssertEqual(event.logicalResourceId, "TestLogicalResource")
        XCTAssertEqual(event.physicalResourceId, "TestPhysicalResource")
        XCTAssertEqual(event.resourceProperties?.property1, "value1")
        XCTAssertEqual(event.resourceProperties?.property2, "")
        XCTAssertEqual(event.resourceProperties?.property3, ["1", "2", "3"])
        XCTAssertEqual(event.resourceProperties?.property4, nil)
        XCTAssertNil(event.oldResourceProperties)
    }

    func testDecodeRequestUpdateFromJSON() {
        let eventBody = CloudFormationTests.eventBodyRequestUpdate()
        let data = eventBody.data(using: .utf8)!
        var event: CloudFormation.Request<TestResourceProperties, TestResourceProperties>?
        XCTAssertNoThrow(event = try JSONDecoder().decode(CloudFormation.Request.self, from: data))

        guard let event = event else {
            return XCTFail("Expected to have an event")
        }

        XCTAssertEqual(event.requestId, "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        XCTAssertEqual(event.requestType, CloudFormation.Request.RequestType.update)
        XCTAssertEqual(event.stackId, "arn:aws:cloudformation:us-east-1:123456789:stack/TestStack")
        XCTAssertEqual(event.responseURL, "http://localhost:7000/response/test")
        XCTAssertEqual(event.logicalResourceId, "TestLogicalResource")
        XCTAssertEqual(event.physicalResourceId, "TestPhysicalResource")
        XCTAssertEqual(event.resourceProperties?.property1, "value1")
        XCTAssertEqual(event.resourceProperties?.property2, "value2")
        XCTAssertEqual(event.resourceProperties?.property3, ["1", "2", "3"])
        XCTAssertEqual(event.resourceProperties?.property4, "value4")
        XCTAssertEqual(event.oldResourceProperties?.property1, "value1")
        XCTAssertEqual(event.oldResourceProperties?.property2, "")
        XCTAssertEqual(event.oldResourceProperties?.property3, ["1", "2", "3"])
        XCTAssertEqual(event.oldResourceProperties?.property4, nil)
    }

    func testEncodeResponseToJSON() {
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

        var data: Data?
        XCTAssertNoThrow(data = try encoder.encode(resp))

        var stringData: String?
        XCTAssertNoThrow(stringData = String(data: try XCTUnwrap(data), encoding: .utf8))

        print(stringData ?? "")

        XCTAssertEqual(CloudFormationTests.eventBodyResponse(), stringData)
    }
}
