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

import Foundation
import Testing

@testable import AWSLambdaEvents

@Suite
struct CloudwatchTests {
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

    @Test func scheduledEventFromJSON() throws {
        let eventBody = CloudwatchTests.eventBody(type: CloudwatchDetails.Scheduled.name, details: "{}")
        let data = eventBody.data(using: .utf8)!
        let event = try JSONDecoder().decode(CloudwatchScheduledEvent.self, from: data)

        #expect(event.id == "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        #expect(event.source == "aws.events")
        #expect(event.accountId == "123456789012")
        #expect(event.time == Date(timeIntervalSince1970: 0))
        #expect(event.region == .us_east_1)
        #expect(event.resources == ["arn:aws:events:us-east-1:123456789012:rule/ExampleRule"])
    }

    @Test func ec2InstanceStateChangeNotificationEventFromJSON() throws {
        let eventBody = CloudwatchTests.eventBody(
            type: CloudwatchDetails.EC2.InstanceStateChangeNotification.name,
            details: "{ \"instance-id\": \"0\", \"state\": \"stopping\" }"
        )
        let data = eventBody.data(using: .utf8)!
        let event = try JSONDecoder().decode(CloudwatchEC2InstanceStateChangeNotificationEvent.self, from: data)

        #expect(event.id == "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        #expect(event.source == "aws.events")
        #expect(event.accountId == "123456789012")
        #expect(event.time == Date(timeIntervalSince1970: 0))
        #expect(event.region == .us_east_1)
        #expect(event.resources == ["arn:aws:events:us-east-1:123456789012:rule/ExampleRule"])
        #expect(event.detail.instanceId == "0")
        #expect(event.detail.state == .stopping)
    }

    @Test func ec2SpotInstanceInterruptionNoticeEventFromJSON() throws {
        let eventBody = CloudwatchTests.eventBody(
            type: CloudwatchDetails.EC2.SpotInstanceInterruptionNotice.name,
            details: "{ \"instance-id\": \"0\", \"instance-action\": \"terminate\" }"
        )
        let data = eventBody.data(using: .utf8)!
        let event = try JSONDecoder().decode(CloudwatchEC2SpotInstanceInterruptionNoticeEvent.self, from: data)

        #expect(event.id == "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        #expect(event.source == "aws.events")
        #expect(event.accountId == "123456789012")
        #expect(event.time == Date(timeIntervalSince1970: 0))
        #expect(event.region == .us_east_1)
        #expect(event.resources == ["arn:aws:events:us-east-1:123456789012:rule/ExampleRule"])
        #expect(event.detail.instanceId == "0")
        #expect(event.detail.action == .terminate)
    }

    @Test func s3ObjectCreatedEventFromJSON() throws {
        let eventBody = CloudwatchTests.eventBody(
            type: CloudwatchDetails.S3.ObjectCreatedNotification.name,
            details:
                "{ \"version\": \"0\", \"bucket\": { \"name\": \"amzn-s3-demo-bucket1\" }, \"object\": { \"key\": \"example-key\", \"size\":5, \"etag\": \"b1946ac92492d2347c6235b4d2611184\", \"version-id\": \"IYV3p45BT0ac8hjHg1houSdS1a.Mro8e\", \"sequencer\": \"617f08299329d189\" }, \"request-id\": \"N4N7GDK58NMKJ12R\", \"requester\": \"123456789012\", \"source-ip-address\": \"1.2.3.4\", \"reason\": \"PutObject\" }"

        )
        let data = eventBody.data(using: .utf8)!
        let event = try JSONDecoder().decode(CloudWatchS3ObjectCreatedNotificationEvent.self, from: data)

        #expect(event.id == "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        #expect(event.source == "aws.events")
        #expect(event.accountId == "123456789012")
        #expect(event.time == Date(timeIntervalSince1970: 0))
        #expect(event.region == .us_east_1)
        #expect(event.resources == ["arn:aws:events:us-east-1:123456789012:rule/ExampleRule"])
        #expect(event.detail.version == "0")
        #expect(event.detail.bucket.name == "amzn-s3-demo-bucket1")
        #expect(event.detail.object.key == "example-key")
        #expect(event.detail.object.size == 5)
        #expect(event.detail.object.etag == "b1946ac92492d2347c6235b4d2611184")
        #expect(event.detail.object.versionId == "IYV3p45BT0ac8hjHg1houSdS1a.Mro8e")
        #expect(event.detail.object.sequencer == "617f08299329d189")
        #expect(event.detail.requestId == "N4N7GDK58NMKJ12R")
        #expect(event.detail.requester == "123456789012")
        #expect(event.detail.sourceIpAddress == "1.2.3.4")
        #expect(event.detail.reason == .putObject)
    }

    @Test func s3ObjectDeletedEventFromJSON() throws {
        let eventBody = CloudwatchTests.eventBody(
            type: CloudwatchDetails.S3.ObjectDeletedNotification.name,
            details:
                "{ \"version\": \"0\", \"bucket\": { \"name\": \"amzn-s3-demo-bucket1\" }, \"object\": { \"key\": \"example-key\", \"etag\": \"d41d8cd98f00b204e9800998ecf8427e\", \"version-id\": \"1QW9g1Z99LUNbvaaYVpW9xDlOLU.qxgF\", \"sequencer\": \"617f0837b476e463\" }, \"request-id\": \"0BH729840619AG5K\", \"requester\": \"123456789012\", \"source-ip-address\": \"1.2.3.4\", \"reason\": \"DeleteObject\", \"deletion-type\": \"Delete Marker Created\" }"

        )
        let data = eventBody.data(using: .utf8)!
        let event = try JSONDecoder().decode(CloudWatchS3ObjectDeletedNotificationEvent.self, from: data)

        #expect(event.id == "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        #expect(event.source == "aws.events")
        #expect(event.accountId == "123456789012")
        #expect(event.time == Date(timeIntervalSince1970: 0))
        #expect(event.region == .us_east_1)
        #expect(event.resources == ["arn:aws:events:us-east-1:123456789012:rule/ExampleRule"])
        #expect(event.detail.version == "0")
        #expect(event.detail.bucket.name == "amzn-s3-demo-bucket1")
        #expect(event.detail.object.key == "example-key")
        #expect(event.detail.object.etag == "d41d8cd98f00b204e9800998ecf8427e")
        #expect(event.detail.object.versionId == "1QW9g1Z99LUNbvaaYVpW9xDlOLU.qxgF")
        #expect(event.detail.object.sequencer == "617f0837b476e463")
        #expect(event.detail.requestId == "0BH729840619AG5K")
        #expect(event.detail.requester == "123456789012")
        #expect(event.detail.sourceIpAddress == "1.2.3.4")
        #expect(event.detail.reason == .deleteObject)
        #expect(event.detail.deletionType == .deleteMarkerCreated)
    }

    @Test func s3ObjectRestoreCompletedEventFromJSON() throws {
        let eventBody = CloudwatchTests.eventBody(
            type: CloudwatchDetails.S3.ObjectRestoreCompletedNotification.name,
            details:
                "{ \"version\": \"0\", \"bucket\": { \"name\": \"amzn-s3-demo-bucket1\" }, \"object\": { \"key\": \"example-key\", \"size\": 5, \"etag\": \"b1946ac92492d2347c6235b4d2611184\", \"version-id\": \"KKsjUC1.6gIjqtvhfg5AdMI0eCePIiT3\" }, \"request-id\": \"189F19CB7FB1B6A4\", \"requester\": \"s3.amazonaws.com\", \"restore-expiry-time\": \"2021-11-13T00:00:00Z\", \"source-storage-class\": \"GLACIER\" }"

        )
        let data = eventBody.data(using: .utf8)!
        let event = try JSONDecoder().decode(CloudWatchS3ObjectRestoreCompletedNotificationEvent.self, from: data)

        #expect(event.id == "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        #expect(event.source == "aws.events")
        #expect(event.accountId == "123456789012")
        #expect(event.time == Date(timeIntervalSince1970: 0))
        #expect(event.region == .us_east_1)
        #expect(event.resources == ["arn:aws:events:us-east-1:123456789012:rule/ExampleRule"])
        #expect(event.detail.version == "0")
        #expect(event.detail.bucket.name == "amzn-s3-demo-bucket1")
        #expect(event.detail.object.key == "example-key")
        #expect(event.detail.object.size == 5)
        #expect(event.detail.object.etag == "b1946ac92492d2347c6235b4d2611184")
        #expect(event.detail.object.versionId == "KKsjUC1.6gIjqtvhfg5AdMI0eCePIiT3")
        #expect(event.detail.requestId == "189F19CB7FB1B6A4")
        #expect(event.detail.requester == "s3.amazonaws.com")
        #expect(event.detail.restoreExpiryTime.description == "2021-11-13 00:00:00 +0000")
        #expect(event.detail.sourceStorageClass == .glacier)
    }

    @Test func customEventFromJSON() throws {
        struct Custom: CloudwatchDetail {
            public static let name = "Custom"

            let name: String
        }

        let eventBody = CloudwatchTests.eventBody(type: Custom.name, details: "{ \"name\": \"foo\" }")
        let data = eventBody.data(using: .utf8)!
        let event = try JSONDecoder().decode(CloudwatchEvent<Custom>.self, from: data)

        #expect(event.id == "cdc73f9d-aea9-11e3-9d5a-835b769c0d9c")
        #expect(event.source == "aws.events")
        #expect(event.accountId == "123456789012")
        #expect(event.time == Date(timeIntervalSince1970: 0))
        #expect(event.region == .us_east_1)
        #expect(event.resources == ["arn:aws:events:us-east-1:123456789012:rule/ExampleRule"])
        #expect(event.detail.name == "foo")
    }

    @Test func unregistredType() throws {
        let eventBody = CloudwatchTests.eventBody(type: UUID().uuidString, details: "{}")
        let data = eventBody.data(using: .utf8)!
        #expect(throws: CloudwatchDetails.TypeMismatch.self) {
            try JSONDecoder().decode(CloudwatchScheduledEvent.self, from: data)
        }
    }

    @Test func typeMismatch() throws {
        let eventBody = CloudwatchTests.eventBody(
            type: CloudwatchDetails.EC2.InstanceStateChangeNotification.name,
            details: "{ \"instance-id\": \"0\", \"state\": \"stopping\" }"
        )
        let data = eventBody.data(using: .utf8)!
        #expect(throws: CloudwatchDetails.TypeMismatch.self) {
            try JSONDecoder().decode(CloudwatchScheduledEvent.self, from: data)
        }
    }
}
