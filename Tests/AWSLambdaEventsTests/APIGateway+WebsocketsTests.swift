//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) YEARS Apple Inc. and the SwiftAWSLambdaRuntime project authors
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
class APIGatewayWebSocketsTests {
    static let exampleConnectEventBody = """
        {
          "headers": {
            "Host": "lqrlmblaa2.execute-api.us-east-1.amazonaws.com",
            "Origin": "wss://lqrlmblaa2.execute-api.us-east-1.amazonaws.com",
            "Sec-WebSocket-Extensions": "",
            "Sec-WebSocket-Key": "am5ubWVpbHd3bmNyYXF0ag==",
            "Sec-WebSocket-Version": "13",
            "X-Amzn-Trace-Id": "Root=1-64b83950-42de8e247b4c2b43091ef67c",
            "X-Forwarded-For": "24.148.42.16",
            "X-Forwarded-Port": "443",
            "X-Forwarded-Proto": "https"
          },
          "multiValueHeaders": {
            "Host": [ "lqrlmblaa2.execute-api.us-east-1.amazonaws.com" ],
            "Origin": [ "wss://lqrlmblaa2.execute-api.us-east-1.amazonaws.com" ],
            "Sec-WebSocket-Extensions": [
              "permessage-deflate; client_max_window_bits; server_max_window_bits=15"
            ],
            "Sec-WebSocket-Key": [ "am5ubWVpbHd3bmNyYXF0ag==" ],
            "Sec-WebSocket-Version": [ "13" ],
            "X-Amzn-Trace-Id": [ "Root=1-64b83950-42de8e247b4c2b43091ef67c" ],
            "X-Forwarded-For": [ "24.148.42.16" ],
            "X-Forwarded-Port": [ "443" ],
            "X-Forwarded-Proto": [ "https" ]
          },
          "requestContext": {
            "routeKey": "$connect",
            "eventType": "CONNECT",
            "extendedRequestId": "IU3kkGyEoAMFwZQ=",
            "requestTime": "19/Jul/2023:19:28:16 +0000",
            "messageDirection": "IN",
            "stage": "dev",
            "connectedAt": 1689794896145,
            "requestTimeEpoch": 1689794896162,
            "identity": { "sourceIp": "24.148.42.16" },
            "requestId": "IU3kkGyEoAMFwZQ=",
            "domainName": "lqrlmblaa2.execute-api.us-east-1.amazonaws.com",
            "connectionId": "IU3kkeN4IAMCJwA=",
            "apiId": "lqrlmblaa2"
          },
          "isBase64Encoded": false
        }
        """

    // MARK: - Request -

    // MARK: Decoding
    @Test func testRequestDecodingExampleConnectRequest() async throws {
        let data = APIGatewayWebSocketsTests.exampleConnectEventBody.data(using: .utf8)!
        let req = try JSONDecoder().decode(APIGatewayWebSocketRequest.self, from: data)

        #expect(req.context.routeKey == "$connect")
        #expect(req.context.connectionId == "IU3kkeN4IAMCJwA=")
        #expect(req.body == nil)
    }
}
