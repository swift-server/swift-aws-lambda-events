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

    // MARK: Codable Helpers Tests

    @Test func decodeBodyForSingleMessage() throws {
        struct TestPayload: Codable, Equatable {
            let message: String
            let count: Int
        }
        
        let testPayload = TestPayload(message: "test", count: 42)
        
        let eventBodyWithJSON = """
        {
          "Records": [
            {
              "messageId": "test-message-id",
              "receiptHandle": "test-receipt-handle",
              "body": "{\\"message\\":\\"test\\",\\"count\\":42}",
              "attributes": {
                "ApproximateReceiveCount": "1",
                "SentTimestamp": "1523232000000",
                "SenderId": "123456789012",
                "ApproximateFirstReceiveTimestamp": "1523232000001"
              },
              "messageAttributes": {},
              "md5OfBody": "test-md5",
              "eventSource": "aws:sqs",
              "eventSourceARN": "arn:aws:sqs:us-east-1:123456789012:TestQueue",
              "awsRegion": "us-east-1"
            }
          ]
        }
        """
        
        let data = eventBodyWithJSON.data(using: .utf8)!
        let event = try JSONDecoder().decode(SQSEvent.self, from: data)
        
        guard let message = event.records.first else {
            Issue.record("Expected to have one message in the event")
            return
        }
        
        let decodedPayload = try message.decodeBody(TestPayload.self)
        #expect(decodedPayload == testPayload)
    }

    @Test func decodeBodyForSQSEvent() throws {
        struct TestPayload: Codable, Equatable {
            let message: String
            let count: Int
        }
        
        let testPayload1 = TestPayload(message: "test1", count: 42)
        let testPayload2 = TestPayload(message: "test2", count: 84)
        
        let eventBodyWithMultipleRecords = """
        {
          "Records": [
            {
              "messageId": "test-message-id-1",
              "receiptHandle": "test-receipt-handle-1",
              "body": "{\\"message\\":\\"test1\\",\\"count\\":42}",
              "attributes": {
                "ApproximateReceiveCount": "1",
                "SentTimestamp": "1523232000000",
                "SenderId": "123456789012",
                "ApproximateFirstReceiveTimestamp": "1523232000001"
              },
              "messageAttributes": {},
              "md5OfBody": "test-md5-1",
              "eventSource": "aws:sqs",
              "eventSourceARN": "arn:aws:sqs:us-east-1:123456789012:TestQueue",
              "awsRegion": "us-east-1"
            },
            {
              "messageId": "test-message-id-2",
              "receiptHandle": "test-receipt-handle-2",
              "body": "{\\"message\\":\\"test2\\",\\"count\\":84}",
              "attributes": {
                "ApproximateReceiveCount": "1",
                "SentTimestamp": "1523232000000",
                "SenderId": "123456789012",
                "ApproximateFirstReceiveTimestamp": "1523232000001"
              },
              "messageAttributes": {},
              "md5OfBody": "test-md5-2",
              "eventSource": "aws:sqs",
              "eventSourceARN": "arn:aws:sqs:us-east-1:123456789012:TestQueue",
              "awsRegion": "us-east-1"
            }
          ]
        }
        """
        
        let data = eventBodyWithMultipleRecords.data(using: .utf8)!
        let event = try JSONDecoder().decode(SQSEvent.self, from: data)
        
        let decodedPayloads = try event.decodeBody(TestPayload.self)
        #expect(decodedPayloads.count == 2)
        #expect(decodedPayloads[0] == testPayload1)
        #expect(decodedPayloads[1] == testPayload2)
    }

    @Test func decodeBodyWithCustomDecoder() throws {
        struct TestPayload: Codable, Equatable {
            let messageText: String
            let count: Int
            
            enum CodingKeys: String, CodingKey {
                case messageText = "message_text"
                case count
            }
        }
        
        let testPayload = TestPayload(messageText: "test", count: 42)
        
        // We need to create a decoder that can handle the explicit coding keys
        
        let eventBodyWithSnakeCase = """
        {
          "Records": [
            {
              "messageId": "test-message-id",
              "receiptHandle": "test-receipt-handle",
              "body": "{\\"message_text\\":\\"test\\",\\"count\\":42}",
              "attributes": {
                "ApproximateReceiveCount": "1",
                "SentTimestamp": "1523232000000",
                "SenderId": "123456789012",
                "ApproximateFirstReceiveTimestamp": "1523232000001"
              },
              "messageAttributes": {},
              "md5OfBody": "test-md5",
              "eventSource": "aws:sqs",
              "eventSourceARN": "arn:aws:sqs:us-east-1:123456789012:TestQueue",
              "awsRegion": "us-east-1"
            }
          ]
        }
        """
        
        let data = eventBodyWithSnakeCase.data(using: .utf8)!
        let event = try JSONDecoder().decode(SQSEvent.self, from: data)
        
        let decodedPayloads = try event.decodeBody(TestPayload.self)
        #expect(decodedPayloads.count == 1)
        #expect(decodedPayloads[0] == testPayload)
    }
}
