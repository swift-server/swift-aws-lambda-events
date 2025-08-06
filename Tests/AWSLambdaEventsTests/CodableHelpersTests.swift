//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) 2017-2022 Apple Inc. and the SwiftAWSLambdaRuntime project authors
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

/// Tests for the DecodableRequest and EncodableResponse protocols
struct CodableHelpersTests {

    // MARK: - DecodableRequest Tests

    @Test func decodableRequestProtocolConformanceAPIGatewayV2() throws {
        // Test that APIGatewayV2Request conforms to DecodableRequest protocol
        let requestJSON = """
            {
                "routeKey": "GET /test",
                "version": "2.0",
                "rawPath": "/test",
                "rawQueryString": "",
                "requestContext": {
                    "timeEpoch": 1587750461466,
                    "domainPrefix": "hello",
                    "accountId": "0123456789",
                    "stage": "$default",
                    "domainName": "hello.test.com",
                    "apiId": "pb5dg6g3rg",
                    "requestId": "LgLpnibOFiAEPCA=",
                    "http": {
                        "path": "/test",
                        "userAgent": "test",
                        "method": "GET",
                        "protocol": "HTTP/1.1",
                        "sourceIp": "127.0.0.1"
                    },
                    "time": "24/Apr/2020:17:47:41 +0000"
                },
                "isBase64Encoded": false,
                "body": null
            }
            """

        let data = requestJSON.data(using: .utf8)!
        let request = try JSONDecoder().decode(APIGatewayV2Request.self, from: data)

        // Test protocol conformance through polymorphism
        let decodableRequest: DecodableRequest = request
        let bodyData = try decodableRequest.decodeBody()
        #expect(bodyData == nil)  // Since body is null
    }

    @Test func decodableRequestProtocolConformanceFunctionURL() throws {
        // Test that FunctionURLRequest conforms to DecodableRequest protocol
        let requestJSON = """
            {
                "version": "2.0",
                "routeKey": "$default",
                "rawPath": "/test",
                "rawQueryString": "",
                "headers": {},
                "requestContext": {
                    "accountId": "123456789012",
                    "apiId": "<urlid>",
                    "domainName": "<url-id>.lambda-url.us-west-2.on.aws",
                    "domainPrefix": "<url-id>",
                    "http": {
                        "method": "GET",
                        "path": "/test",
                        "protocol": "HTTP/1.1",
                        "sourceIp": "123.123.123.123",
                        "userAgent": "test"
                    },
                    "requestId": "id",
                    "routeKey": "$default",
                    "stage": "$default",
                    "time": "12/Mar/2020:19:03:58 +0000",
                    "timeEpoch": 1583348638390
                },
                "body": null,
                "isBase64Encoded": false
            }
            """

        let data = requestJSON.data(using: .utf8)!
        let request = try JSONDecoder().decode(FunctionURLRequest.self, from: data)

        // Test protocol conformance through polymorphism
        let decodableRequest: DecodableRequest = request
        let bodyData = try decodableRequest.decodeBody()
        #expect(bodyData == nil)  // Since body is null
    }

    @Test func decodableRequestDecodeBodyWithPlainText() throws {
        let requestJSON = """
            {
                "routeKey": "POST /test",
                "version": "2.0",
                "rawPath": "/test",
                "rawQueryString": "",
                "requestContext": {
                    "timeEpoch": 1587750461466,
                    "domainPrefix": "hello",
                    "accountId": "0123456789",
                    "stage": "$default",
                    "domainName": "hello.test.com",
                    "apiId": "pb5dg6g3rg",
                    "requestId": "LgLpnibOFiAEPCA=",
                    "http": {
                        "path": "/test",
                        "userAgent": "test",
                        "method": "POST",
                        "protocol": "HTTP/1.1",
                        "sourceIp": "127.0.0.1"
                    },
                    "time": "24/Apr/2020:17:47:41 +0000"
                },
                "isBase64Encoded": false,
                "body": "Hello, World!"
            }
            """

        let data = requestJSON.data(using: .utf8)!
        let request = try JSONDecoder().decode(APIGatewayV2Request.self, from: data)

        let decodedBody = try request.decodeBody()
        let expectedBody = "Hello, World!".data(using: .utf8)
        #expect(decodedBody == expectedBody)
    }

    @Test func decodableRequestDecodeBodyWithBase64() throws {
        let requestJSON = """
            {
                "routeKey": "POST /test",
                "version": "2.0",
                "rawPath": "/test",
                "rawQueryString": "",
                "requestContext": {
                    "timeEpoch": 1587750461466,
                    "domainPrefix": "hello",
                    "accountId": "0123456789",
                    "stage": "$default",
                    "domainName": "hello.test.com",
                    "apiId": "pb5dg6g3rg",
                    "requestId": "LgLpnibOFiAEPCA=",
                    "http": {
                        "path": "/test",
                        "userAgent": "test",
                        "method": "POST",
                        "protocol": "HTTP/1.1",
                        "sourceIp": "127.0.0.1"
                    },
                    "time": "24/Apr/2020:17:47:41 +0000"
                },
                "isBase64Encoded": true,
                "body": "SGVsbG8sIFdvcmxkIQ=="
            }
            """

        let data = requestJSON.data(using: .utf8)!
        let request = try JSONDecoder().decode(APIGatewayV2Request.self, from: data)

        let decodedBody = try request.decodeBody()
        let expectedBody = "Hello, World!".data(using: .utf8)
        #expect(decodedBody == expectedBody)
    }

    @Test func decodableRequestDecodeBodyAsDecodableType() throws {
        struct TestPayload: Codable, Equatable {
            let message: String
            let count: Int
        }

        let testPayload = TestPayload(message: "test", count: 42)

        let requestJSON = """
            {
                "routeKey": "POST /test",
                "version": "2.0",
                "rawPath": "/test",
                "rawQueryString": "",
                "requestContext": {
                    "timeEpoch": 1587750461466,
                    "domainPrefix": "hello",
                    "accountId": "0123456789",
                    "stage": "$default",
                    "domainName": "hello.test.com",
                    "apiId": "pb5dg6g3rg",
                    "requestId": "LgLpnibOFiAEPCA=",
                    "http": {
                        "path": "/test",
                        "userAgent": "test",
                        "method": "POST",
                        "protocol": "HTTP/1.1",
                        "sourceIp": "127.0.0.1"
                    },
                    "time": "24/Apr/2020:17:47:41 +0000"
                },
                "isBase64Encoded": false,
                "body": "{\\"message\\":\\"test\\",\\"count\\":42}"
            }
            """

        let data = requestJSON.data(using: .utf8)!
        let request = try JSONDecoder().decode(APIGatewayV2Request.self, from: data)

        let decodedPayload = try request.decodeBody(TestPayload.self)
        #expect(decodedPayload == testPayload)
    }

    @Test func decodableRequestDecodeBodyAsDecodableTypeWithBase64() throws {
        struct TestPayload: Codable, Equatable {
            let message: String
            let count: Int
        }

        let testPayload = TestPayload(message: "test", count: 42)
        let jsonData = try JSONEncoder().encode(testPayload)
        let base64String = jsonData.base64EncodedString()

        let requestJSON = """
            {
                "routeKey": "POST /test",
                "version": "2.0",
                "rawPath": "/test",
                "rawQueryString": "",
                "requestContext": {
                    "timeEpoch": 1587750461466,
                    "domainPrefix": "hello",
                    "accountId": "0123456789",
                    "stage": "$default",
                    "domainName": "hello.test.com",
                    "apiId": "pb5dg6g3rg",
                    "requestId": "LgLpnibOFiAEPCA=",
                    "http": {
                        "path": "/test",
                        "userAgent": "test",
                        "method": "POST",
                        "protocol": "HTTP/1.1",
                        "sourceIp": "127.0.0.1"
                    },
                    "time": "24/Apr/2020:17:47:41 +0000"
                },
                "isBase64Encoded": true,
                "body": "\(base64String)"
            }
            """

        let data = requestJSON.data(using: .utf8)!
        let request = try JSONDecoder().decode(APIGatewayV2Request.self, from: data)

        let decodedPayload = try request.decodeBody(TestPayload.self)
        #expect(decodedPayload == testPayload)
    }

    // MARK: - EncodableResponse Tests

    @Test func encodableResponseProtocolConformanceAPIGatewayV2() {
        struct TestPayload: Codable {
            let message: String
            let count: Int
        }

        let testPayload = TestPayload(message: "test", count: 42)

        // Test that APIGatewayV2Response conforms to EncodableResponse protocol
        let response = APIGatewayV2Response.encoding(testPayload, onError: APIGatewayV2Response.defaultErrorHandler)

        #expect(response.statusCode == .ok)
        #expect(response.body != nil)
    }

    @Test func encodableResponseProtocolConformanceFunctionURL() {
        struct TestPayload: Codable {
            let message: String
            let count: Int
        }

        let testPayload = TestPayload(message: "test", count: 42)

        // Test that FunctionURLResponse conforms to EncodableResponse protocol
        let response = FunctionURLResponse.encoding(testPayload, onError: FunctionURLResponse.defaultErrorHandler)

        #expect(response.statusCode == .ok)
        #expect(response.body != nil)
    }

    @Test func encodableResponseEncodingWithDefaultParameters() throws {
        struct TestPayload: Codable, Equatable {
            let message: String
            let count: Int
        }

        let testPayload = TestPayload(message: "Hello", count: 123)

        let response = APIGatewayV2Response.encoding(testPayload)

        #expect(response.statusCode == .ok)
        #expect(response.body != nil)
        #expect(response.headers == nil)
        #expect(response.cookies == nil)
        #expect(response.isBase64Encoded == nil)

        let bodyData = try #require(response.body?.data(using: .utf8))
        let decodedPayload = try JSONDecoder().decode(TestPayload.self, from: bodyData)
        #expect(decodedPayload == testPayload)
    }

    @Test func encodableResponseEncodingWithCustomStatus() throws {
        struct TestPayload: Codable, Equatable {
            let message: String
            let count: Int
        }

        let testPayload = TestPayload(message: "Created", count: 201)

        let response = APIGatewayV2Response.encoding(testPayload, status: .created)

        #expect(response.statusCode == .created)
        #expect(response.body != nil)

        let bodyData = try #require(response.body?.data(using: .utf8))
        let decodedPayload = try JSONDecoder().decode(TestPayload.self, from: bodyData)
        #expect(decodedPayload == testPayload)
    }

    @Test func encodableResponseEncodingWithCustomEncoder() throws {
        struct TestPayload: Codable, Equatable {
            let message: String
            let count: Int
        }

        let testPayload = TestPayload(message: "Pretty", count: 42)
        let customEncoder = JSONEncoder()
        customEncoder.outputFormatting = .prettyPrinted

        let response = APIGatewayV2Response.encoding(testPayload, using: customEncoder)

        #expect(response.statusCode == .ok)
        #expect(response.body != nil)
        #expect(response.body?.contains("\n") == true)  // Pretty printed JSON should contain newlines

        let bodyData = try #require(response.body?.data(using: .utf8))
        let decodedPayload = try JSONDecoder().decode(TestPayload.self, from: bodyData)
        #expect(decodedPayload == testPayload)
    }

    @Test func encodableResponseEncodingWithHeadersAndCookies() throws {
        struct TestPayload: Codable, Equatable {
            let message: String
            let count: Int
        }

        let testPayload = TestPayload(message: "WithHeaders", count: 200)
        let headers = ["Content-Type": "application/json", "X-Custom-Header": "CustomValue"]
        let cookies = ["session=abc123", "token=xyz789"]

        let response = APIGatewayV2Response.encoding(
            testPayload,
            status: .ok,
            headers: headers,
            cookies: cookies
        )

        #expect(response.statusCode == .ok)
        #expect(response.body != nil)
        #expect(response.headers == headers)
        #expect(response.cookies == cookies)

        let bodyData = try #require(response.body?.data(using: .utf8))
        let decodedPayload = try JSONDecoder().decode(TestPayload.self, from: bodyData)
        #expect(decodedPayload == testPayload)
    }

    @Test func encodableResponseEncodingWithErrorHandler() {
        struct FailingEncoder: Encodable {
            func encode(to encoder: Encoder) throws {
                throw TestError.encodingFailed
            }
        }

        enum TestError: Error {
            case encodingFailed
        }

        let failingObject = FailingEncoder()

        let response = APIGatewayV2Response.encoding(failingObject) { error in
            APIGatewayV2Response(
                statusCode: .badRequest,
                headers: ["X-Error": "Custom"],
                body: "Custom error: \(error)",
                isBase64Encoded: false,
                cookies: nil
            )
        }

        #expect(response.statusCode == .badRequest)
        #expect(response.headers?["X-Error"] == "Custom")
        #expect(response.body?.contains("Custom error:") == true)
    }

    @Test func encodableResponseDefaultErrorHandler() {
        struct FailingEncoder: Encodable {
            func encode(to encoder: Encoder) throws {
                throw TestError.encodingFailed
            }
        }

        enum TestError: Error {
            case encodingFailed
        }

        let failingObject = FailingEncoder()

        let response = APIGatewayV2Response.encoding(failingObject)

        #expect(response.statusCode == .internalServerError)
        #expect(response.body?.contains("Internal Server Error:") == true)
        #expect(response.body?.contains("encodingFailed") == true)
    }

    // MARK: - Cross-Protocol Integration Tests

    @Test func decodableRequestAndEncodableResponseIntegration() throws {
        struct RequestPayload: Codable, Equatable {
            let message: String
            let count: Int
        }

        struct ResponsePayload: Codable, Equatable {
            let processedMessage: String
            let doubledCount: Int
        }

        // Create a request with a JSON payload
        let requestPayload = RequestPayload(message: "process me", count: 21)

        let fullRequestJSON = """
            {
                "routeKey": "POST /process",
                "version": "2.0",
                "rawPath": "/process",
                "rawQueryString": "",
                "requestContext": {
                    "timeEpoch": 1587750461466,
                    "domainPrefix": "hello",
                    "accountId": "0123456789",
                    "stage": "$default",
                    "domainName": "hello.test.com",
                    "apiId": "pb5dg6g3rg",
                    "requestId": "LgLpnibOFiAEPCA=",
                    "http": {
                        "path": "/process",
                        "userAgent": "test",
                        "method": "POST",
                        "protocol": "HTTP/1.1",
                        "sourceIp": "127.0.0.1"
                    },
                    "time": "24/Apr/2020:17:47:41 +0000"
                },
                "isBase64Encoded": false,
                "body": "{\\"message\\":\\"process me\\",\\"count\\":21}"
            }
            """

        let data = fullRequestJSON.data(using: .utf8)!
        let request = try JSONDecoder().decode(APIGatewayV2Request.self, from: data)

        // Decode the request
        let decodedRequest = try request.decodeBody(RequestPayload.self)
        #expect(decodedRequest == requestPayload)

        // Process and create response
        let responsePayload = ResponsePayload(
            processedMessage: decodedRequest.message.uppercased(),
            doubledCount: decodedRequest.count * 2
        )

        // Encode the response
        let response = APIGatewayV2Response.encoding(responsePayload, status: .ok)

        #expect(response.statusCode == .ok)
        #expect(response.body != nil)

        // Verify the response content
        let responseBodyData = try #require(response.body?.data(using: .utf8))
        let decodedResponse = try JSONDecoder().decode(ResponsePayload.self, from: responseBodyData)
        #expect(decodedResponse.processedMessage == "PROCESS ME")
        #expect(decodedResponse.doubledCount == 42)
    }
}
