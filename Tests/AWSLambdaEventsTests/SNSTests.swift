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
struct SNSTests {
    static let eventBody = """
        {
          "Records": [
            {
              "EventSource": "aws:sns",
              "EventVersion": "1.0",
              "EventSubscriptionArn": "arn:aws:sns:eu-central-1:079477498937:EventSources-SNSTopic-1NHENSE2MQKF5:6fabdb7f-b27e-456d-8e8a-14679db9e40c",
              "Sns": {
                "Type": "Notification",
                "MessageId": "bdb6900e-1ae9-5b4b-b7fc-c681fde222e3",
                "TopicArn": "arn:aws:sns:eu-central-1:079477498937:EventSources-SNSTopic-1NHENSE2MQKF5",
                "Subject": null,
                "Message": "{\\\"hello\\\": \\\"world\\\"}",
                "Timestamp": "2020-01-08T14:18:51.203Z",
                "SignatureVersion": "1",
                "Signature": "LJMF/xmMH7A1gNy2unLA3hmzyf6Be+zS/Yeiiz9tZbu6OG8fwvWZeNOcEZardhSiIStc0TF7h9I+4Qz3omCntaEfayzTGmWN8itGkn2mfn/hMFmPbGM8gEUz3+jp1n6p+iqP3XTx92R0LBIFrU3ylOxSo8+SCOjA015M93wfZzwj0WPtynji9iAvvtf15d8JxPUu1T05BRitpFd5s6ZXDHtVQ4x/mUoLUN8lOVp+rs281/ZdYNUG/V5CwlyUDTOERdryTkBJ/GO1NNPa+6m04ywJFa5d+BC8mDcUcHhhXXjpTEbt8AHBmswK3nudHrVMRO/G4zmssxU2P7ii5+gCfA==",
                "SigningCertUrl": "https://sns.eu-central-1.amazonaws.com/SimpleNotificationService-6aad65c2f9911b05cd53efda11f913f9.pem",
                "UnsubscribeUrl": "https://sns.eu-central-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:eu-central-1:079477498937:EventSources-SNSTopic-1NHENSE2MQKF5:6fabdb7f-b27e-456d-8e8a-14679db9e40c",
                "MessageAttributes": {
                  "binary":{
                    "Type": "Binary",
                    "Value": "YmFzZTY0"
                  },
                  "string":{
                    "Type": "String",
                    "Value": "abc123"
                  }
                }
              }
            }
          ]
        }
        """

    @Test func simpleEventFromJSON() throws {
        let data = SNSTests.eventBody.data(using: .utf8)!
        let event = try JSONDecoder().decode(SNSEvent.self, from: data)

        guard let record = event.records.first else {
            Issue.record("Expected to have one record")
            return
        }

        #expect(record.eventSource == "aws:sns")
        #expect(record.eventVersion == "1.0")
        #expect(
            record.eventSubscriptionArn == "arn:aws:sns:eu-central-1:079477498937:EventSources-SNSTopic-1NHENSE2MQKF5:6fabdb7f-b27e-456d-8e8a-14679db9e40c"
        )

        #expect(record.sns.type == "Notification")
        #expect(record.sns.messageId == "bdb6900e-1ae9-5b4b-b7fc-c681fde222e3")
        #expect(record.sns.topicArn == "arn:aws:sns:eu-central-1:079477498937:EventSources-SNSTopic-1NHENSE2MQKF5")
        #expect(record.sns.message == "{\"hello\": \"world\"}")
        #expect(abs(record.sns.timestamp.timeIntervalSince1970 - 1_578_493_131.203) < 0.001)
        #expect(record.sns.signatureVersion == "1")
        #expect(
            record.sns.signature == "LJMF/xmMH7A1gNy2unLA3hmzyf6Be+zS/Yeiiz9tZbu6OG8fwvWZeNOcEZardhSiIStc0TF7h9I+4Qz3omCntaEfayzTGmWN8itGkn2mfn/hMFmPbGM8gEUz3+jp1n6p+iqP3XTx92R0LBIFrU3ylOxSo8+SCOjA015M93wfZzwj0WPtynji9iAvvtf15d8JxPUu1T05BRitpFd5s6ZXDHtVQ4x/mUoLUN8lOVp+rs281/ZdYNUG/V5CwlyUDTOERdryTkBJ/GO1NNPa+6m04ywJFa5d+BC8mDcUcHhhXXjpTEbt8AHBmswK3nudHrVMRO/G4zmssxU2P7ii5+gCfA=="
        )
        #expect(
            record.sns.signingCertURL == "https://sns.eu-central-1.amazonaws.com/SimpleNotificationService-6aad65c2f9911b05cd53efda11f913f9.pem"
        )
        #expect(
            record.sns.unsubscribeURL == "https://sns.eu-central-1.amazonaws.com/?Action=Unsubscribe&SubscriptionArn=arn:aws:sns:eu-central-1:079477498937:EventSources-SNSTopic-1NHENSE2MQKF5:6fabdb7f-b27e-456d-8e8a-14679db9e40c"
        )

        #expect(record.sns.messageAttributes?.count == 2)

        #expect(record.sns.messageAttributes?["binary"] == .binary([UInt8]("base64".utf8)))
        #expect(record.sns.messageAttributes?["string"] == .string("abc123"))
    }
}
