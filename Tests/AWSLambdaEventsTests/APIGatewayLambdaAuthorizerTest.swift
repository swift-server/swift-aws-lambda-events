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

    static let lambdaAuthorizerRequest = """
    {
        "version": "2.0",
        "type": "REQUEST",
        "routeArn": "arn:aws:execute-api:eu-north-1:000000000000:0000000000/dev/GET/applications",
        "identitySource": [
            "abc.xyz.123"
        ],
        "routeKey": "GET /applications",
        "rawPath": "/dev/applications",
        "rawQueryString": "",
        "headers": {
            "accept": "*/*",
            "authorization": "abc.xyz.123",
            "content-length": "0",
            "host": "0000000000.execute-api.eu-north-1.amazonaws.com",
            "user-agent": "curl/8.1.2",
            "x-amzn-trace-id": "Root=1-00000000-000000000000000000000000",
            "x-forwarded-for": "0.0.0.0",
            "x-forwarded-port": "443",
            "x-forwarded-proto": "https"
        },
        "requestContext": {
            "accountId": "000000000000",
            "apiId": "0000000000",
            "domainName": "0000000000.execute-api.eu-north-1.amazonaws.com",
            "domainPrefix": "0000000000",
            "http": {
                "method": "GET",
                "path": "/dev/applications",
                "protocol": "HTTP/1.1",
                "sourceIp": "0.0.0.0",
                "userAgent": "curl/8.1.2"
            },
            "requestId": "QHACgr8sig0MELg=",
            "routeKey": "GET /applications",
            "stage": "dev",
            "time": "15/Dec/2023:20:35:03 +0000",
            "timeEpoch": 1702672503230
        }
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

    func testLambdaAuthorizerRequestRequestDecoding() {
        let data = APIGatewayLambdaAuthorizerTests.lambdaAuthorizerRequest.data(using: .utf8)!
        var req: APIGatewayLambdaAuthorizerRequest?
        XCTAssertNoThrow(req = try JSONDecoder().decode(APIGatewayLambdaAuthorizerRequest.self, from: data))

        XCTAssertEqual(req?.rawPath, "/dev/applications")
        XCTAssertEqual(req?.version, "2.0")
    }

    // MARK: Encoding

    func testDecodingLambdaAuthorizerResponse() {
        var resp = APIGatewayLambdaAuthorizerResponse(
            isAuthorized: true,
            context: ["abc1": "xyz1", "abc2": "xyz2"]
        )

        var data: Data?
        XCTAssertNoThrow(data = try JSONEncoder().encode(resp))

        var stringData: String?
        XCTAssertNoThrow(stringData = String(data: try XCTUnwrap(data), encoding: .utf8))

        data = stringData?.data(using: .utf8)
        XCTAssertNoThrow(resp = try JSONDecoder().decode(APIGatewayLambdaAuthorizerResponse.self, from: XCTUnwrap(data)))

        XCTAssertEqual(resp.isAuthorized, true)
        XCTAssertEqual(resp.context?.count, 2)
        XCTAssertEqual(resp.context?["abc1"], "xyz1")
    }
}
