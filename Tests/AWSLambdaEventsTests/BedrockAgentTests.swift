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
import HTTPTypes
import Testing

@testable import AWSLambdaEvents

@Suite
struct BedrockAgentTests {
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

    @Test func simpleEventFromJSON() throws {
        let data = BedrockAgentTests.eventBody.data(using: .utf8)!
        let event = try JSONDecoder().decode(BedrockAgentRequest.self, from: data)

        #expect(event.messageVersion == "1.0")

        #expect(event.agent?.alias == "AGENT_ID")
        #expect(event.agent?.name == "StockQuoteAgent")
        #expect(event.agent?.version == "DRAFT")
        #expect(event.agent?.id == "PR3AHNYEAA")

        #expect(event.sessionId == "486652066693565")
        #expect(event.inputText == "what the price of amazon stock ?")
        #expect(event.apiPath == "/stocks/{symbol}")
        #expect(event.actionGroup == "StockQuoteService")
        #expect(event.httpMethod == .get)

        #expect(event.parameters?.count == 1)
        #expect(event.parameters?[0].name == "symbol")
        #expect(event.parameters?[0].type == "string")
        #expect(event.parameters?[0].value == "AMZN")

        let body = try #require(event.requestBody?.content)
        let content = try #require(body["application/text"])
        #expect(content.properties.count == 1)
        #expect(content.properties[0].name == "symbol")
        #expect(content.properties[0].type == "string")
        #expect(content.properties[0].value == "AMZN")
    }
}
