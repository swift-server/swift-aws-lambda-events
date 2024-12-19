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

class LambdaGatewayProxyEventTests: XCTestCase {
    static let exampleLambdaProxyEvent = """
        {
            "resource": "/hello",
            "path": "/hello",
            "httpMethod": "GET",
            "headers": {
                "x-forwarded-proto":"https",
                "x-forwarded-for":"91.64.117.86",
                "x-forwarded-port":"443",
                "authorization":"Bearer abc123",
                "host":"hello.test.com",
                "x-amzn-trace-id":"Root=1-5ea3263d-07c5d5ddfd0788bed7dad831",
                "user-agent":"Paw/3.1.10 (Macintosh; OS X/10.15.4) GCDHTTPRequest",
                "content-length":"0"
            },
            "multiValueHeaders": {
              "header1": [
                "value1"
              ],
              "header2": [
                "value1",
                "value2"
              ]
            },
            "queryStringParameters": {
                "foo":"bar"
            },
            "multiValueQueryStringParameters": {
              "parameter1": [
                "value1",
                "value2"
              ],
              "parameter2": [
                "value"
              ]
            },
            "requestContext": {
              "accountId": "123456789012",
              "apiId":"pb5dg6g3rg",
              "authorizer": {
                "scopes":[
                    "hello"
                ],
                "claims":{
                    "aud":"customers",
                    "iss":"https://hello.test.com/",
                    "iat":"1587749276",
                    "exp":"1587756476"
                }
              },
              "domainName": "id.execute-api.us-east-1.amazonaws.com",
              "domainPrefix": "id",
              "extendedRequestId": "request-id",
              "httpMethod": "GET",
              "identity": {
                "accessKey": null,
                "accountId": null,
                "caller": null,
                "cognitoAuthenticationProvider": null,
                "cognitoAuthenticationType": null,
                "cognitoIdentityId": null,
                "cognitoIdentityPoolId": null,
                "principalOrgId": null,
                "sourceIp":"91.64.117.86",
                "user": null,
                "userAgent":"Paw/3.1.10 (Macintosh; OS X/10.15.4) GCDHTTPRequest",
                "userArn": null,
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
              "path": "/hello",
              "protocol": "HTTP/1.1",
              "requestId":"LgLpnibOFiAEPCA=",
              "requestTime": "04/Mar/2020:19:15:17 +0000",
              "requestTimeEpoch": 1587750461466,
              "resourceId": null,
              "resourcePath": "/my/path",
              "stage": "$default"
            },
            "pathParameters": null,
            "stageVariables":{
                "foo":"bar"
            },
            "body": "Hello from Lambda!",
            "isBase64Encoded": false
          }
        """

    // MARK: - Request -

    // MARK: Decoding

    func testRequestDecodingExampleProxyRequest() {
        let data = LambdaGatewayProxyEventTests.exampleLambdaProxyEvent.data(using: .utf8)!
        var req: LambdaGatewayProxyEvent?
        XCTAssertNoThrow(req = try JSONDecoder().decode(LambdaGatewayProxyEvent.self, from: data))

        XCTAssertEqual(req?.path, "/hello")
        XCTAssertEqual(req?.requestContext.httpMethod, .get)
        XCTAssertEqual(req?.queryStringParameters?.count, 1)
        XCTAssertEqual(req?.headers.count, 8)
        XCTAssertNotNil(req?.body)
    }
}
