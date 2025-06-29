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
struct DynamoDBTests {
    static let streamEventBody = """
        {
          "Records": [
            {
              "eventID": "1",
              "eventVersion": "1.0",
              "dynamodb": {
                "ApproximateCreationDateTime": 1.578648338E9,
                "Keys": {
                  "Id": {
                    "N": "101"
                  }
                },
                "NewImage": {
                  "Message": {
                    "S": "New item!"
                  },
                  "Id": {
                    "N": "101"
                  }
                },
                "StreamViewType": "NEW_AND_OLD_IMAGES",
                "SequenceNumber": "111",
                "SizeBytes": 26
              },
              "awsRegion": "eu-central-1",
              "eventName": "INSERT",
              "eventSourceARN": "arn:aws:dynamodb:eu-central-1:account-id:table/ExampleTableWithStream/stream/2015-06-27T00:48:05.899",
              "eventSource": "aws:dynamodb"
            },
            {
              "eventID": "2",
              "eventVersion": "1.0",
              "dynamodb": {
                "ApproximateCreationDateTime": 1.578648338E9,
                "OldImage": {
                  "Message": {
                    "S": "New item!"
                  },
                  "Id": {
                    "N": "101"
                  }
                },
                "SequenceNumber": "222",
                "Keys": {
                  "Id": {
                    "N": "101"
                  }
                },
                "SizeBytes": 59,
                "NewImage": {
                  "Message": {
                    "S": "This item has changed"
                  },
                  "Id": {
                    "N": "101"
                  }
                },
                "StreamViewType": "NEW_AND_OLD_IMAGES"
              },
              "awsRegion": "eu-central-1",
              "eventName": "MODIFY",
              "eventSourceARN": "arn:aws:dynamodb:eu-central-1:account-id:table/ExampleTableWithStream/stream/2015-06-27T00:48:05.899",
              "eventSource": "aws:dynamodb"
            },
            {
              "eventID": "3",
              "eventVersion": "1.0",
              "dynamodb": {
                "ApproximateCreationDateTime":1.578648338E9,
                "Keys": {
                  "Id": {
                    "N": "101"
                  }
                },
                "SizeBytes": 38,
                "SequenceNumber": "333",
                "OldImage": {
                  "Message": {
                    "S": "This item has changed"
                  },
                  "Id": {
                    "N": "101"
                  }
                },
                "StreamViewType": "NEW_AND_OLD_IMAGES"
              },
              "awsRegion": "eu-central-1",
              "eventName": "REMOVE",
              "eventSourceARN": "arn:aws:dynamodb:eu-central-1:account-id:table/ExampleTableWithStream/stream/2015-06-27T00:48:05.899",
              "eventSource": "aws:dynamodb"
            }
          ]
        }
        """

    @Test func eventFromJSON() throws {
        let data = DynamoDBTests.streamEventBody.data(using: .utf8)!
        let event = try JSONDecoder().decode(DynamoDBEvent.self, from: data)

        #expect(event.records.count == 3)
    }

    // MARK: - Parse Attribute Value Tests -

    @Test func attributeValueBoolDecoding() {
        let json = "{\"BOOL\": true}"
        var value: DynamoDBEvent.AttributeValue?
        #expect(throws: Never.self) {
            value = try JSONDecoder().decode(DynamoDBEvent.AttributeValue.self, from: json.data(using: .utf8)!)
        }
        #expect(value == .boolean(true))
    }

    @Test func attributeValueBinaryDecoding() {
        let json = "{\"B\": \"YmFzZTY0\"}"
        var value: DynamoDBEvent.AttributeValue?
        #expect(throws: Never.self) {
            value = try JSONDecoder().decode(DynamoDBEvent.AttributeValue.self, from: json.data(using: .utf8)!)
        }
        #expect(value == .binary([UInt8]("base64".utf8)))
    }

    @Test func attributeValueBinarySetDecoding() {
        let json = "{\"BS\": [\"YmFzZTY0\", \"YWJjMTIz\"]}"
        var value: DynamoDBEvent.AttributeValue?
        #expect(throws: Never.self) {
            value = try JSONDecoder().decode(DynamoDBEvent.AttributeValue.self, from: json.data(using: .utf8)!)
        }
        #expect(value == .binarySet([[UInt8]("base64".utf8), [UInt8]("abc123".utf8)]))
    }

    @Test func attributeValueStringDecoding() {
        let json = "{\"S\": \"huhu\"}"
        var value: DynamoDBEvent.AttributeValue?
        #expect(throws: Never.self) {
            value = try JSONDecoder().decode(DynamoDBEvent.AttributeValue.self, from: json.data(using: .utf8)!)
        }
        #expect(value == .string("huhu"))
    }

    @Test func attributeValueStringSetDecoding() {
        let json = "{\"SS\": [\"huhu\", \"haha\"]}"
        var value: DynamoDBEvent.AttributeValue?
        #expect(throws: Never.self) {
            value = try JSONDecoder().decode(DynamoDBEvent.AttributeValue.self, from: json.data(using: .utf8)!)
        }
        #expect(value == .stringSet(["huhu", "haha"]))
    }

    @Test func attributeValueNullDecoding() {
        let json = "{\"NULL\": true}"
        var value: DynamoDBEvent.AttributeValue?
        #expect(throws: Never.self) {
            value = try JSONDecoder().decode(DynamoDBEvent.AttributeValue.self, from: json.data(using: .utf8)!)
        }
        #expect(value == .null)
    }

    @Test func attributeValueNumberDecoding() {
        let json = "{\"N\": \"1.2345\"}"
        var value: DynamoDBEvent.AttributeValue?
        #expect(throws: Never.self) {
            value = try JSONDecoder().decode(DynamoDBEvent.AttributeValue.self, from: json.data(using: .utf8)!)
        }
        #expect(value == .number("1.2345"))
    }

    @Test func attributeValueNumberSetDecoding() {
        let json = "{\"NS\": [\"1.2345\", \"-19\"]}"
        var value: DynamoDBEvent.AttributeValue?
        #expect(throws: Never.self) {
            value = try JSONDecoder().decode(DynamoDBEvent.AttributeValue.self, from: json.data(using: .utf8)!)
        }
        #expect(value == .numberSet(["1.2345", "-19"]))
    }

    @Test func attributeValueListDecoding() {
        let json = "{\"L\": [{\"NS\": [\"1.2345\", \"-19\"]}, {\"S\": \"huhu\"}]}"
        var value: DynamoDBEvent.AttributeValue?
        #expect(throws: Never.self) {
            value = try JSONDecoder().decode(DynamoDBEvent.AttributeValue.self, from: json.data(using: .utf8)!)
        }
        #expect(value == .list([.numberSet(["1.2345", "-19"]), .string("huhu")]))
    }

    @Test func attributeValueMapDecoding() {
        let json = "{\"M\": {\"numbers\": {\"NS\": [\"1.2345\", \"-19\"]}, \"string\": {\"S\": \"huhu\"}}}"
        var value: DynamoDBEvent.AttributeValue?
        #expect(throws: Never.self) {
            value = try JSONDecoder().decode(DynamoDBEvent.AttributeValue.self, from: json.data(using: .utf8)!)
        }
        #expect(
            value == .map([
                "numbers": .numberSet(["1.2345", "-19"]),
                "string": .string("huhu"),
            ])
        )
    }

    @Test func attributeValueEmptyDecoding() {
        let json = "{\"haha\": 1}"
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(DynamoDBEvent.AttributeValue.self, from: json.data(using: .utf8)!)
        }
    }

    @Test func attributeValueEquatable() {
        #expect(DynamoDBEvent.AttributeValue.boolean(true) == .boolean(true))
        #expect(DynamoDBEvent.AttributeValue.boolean(true) != .boolean(false))
        #expect(DynamoDBEvent.AttributeValue.boolean(true) != .string("haha"))
    }

    // MARK: - DynamoDB Decoder Tests -

    @Test func decoderSimple() {
        let value: [String: DynamoDBEvent.AttributeValue] = [
            "foo": .string("bar"),
            "xyz": .number("123"),
        ]

        struct Test: Codable {
            let foo: String
            let xyz: UInt8
        }

        let test = try? DynamoDBEvent.Decoder().decode(Test.self, from: value)
        #expect(test?.foo == "bar")
        #expect(test?.xyz == 123)
    }
}
