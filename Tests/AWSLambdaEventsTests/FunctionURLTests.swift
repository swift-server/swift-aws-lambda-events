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

class FunctionURLTests: XCTestCase {
    /// Example event body pulled from [AWS documentation](https://docs.aws.amazon.com/lambda/latest/dg/urls-invocation.html#urls-request-payload).
    static let documentationExample = """
    {
        "version": "2.0",
        "routeKey": "$default",
        "rawPath": "/my/path",
        "rawQueryString": "parameter1=value1&parameter1=value2&parameter2=value",
        "cookies": [
            "cookie1",
            "cookie2"
        ],
        "headers": {
            "header1": "value1",
            "header2": "value1,value2"
        },
        "queryStringParameters": {
            "parameter1": "value1,value2",
            "parameter2": "value"
        },
        "requestContext": {
            "accountId": "123456789012",
            "apiId": "<urlid>",
            "authentication": null,
            "authorizer": {
                "iam": {
                    "accessKey": "AKIA...",
                    "accountId": "111122223333",
                    "callerId": "AIDA...",
                    "cognitoIdentity": null,
                    "principalOrgId": null,
                    "userArn": "arn:aws:iam::111122223333:user/example-user",
                    "userId": "AIDA..."
                }
            },
            "domainName": "<url-id>.lambda-url.us-west-2.on.aws",
            "domainPrefix": "<url-id>",
            "http": {
                "method": "POST",
                "path": "/my/path",
                "protocol": "HTTP/1.1",
                "sourceIp": "123.123.123.123",
                "userAgent": "agent"
            },
            "requestId": "id",
            "routeKey": "$default",
            "stage": "$default",
            "time": "12/Mar/2020:19:03:58 +0000",
            "timeEpoch": 1583348638390
        },
        "body": "Hello from client!",
        "pathParameters": null,
        "isBase64Encoded": false,
        "stageVariables": null
    }
    """

    /// Example event body pulled from an an actual Lambda invocation.
    static let realWorldExample = """
    {
        "headers": {
            "x-amzn-tls-cipher-suite": "ECDHE-RSA-AES128-GCM-SHA256",
            "x-amzn-tls-version": "TLSv1.2",
            "x-amzn-trace-id": "Root=0-12345678-9abcdef0123456789abcdef0",
            "cookie": "test",
            "x-forwarded-proto": "https",
            "host": "0123456789abcdefghijklmnopqrstuv.lambda-url.us-west-2.on.aws",
            "x-forwarded-port": "443",
            "x-forwarded-for": "1.2.3.4",
            "accept": "*/*",
            "user-agent": "curl"
        },
        "isBase64Encoded": false,
        "rawPath": "/",
        "routeKey": "$default",
        "requestContext": {
            "accountId": "anonymous",
            "timeEpoch": 1667192002044,
            "routeKey": "$default",
            "stage": "$default",
            "domainPrefix": "0123456789abcdefghijklmnopqrstuv",
            "requestId": "01234567-89ab-cdef-0123-456789abcdef",
            "domainName": "0123456789abcdefghijklmnopqrstuv.lambda-url.us-west-2.on.aws",
            "http": {
                "path": "/",
                "protocol": "HTTP/1.1",
                "method": "GET",
                "sourceIp": "1.2.3.4",
                "userAgent": "curl"
            },
            "time": "31/Oct/2022:04:53:22 +0000",
            "apiId": "0123456789abcdefghijklmnopqrstuv"
        },
        "queryStringParameters": {
            "test": "2"
        },
        "version": "2.0",
        "rawQueryString": "test=2",
        "cookies": [
            "test"
        ]
    }
    """

    // MARK: - Request -

    // MARK: Decoding

    func testRequestDecodingDocumentationExampleRequest() {
        let data = Self.documentationExample.data(using: .utf8)!
        var req: FunctionURLRequest?
        XCTAssertNoThrow(req = try JSONDecoder().decode(FunctionURLRequest.self, from: data))

        XCTAssertEqual(req?.rawPath, "/my/path")
        XCTAssertEqual(req?.requestContext.http.method, .post)
        XCTAssertEqual(req?.queryStringParameters?.count, 2)
        XCTAssertEqual(req?.rawQueryString, "parameter1=value1&parameter1=value2&parameter2=value")
        XCTAssertEqual(req?.headers.count, 2)
        XCTAssertEqual(req?.body, "Hello from client!")
    }

    func testRequestDecodingRealWorldExampleRequest() {
        let data = Self.realWorldExample.data(using: .utf8)!
        var req: FunctionURLRequest?
        XCTAssertNoThrow(req = try JSONDecoder().decode(FunctionURLRequest.self, from: data))

        XCTAssertEqual(req?.rawPath, "/")
        XCTAssertEqual(req?.requestContext.http.method, .get)
        XCTAssertEqual(req?.queryStringParameters?.count, 1)
        XCTAssertEqual(req?.rawQueryString, "test=2")
        XCTAssertEqual(req?.headers.count, 10)
        XCTAssertEqual(req?.cookies, ["test"])
        XCTAssertNil(req?.body)
    }
}
