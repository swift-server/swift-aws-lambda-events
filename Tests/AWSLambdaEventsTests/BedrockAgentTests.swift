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

import HTTPTypes
import XCTest

@testable import AWSLambdaEvents

class BedrockAgentTests: XCTestCase {
    static let eventBody =
        """
        {
          "messageVersion": "1.0",
          "agent": {
            "alias": "AGENT_ID",
            "name": "StockQuoteAgent",
            "version": "DRAFT",
            "id": "PR3AHNYEAA"
          },
          "sessionId": "486652066693565",
          "sessionAttributes": {},
          "promptSessionAttributes": {},
          "inputText": "what the price of amazon stock ?",
          "apiPath": "/stocks/{symbol}",
          "actionGroup": "StockQuoteService",
          "httpMethod": "GET",
          "parameters": [
            {
              "name": "symbol",
              "type": "string",
              "value": "AMZN"
            }
          ],
          "requestBody": {
              "content": {
                  "application/text": {
                      "properties": [
                        {
                            "name": "symbol",
                            "type": "string",
                            "value": "AMZN"
                          }
                      ]
                  }
              }
          }         
        }
        """

    func testSimpleEventFromJSON() throws {
        let data = BedrockAgentTests.eventBody.data(using: .utf8)!
        var event: BedrockAgentRequest?
        XCTAssertNoThrow(event = try JSONDecoder().decode(BedrockAgentRequest.self, from: data))

        XCTAssertEqual(event?.messageVersion, "1.0")

        XCTAssertEqual(event?.agent?.alias, "AGENT_ID")
        XCTAssertEqual(event?.agent?.name, "StockQuoteAgent")
        XCTAssertEqual(event?.agent?.version, "DRAFT")
        XCTAssertEqual(event?.agent?.id, "PR3AHNYEAA")

        XCTAssertEqual(event?.sessionId, "486652066693565")
        XCTAssertEqual(event?.inputText, "what the price of amazon stock ?")
        XCTAssertEqual(event?.apiPath, "/stocks/{symbol}")
        XCTAssertEqual(event?.actionGroup, "StockQuoteService")
        XCTAssertEqual(event?.httpMethod, .get)

        XCTAssertTrue(event?.parameters?.count == 1)
        XCTAssertEqual(event?.parameters?[0].name, "symbol")
        XCTAssertEqual(event?.parameters?[0].type, "string")
        XCTAssertEqual(event?.parameters?[0].value, "AMZN")

        let body = try XCTUnwrap(event?.requestBody?.content)
        let content = try XCTUnwrap(body["application/text"])
        XCTAssertTrue(content.properties.count == 1)
        XCTAssertEqual(content.properties[0].name, "symbol")
        XCTAssertEqual(content.properties[0].type, "string")
        XCTAssertEqual(content.properties[0].value, "AMZN")
    }
}
