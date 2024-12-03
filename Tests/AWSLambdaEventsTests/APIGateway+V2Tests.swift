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

import XCTest

@testable import AWSLambdaEvents

class APIGatewayV2Tests: XCTestCase {
    static let exampleGetEventBody = """
        {
            "routeKey":"GET /hello",
            "version":"2.0",
            "rawPath":"/hello",
            "stageVariables":{
                "foo":"bar"
            },
            "requestContext":{
                "timeEpoch":1587750461466,
                "domainPrefix":"hello",
                "authorizer":{
                    "jwt":{
                        "scopes":[
                            "hello"
                        ],
                        "claims":{
                            "aud":"customers",
                            "iss":"https://hello.test.com/",
                            "iat":"1587749276",
                            "exp":"1587756476"
                        }
                    }
                },
                "accountId":"0123456789",
                "stage":"$default",
                "domainName":"hello.test.com",
                "apiId":"pb5dg6g3rg",
                "requestId":"LgLpnibOFiAEPCA=",
                "http":{
                    "path":"/hello",
                    "userAgent":"Paw/3.1.10 (Macintosh; OS X/10.15.4) GCDHTTPRequest",
                    "method":"GET",
                    "protocol":"HTTP/1.1",
                    "sourceIp":"91.64.117.86"
                },
                "time":"24/Apr/2020:17:47:41 +0000"
            },
            "isBase64Encoded":false,
            "rawQueryString":"foo=bar",
            "queryStringParameters":{
                "foo":"bar"
            },
            "headers":{
                "x-forwarded-proto":"https",
                "x-forwarded-for":"91.64.117.86",
                "x-forwarded-port":"443",
                "authorization":"Bearer abc123",
                "host":"hello.test.com",
                "x-amzn-trace-id":"Root=1-5ea3263d-07c5d5ddfd0788bed7dad831",
                "user-agent":"Paw/3.1.10 (Macintosh; OS X/10.15.4) GCDHTTPRequest",
                "content-length":"0"
            }
        }
        """

    static let exampleGetEventBodyNilHeaders = """
        {
            "routeKey":"GET /hello",
            "version":"2.0",
            "rawPath":"/hello",
            "requestContext":{
                "timeEpoch":1587750461466,
                "domainPrefix":"hello",
                "authorizer":{
                    "jwt":{
                        "scopes":[
                            "hello"
                        ],
                        "claims":{
                            "aud":"customers",
                            "iss":"https://hello.test.com/",
                            "iat":"1587749276",
                            "exp":"1587756476"
                        }
                    }
                },
                "accountId":"0123456789",
                "stage":"$default",
                "domainName":"hello.test.com",
                "apiId":"pb5dg6g3rg",
                "requestId":"LgLpnibOFiAEPCA=",
                "http":{
                    "path":"/hello",
                    "userAgent":"Paw/3.1.10 (Macintosh; OS X/10.15.4) GCDHTTPRequest",
                    "method":"GET",
                    "protocol":"HTTP/1.1",
                    "sourceIp":"91.64.117.86"
                },
                "time":"24/Apr/2020:17:47:41 +0000"
            },
            "isBase64Encoded":false,
            "rawQueryString":"foo=bar"
        }
        """

    static let fullExamplePayload = """
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
                "apiId": "api-id",
                "authentication": {
                "clientCert": {
                    "clientCertPem": "CERT_CONTENT",
                    "subjectDN": "www.example.com",
                    "issuerDN": "Example issuer",
                    "serialNumber": "a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1",
                    "validity": {
                    "notBefore": "May 28 12:30:02 2019 GMT",
                    "notAfter": "Aug  5 09:36:04 2021 GMT"
                    }
                }
                },
                "authorizer": {
                "jwt": {
                    "claims": {
                    "claim1": "value1",
                    "claim2": "value2"
                    },
                    "scopes": [
                    "scope1",
                    "scope2"
                    ]
                }
                },
                "domainName": "id.execute-api.us-east-1.amazonaws.com",
                "domainPrefix": "id",
                "http": {
                "method": "POST",
                "path": "/my/path",
                "protocol": "HTTP/1.1",
                "sourceIp": "192.0.2.1",
                "userAgent": "agent"
                },
                "requestId": "id",
                "routeKey": "$default",
                "stage": "$default",
                "time": "12/Mar/2020:19:03:58 +0000",
                "timeEpoch": 1583348638390
            },
            "body": "Hello from Lambda",
            "pathParameters": {
                "parameter1": "value1"
            },
            "isBase64Encoded": false,
            "stageVariables": {
                "stageVariable1": "value1",
                "stageVariable2": "value2"
            }
        }
        """

    // MARK: - Request -

    // MARK: Decoding

    func testRequestDecodingExampleGetRequest() {
        let data = APIGatewayV2Tests.exampleGetEventBody.data(using: .utf8)!
        var req: APIGatewayV2Request?
        XCTAssertNoThrow(req = try JSONDecoder().decode(APIGatewayV2Request.self, from: data))

        XCTAssertEqual(req?.rawPath, "/hello")
        XCTAssertEqual(req?.context.http.method, .get)
        XCTAssertEqual(req?.queryStringParameters.count, 1)
        XCTAssertEqual(req?.rawQueryString, "foo=bar")
        XCTAssertEqual(req?.headers.count, 8)
        XCTAssertEqual(req?.context.authorizer?.jwt?.claims?["aud"], "customers")

        XCTAssertNil(req?.body)
    }

    func testDecodingRequestClientCert() throws {
        let data = APIGatewayV2Tests.fullExamplePayload.data(using: .utf8)!
        let request = try JSONDecoder().decode(APIGatewayV2Request.self, from: data)
        let clientCert = request.context.authentication?.clientCert

        XCTAssertEqual(clientCert?.clientCertPem, "CERT_CONTENT")
        XCTAssertEqual(clientCert?.subjectDN, "www.example.com")
        XCTAssertEqual(clientCert?.issuerDN, "Example issuer")
        XCTAssertEqual(clientCert?.serialNumber, "a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1:a1")
        XCTAssertEqual(clientCert?.validity.notBefore, "May 28 12:30:02 2019 GMT")
        XCTAssertEqual(clientCert?.validity.notAfter, "Aug  5 09:36:04 2021 GMT")
    }

    func testDecodingNilCollections() {
        let data = APIGatewayV2Tests.exampleGetEventBodyNilHeaders.data(using: .utf8)!
        XCTAssertNoThrow(_ = try JSONDecoder().decode(APIGatewayV2Request.self, from: data))
    }
}
