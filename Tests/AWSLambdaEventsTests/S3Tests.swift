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
struct S3Tests {
    static let eventBodyObjectCreated = """
        {
          "Records": [
            {
              "eventVersion":"2.1",
              "eventSource":"aws:s3",
              "awsRegion":"eu-central-1",
              "eventTime":"2020-01-13T09:25:40.621Z",
              "eventName":"ObjectCreated:Put",
              "userIdentity":{
                "principalId":"AWS:AAAAAAAJ2MQ4YFQZ7AULJ"
              },
              "requestParameters":{
                "sourceIPAddress":"123.123.123.123"
              },
              "responseElements":{
                "x-amz-request-id":"01AFA1430E18C358",
                "x-amz-id-2":"JsbNw6sHGFwgzguQjbYcew//bfAeZITyTYLfjuu1U4QYqCq5CPlSyYLtvWQS+gw0RxcroItGwm8="
              },
              "s3":{
                "s3SchemaVersion":"1.0",
                "configurationId":"98b55bc4-3c0c-4007-b727-c6b77a259dde",
                "bucket":{
                  "name":"eventsources",
                  "ownerIdentity":{
                    "principalId":"AAAAAAAAAAAAAA"
                  },
                  "arn":"arn:aws:s3:::eventsources"
                },
                "object":{
                  "key":"Hi.md",
                  "size":2880,
                  "eTag":"91a7f2c3ae81bcc6afef83979b463f0e",
                  "sequencer":"005E1C37948E783A6E"
                }
              }
            }
          ]
        }
        """

    // A S3 ObjectRemoved:* event does not contain the object size
    static let eventBodyObjectRemoved = """
        {
          "Records": [
            {
              "eventVersion":"2.1",
              "eventSource":"aws:s3",
              "awsRegion":"eu-central-1",
              "eventTime":"2020-01-13T09:25:40.621Z",
              "eventName":"ObjectRemoved:DeleteMarkerCreated",
              "userIdentity":{
                "principalId":"AWS:AAAAAAAJ2MQ4YFQZ7AULJ"
              },
              "requestParameters":{
                "sourceIPAddress":"123.123.123.123"
              },
              "responseElements":{
                "x-amz-request-id":"01AFA1430E18C358",
                "x-amz-id-2":"JsbNw6sHGFwgzguQjbYcew//bfAeZITyTYLfjuu1U4QYqCq5CPlSyYLtvWQS+gw0RxcroItGwm8="
              },
              "s3":{
                "s3SchemaVersion":"1.0",
                "configurationId":"98b55bc4-3c0c-4007-b727-c6b77a259dde",
                "bucket":{
                  "name":"eventsources",
                  "ownerIdentity":{
                    "principalId":"AAAAAAAAAAAAAA"
                  },
                  "arn":"arn:aws:s3:::eventsources"
                },
                "object":{
                  "key":"Hi.md",
                  "eTag":"91a7f2c3ae81bcc6afef83979b463f0e",
                  "sequencer":"005E1C37948E783A6E"
                }
              }
            }
          ]
        }
        """

    @Test func simpleEventFromJSON() throws {
        let data = S3Tests.eventBodyObjectCreated.data(using: .utf8)!
        let event = try JSONDecoder().decode(S3Event.self, from: data)
        let record = try #require(event.records.first)

        #expect(record.eventVersion == "2.1")
        #expect(record.eventSource == "aws:s3")
        #expect(record.awsRegion == .eu_central_1)
        #expect(record.eventName == "ObjectCreated:Put")
        #expect(record.eventTime == Date(timeIntervalSince1970: 1_578_907_540.621))
        #expect(record.userIdentity == S3Event.UserIdentity(principalId: "AWS:AAAAAAAJ2MQ4YFQZ7AULJ"))
        #expect(record.requestParameters == S3Event.RequestParameters(sourceIPAddress: "123.123.123.123"))
        #expect(record.responseElements.count == 2)
        #expect(record.s3.schemaVersion == "1.0")
        #expect(record.s3.configurationId == "98b55bc4-3c0c-4007-b727-c6b77a259dde")
        #expect(record.s3.bucket.name == "eventsources")
        #expect(record.s3.bucket.ownerIdentity == S3Event.UserIdentity(principalId: "AAAAAAAAAAAAAA"))
        #expect(record.s3.bucket.arn == "arn:aws:s3:::eventsources")
        #expect(record.s3.object.key == "Hi.md")
        #expect(record.s3.object.size == 2880)
        #expect(record.s3.object.eTag == "91a7f2c3ae81bcc6afef83979b463f0e")
        #expect(record.s3.object.sequencer == "005E1C37948E783A6E")
    }

    @Test func objectRemovedEvent() throws {
        let data = S3Tests.eventBodyObjectRemoved.data(using: .utf8)!
        let event = try JSONDecoder().decode(S3Event.self, from: data)
        let record = try #require(event.records.first)

        #expect(record.eventVersion == "2.1")
        #expect(record.eventSource == "aws:s3")
        #expect(record.awsRegion == .eu_central_1)
        #expect(record.eventName == "ObjectRemoved:DeleteMarkerCreated")
        #expect(record.eventTime == Date(timeIntervalSince1970: 1_578_907_540.621))
        #expect(record.userIdentity == S3Event.UserIdentity(principalId: "AWS:AAAAAAAJ2MQ4YFQZ7AULJ"))
        #expect(record.requestParameters == S3Event.RequestParameters(sourceIPAddress: "123.123.123.123"))
        #expect(record.responseElements.count == 2)
        #expect(record.s3.schemaVersion == "1.0")
        #expect(record.s3.configurationId == "98b55bc4-3c0c-4007-b727-c6b77a259dde")
        #expect(record.s3.bucket.name == "eventsources")
        #expect(record.s3.bucket.ownerIdentity == S3Event.UserIdentity(principalId: "AAAAAAAAAAAAAA"))
        #expect(record.s3.bucket.arn == "arn:aws:s3:::eventsources")
        #expect(record.s3.object.key == "Hi.md")
        #expect(record.s3.object.size == nil)
        #expect(record.s3.object.eTag == "91a7f2c3ae81bcc6afef83979b463f0e")
        #expect(record.s3.object.sequencer == "005E1C37948E783A6E")
    }
}
