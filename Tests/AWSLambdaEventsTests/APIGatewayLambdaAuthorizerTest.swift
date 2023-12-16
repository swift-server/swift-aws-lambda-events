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

@testable import AWSLambdaEvents
import XCTest

class APIGatewayLambdaAuthorizerTests: XCTestCase {
    static let getEventWithLambdaAuthorizer = """
    {
        "version": "2.0",
        "routeKey": "$default",
        "rawPath": "/hello",
        "rawQueryString": "",
        "headers": {
            "accept": "*/*",
            "authorization": "AWS4-HMAC-SHA256 Credential=ASIA-redacted/us-east-1/execute-api/aws4_request, SignedHeaders=host;x-amz-date;x-amz-security-token, Signature=289b5fcef3d1156f019cc1140cb5565cc052880a5a0d5586c753e3e3c75556f9",
            "content-length": "0",
            "host": "74bxj8iqjc.execute-api.us-east-1.amazonaws.com",
            "user-agent": "curl/8.4.0",
            "x-amz-date": "20231214T203121Z",
            "x-amz-security-token": "IQoJb3JpZ2luX2VjEO3//////////-redacted",
            "x-amzn-trace-id": "Root=1-657b6619-3222de40051925dd66e1fd72",
            "x-forwarded-for": "191.95.150.52",
            "x-forwarded-port": "443",
            "x-forwarded-proto": "https"
        },
        "requestContext": {
            "accountId": "012345678912",
            "apiId": "74bxj8iqjc",
            "authorizer": {
                "lambda": {
                    "abc1": "xyz1",
                    "abc2": "xyz2",
                }
            },
            "domainName": "74bxj8iqjc.execute-api.us-east-1.amazonaws.com",
            "domainPrefix": "74bxj8iqjc",
            "http": {
                "method": "GET",
                "path": "/liveness",
                "protocol": "HTTP/1.1",
                "sourceIp": "191.95.150.52",
                "userAgent": "curl/8.4.0"
            },
            "requestId": "P8zkDiQ8oAMEJsQ=",
            "routeKey": "$default",
            "stage": "$default",
            "time": "14/Dec/2023:20:31:21 +0000",
            "timeEpoch": 1702585881671
        },
        "isBase64Encoded": false
    }
    """

    static let lambdaAuthorizerResponse = """
    {
      "isAuthorized": true,
      "context": {
        "exampleKey": "exampleValue"
      }
    }
    """
    
    // MARK: - Request -

    // MARK: Decoding

    func testRequestDecodingGetRequestWithLambdaAuthorizer() {
        let data = APIGatewayLambdaAuthorizerTests.getEventWithLambdaAuthorizer.data(using: .utf8)!
        var req: APIGatewayV2Request?
        XCTAssertNoThrow(req = try JSONDecoder().decode(APIGatewayV2Request.self, from: data))

        XCTAssertEqual(req?.rawPath, "/hello")
        XCTAssertEqual(req?.context.authorizer?.lambda?.count, 2)
        XCTAssertEqual(req?.context.authorizer?.lambda?["abc1"], "xyz1")
        XCTAssertEqual(req?.context.authorizer?.lambda?["abc2"], "xyz2")
        XCTAssertNil(req?.body)
    }

    func testDecodingLambdaAuthorizerResponse() {
        let data = APIGatewayLambdaAuthorizerTests.lambdaAuthorizerResponse.data(using: .utf8)!
        var response: APIGatewayLambdaAuthorizerResponse?
        XCTAssertNoThrow(response = try JSONDecoder().decode(APIGatewayLambdaAuthorizerResponse.self, from: data))

        XCTAssertEqual(response?.isAuthorized, true)
        XCTAssertEqual(response?.context?.count, 1)
        XCTAssertEqual(response?.context?["exampleKey"], "exampleValue")
    }
}
