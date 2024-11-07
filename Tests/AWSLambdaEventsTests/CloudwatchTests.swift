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

import XCTest

@testable import AWSLambdaEvents

class CloudwatchTests: XCTestCase {
    static func eventBody(type: String, details: String) -> String {
        """
        {
          "id": "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c",
          "detail-type": "\(type)",
          "source": "aws.events",
          "account": "123456789012",
          "time": "1970-01-01T00:00:00Z",
          "region": "us-east-1",
          "resources": [
            "arn:aws:events:us-east-1:123456789012:rule/ExampleRule"
          ],
          "detail": \(details)
        }
        """
    }

    func testScheduledEventFromJSON() {
        let eventBody = CloudwatchTests.eventBody(type: CloudwatchDetails.Scheduled.name, details: "{}")
        let data = eventBody.data(using: .utf8)!
        var maybeEvent: CloudwatchScheduledEvent?
        XCTAssertNoThrow(maybeEvent = try JSONDecoder().decode(CloudwatchScheduledEvent.self, from: data))

        guard let event = maybeEvent else {
            return XCTFail("Expected to have an event")
        }

        XCTAssertEqual(event.id, "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        XCTAssertEqual(event.source, "aws.events")
        XCTAssertEqual(event.accountId, "123456789012")
        XCTAssertEqual(event.time, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(event.region, .us_east_1)
        XCTAssertEqual(event.resources, ["arn:aws:events:us-east-1:123456789012:rule/ExampleRule"])
    }

    func testEC2InstanceStateChangeNotificationEventFromJSON() {
        let eventBody = CloudwatchTests.eventBody(
            type: CloudwatchDetails.EC2.InstanceStateChangeNotification.name,
            details: "{ \"instance-id\": \"0\", \"state\": \"stopping\" }"
        )
        let data = eventBody.data(using: .utf8)!
        var maybeEvent: CloudwatchEC2InstanceStateChangeNotificationEvent?
        XCTAssertNoThrow(
            maybeEvent = try JSONDecoder().decode(CloudwatchEC2InstanceStateChangeNotificationEvent.self, from: data)
        )

        guard let event = maybeEvent else {
            return XCTFail("Expected to have an event")
        }

        XCTAssertEqual(event.id, "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        XCTAssertEqual(event.source, "aws.events")
        XCTAssertEqual(event.accountId, "123456789012")
        XCTAssertEqual(event.time, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(event.region, .us_east_1)
        XCTAssertEqual(event.resources, ["arn:aws:events:us-east-1:123456789012:rule/ExampleRule"])
        XCTAssertEqual(event.detail.instanceId, "0")
        XCTAssertEqual(event.detail.state, .stopping)
    }

    func testEC2SpotInstanceInterruptionNoticeEventFromJSON() {
        let eventBody = CloudwatchTests.eventBody(
            type: CloudwatchDetails.EC2.SpotInstanceInterruptionNotice.name,
            details: "{ \"instance-id\": \"0\", \"instance-action\": \"terminate\" }"
        )
        let data = eventBody.data(using: .utf8)!
        var maybeEvent: CloudwatchEC2SpotInstanceInterruptionNoticeEvent?
        XCTAssertNoThrow(
            maybeEvent = try JSONDecoder().decode(CloudwatchEC2SpotInstanceInterruptionNoticeEvent.self, from: data)
        )

        guard let event = maybeEvent else {
            return XCTFail("Expected to have an event")
        }

        XCTAssertEqual(event.id, "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        XCTAssertEqual(event.source, "aws.events")
        XCTAssertEqual(event.accountId, "123456789012")
        XCTAssertEqual(event.time, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(event.region, .us_east_1)
        XCTAssertEqual(event.resources, ["arn:aws:events:us-east-1:123456789012:rule/ExampleRule"])
        XCTAssertEqual(event.detail.instanceId, "0")
        XCTAssertEqual(event.detail.action, .terminate)
    }
	
	func testS3ObjectCreatedEventFromJSON() {
		let eventBody = CloudwatchTests.eventBody(
			type: CloudwatchDetails.S3.ObjectCreatedNotification.name,
			details: "{ \"version\": \"0\", \"bucket\": { \"name\": \"amzn-s3-demo-bucket1\" }, \"object\": { \"key\": \"example-key\", \"size\":5, \"etag\": \"b1946ac92492d2347c6235b4d2611184\", \"version-id\": \"IYV3p45BT0ac8hjHg1houSdS1a.Mro8e\", \"sequencer\": \"617f08299329d189\" }, \"request-id\": \"N4N7GDK58NMKJ12R\", \"requester\": \"123456789012\", \"source-ip-address\": \"1.2.3.4\", \"reason\": \"PutObject\" }"

		)
		let data = eventBody.data(using: .utf8)!
		var maybeEvent: CloudWatchS3ObjectCreatedNotificationEvent?
		XCTAssertNoThrow(
			maybeEvent = try JSONDecoder().decode(CloudWatchS3ObjectCreatedNotificationEvent.self, from: data)
		)
		
		guard let event = maybeEvent else {
			return XCTFail("Expected to have an event")
		}
		
		XCTAssertEqual(event.id, "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
		XCTAssertEqual(event.source, "aws.events")
		XCTAssertEqual(event.accountId, "123456789012")
		XCTAssertEqual(event.time, Date(timeIntervalSince1970: 0))
		XCTAssertEqual(event.region, .us_east_1)
		XCTAssertEqual(event.resources, ["arn:aws:events:us-east-1:123456789012:rule/ExampleRule"])
		XCTAssertEqual(event.detail.version, "0")
		XCTAssertEqual(event.detail.bucket.name, "amzn-s3-demo-bucket1")
		XCTAssertEqual(event.detail.object.key, "example-key")
		XCTAssertEqual(event.detail.object.size, 5)
		XCTAssertEqual(event.detail.object.etag, "b1946ac92492d2347c6235b4d2611184")
		XCTAssertEqual(event.detail.object.versionId, "IYV3p45BT0ac8hjHg1houSdS1a.Mro8e")
		XCTAssertEqual(event.detail.object.sequencer, "617f08299329d189")
		XCTAssertEqual(event.detail.requestId, "N4N7GDK58NMKJ12R")
		XCTAssertEqual(event.detail.requester, "123456789012")
		XCTAssertEqual(event.detail.sourceIpAddress, "1.2.3.4")
		XCTAssertEqual(event.detail.reason, .putObject)
	}
	
	func testS3ObjectDeletedEventFromJSON() {
		let eventBody = CloudwatchTests.eventBody(
			type: CloudwatchDetails.S3.ObjectDeletedNotification.name,
			details: "{ \"version\": \"0\", \"bucket\": { \"name\": \"amzn-s3-demo-bucket1\" }, \"object\": { \"key\": \"example-key\", \"etag\": \"d41d8cd98f00b204e9800998ecf8427e\", \"version-id\": \"1QW9g1Z99LUNbvaaYVpW9xDlOLU.qxgF\", \"sequencer\": \"617f0837b476e463\" }, \"request-id\": \"0BH729840619AG5K\", \"requester\": \"123456789012\", \"source-ip-address\": \"1.2.3.4\", \"reason\": \"DeleteObject\", \"deletion-type\": \"Delete Marker Created\" }"
			
		)
		let data = eventBody.data(using: .utf8)!
		var maybeEvent: CloudWatchS3ObjectDeletedNotificationEvent?
		XCTAssertNoThrow(
			maybeEvent = try JSONDecoder().decode(CloudWatchS3ObjectDeletedNotificationEvent.self, from: data)
		)
		
		guard let event = maybeEvent else {
			return XCTFail("Expected to have an event")
		}
		
		XCTAssertEqual(event.id, "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
		XCTAssertEqual(event.source, "aws.events")
		XCTAssertEqual(event.accountId, "123456789012")
		XCTAssertEqual(event.time, Date(timeIntervalSince1970: 0))
		XCTAssertEqual(event.region, .us_east_1)
		XCTAssertEqual(event.resources, ["arn:aws:events:us-east-1:123456789012:rule/ExampleRule"])
		XCTAssertEqual(event.detail.version, "0")
		XCTAssertEqual(event.detail.bucket.name, "amzn-s3-demo-bucket1")
		XCTAssertEqual(event.detail.object.key, "example-key")
		XCTAssertEqual(event.detail.object.etag, "d41d8cd98f00b204e9800998ecf8427e")
		XCTAssertEqual(event.detail.object.versionId, "1QW9g1Z99LUNbvaaYVpW9xDlOLU.qxgF")
		XCTAssertEqual(event.detail.object.sequencer, "617f0837b476e463")
		XCTAssertEqual(event.detail.requestId, "0BH729840619AG5K")
		XCTAssertEqual(event.detail.requester, "123456789012")
		XCTAssertEqual(event.detail.sourceIpAddress, "1.2.3.4")
		XCTAssertEqual(event.detail.reason, .deleteObject)
		XCTAssertEqual(event.detail.deletionType, .deleteMarkerCreated)
	}
	
	func testS3ObjectRestoreCompletedEventFromJSON() {
		let eventBody = CloudwatchTests.eventBody(
			type: CloudwatchDetails.S3.ObjectRestoreCompletedNotification.name,
			details: "{ \"version\": \"0\", \"bucket\": { \"name\": \"amzn-s3-demo-bucket1\" }, \"object\": { \"key\": \"example-key\", \"size\": 5, \"etag\": \"b1946ac92492d2347c6235b4d2611184\", \"version-id\": \"KKsjUC1.6gIjqtvhfg5AdMI0eCePIiT3\" }, \"request-id\": \"189F19CB7FB1B6A4\", \"requester\": \"s3.amazonaws.com\", \"restore-expiry-time\": \"2021-11-13T00:00:00Z\", \"source-storage-class\": \"GLACIER\" }"
			
		)
		let data = eventBody.data(using: .utf8)!
		var maybeEvent: CloudWatchS3ObjectRestoreCompletedNotificationEvent?
		XCTAssertNoThrow(
			maybeEvent = try JSONDecoder().decode(CloudWatchS3ObjectRestoreCompletedNotificationEvent.self, from: data)
		)
		
		guard let event = maybeEvent else {
			return XCTFail("Expected to have an event")
		}
		
		XCTAssertEqual(event.id, "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
		XCTAssertEqual(event.source, "aws.events")
		XCTAssertEqual(event.accountId, "123456789012")
		XCTAssertEqual(event.time, Date(timeIntervalSince1970: 0))
		XCTAssertEqual(event.region, .us_east_1)
		XCTAssertEqual(event.resources, ["arn:aws:events:us-east-1:123456789012:rule/ExampleRule"])
		XCTAssertEqual(event.detail.version, "0")
		XCTAssertEqual(event.detail.bucket.name, "amzn-s3-demo-bucket1")
		XCTAssertEqual(event.detail.object.key, "example-key")
		XCTAssertEqual(event.detail.object.size, 5)
		XCTAssertEqual(event.detail.object.etag, "b1946ac92492d2347c6235b4d2611184")
		XCTAssertEqual(event.detail.object.versionId, "KKsjUC1.6gIjqtvhfg5AdMI0eCePIiT3")
		XCTAssertEqual(event.detail.requestId, "189F19CB7FB1B6A4")
		XCTAssertEqual(event.detail.requester, "s3.amazonaws.com")
		XCTAssertEqual(event.detail.restoreExpiryTime.description, "2021-11-13 00:00:00 +0000")
		XCTAssertEqual(event.detail.sourceStorageClass, .glacier)
	}

    func testCustomEventFromJSON() {
        struct Custom: CloudwatchDetail {
            public static let name = "Custom"

            let name: String
        }

        let eventBody = CloudwatchTests.eventBody(type: Custom.name, details: "{ \"name\": \"foo\" }")
        let data = eventBody.data(using: .utf8)!
        var maybeEvent: CloudwatchEvent<Custom>?
        XCTAssertNoThrow(maybeEvent = try JSONDecoder().decode(CloudwatchEvent<Custom>.self, from: data))

        guard let event = maybeEvent else {
            return XCTFail("Expected to have an event")
        }

        XCTAssertEqual(event.id, "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        XCTAssertEqual(event.source, "aws.events")
        XCTAssertEqual(event.accountId, "123456789012")
        XCTAssertEqual(event.time, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(event.region, .us_east_1)
        XCTAssertEqual(event.resources, ["arn:aws:events:us-east-1:123456789012:rule/ExampleRule"])
        XCTAssertEqual(event.detail.name, "foo")
    }

    func testUnregistredType() {
        let eventBody = CloudwatchTests.eventBody(type: UUID().uuidString, details: "{}")
        let data = eventBody.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(CloudwatchScheduledEvent.self, from: data)) { error in
            XCTAssert(error is CloudwatchDetails.TypeMismatch, "expected DetailTypeMismatch but received \(error)")
        }
    }

    func testTypeMismatch() {
        let eventBody = CloudwatchTests.eventBody(
            type: CloudwatchDetails.EC2.InstanceStateChangeNotification.name,
            details: "{ \"instance-id\": \"0\", \"state\": \"stopping\" }"
        )
        let data = eventBody.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(CloudwatchScheduledEvent.self, from: data)) { error in
            XCTAssert(error is CloudwatchDetails.TypeMismatch, "expected DetailTypeMismatch but received \(error)")
        }
    }
}
