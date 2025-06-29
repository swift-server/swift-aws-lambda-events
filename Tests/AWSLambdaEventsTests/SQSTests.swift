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
struct SQSTests {
    static let eventBody = """
        {
          "Records": [
            {
              "messageId": "19dd0b57-b21e-4ac1-bd88-01bbb068cb78",
              "receiptHandle": "MessageReceiptHandle",
              "body": "Hello from SQS!",
              "attributes": {
                "ApproximateReceiveCount": "1",
                "SentTimestamp": "1523232000000",
                "SenderId": "123456789012",
                "ApproximateFirstReceiveTimestamp": "1523232000001"
              },
              "messageAttributes": {
                "number":{
                  "stringValue":"123",
                  "stringListValues":[],
                  "binaryListValues":[],
                  "dataType":"Number"
                },
                "string":{
                  "stringValue":"abc123",
                  "stringListValues":[],
                  "binaryListValues":[],
                  "dataType":"String"
                },
                "binary":{
                  "dataType": "Binary",
                  "stringListValues":[],
                  "binaryListValues":[],
                  "binaryValue":"YmFzZTY0"
                },

              },
              "md5OfBody": "7b270e59b47ff90a553787216d55d91d",
              "eventSource": "aws:sqs",
              "eventSourceARN": "arn:aws:sqs:us-east-1:123456789012:MyQueue",
              "awsRegion": "us-east-1"
            }
          ]
        }
        """

    @Test func simpleEventFromJSON() throws {
        let data = SQSTests.eventBody.data(using: .utf8)!
        let event = try JSONDecoder().decode(SQSEvent.self, from: data)

        guard let message = event.records.first else {
            Issue.record("Expected to have one message in the event")
            return
        }

        #expect(message.messageId == "19dd0b57-b21e-4ac1-bd88-01bbb068cb78")
        #expect(message.receiptHandle == "MessageReceiptHandle")
        #expect(message.body == "Hello from SQS!")
        #expect(message.attributes.count == 4)

        #expect(
            message.messageAttributes == [
                "number": .number("123"),
                "string": .string("abc123"),
                "binary": .binary([UInt8]("base64".utf8)),
            ]
        )
        #expect(message.md5OfBody == "7b270e59b47ff90a553787216d55d91d")
        #expect(message.eventSource == "aws:sqs")
        #expect(message.eventSourceArn == "arn:aws:sqs:us-east-1:123456789012:MyQueue")
        #expect(message.awsRegion == .us_east_1)
    }
}
