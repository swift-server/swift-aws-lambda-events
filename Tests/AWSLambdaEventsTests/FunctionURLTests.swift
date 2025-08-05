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
struct FunctionURLTests {
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

    @Test func requestDecodingDocumentationExampleRequest() throws {
        let data = Self.documentationExample.data(using: .utf8)!
        let req = try JSONDecoder().decode(FunctionURLRequest.self, from: data)

        #expect(req.rawPath == "/my/path")
        #expect(req.requestContext.http.method == .post)
        #expect(req.queryStringParameters?.count == 2)
        #expect(req.rawQueryString == "parameter1=value1&parameter1=value2&parameter2=value")
        #expect(req.headers.count == 2)
        #expect(req.body == "Hello from client!")
    }

    @Test func requestDecodingRealWorldExampleRequest() throws {
        let data = Self.realWorldExample.data(using: .utf8)!
        let req = try JSONDecoder().decode(FunctionURLRequest.self, from: data)

        #expect(req.rawPath == "/")
        #expect(req.requestContext.http.method == .get)
        #expect(req.queryStringParameters?.count == 1)
        #expect(req.rawQueryString == "test=2")
        #expect(req.headers.count == 10)
        #expect(req.cookies == ["test"])
        #expect(req.body == nil)
    }

    // MARK: Codable Helpers Tests

    @Test func decodeBodyWithNilBody() throws {
        let data = Self.realWorldExample.data(using: .utf8)!
        let request = try JSONDecoder().decode(FunctionURLRequest.self, from: data)
        
        let decodedBody = try request.decodeBody()
        #expect(decodedBody == nil)
    }

    @Test func decodeBodyWithPlainTextBody() throws {
        let data = Self.documentationExample.data(using: .utf8)!
        let request = try JSONDecoder().decode(FunctionURLRequest.self, from: data)
        
        let decodedBody = try request.decodeBody()
        let expectedBody = "Hello from client!".data(using: .utf8)
        #expect(decodedBody == expectedBody)
    }

    @Test func decodeBodyWithBase64EncodedBody() throws {
        let requestWithBase64Body = """
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
                    "method": "POST",
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
            "body": "SGVsbG8gZnJvbSBjbGllbnQh",
            "isBase64Encoded": true
        }
        """
        
        let data = requestWithBase64Body.data(using: .utf8)!
        let request = try JSONDecoder().decode(FunctionURLRequest.self, from: data)
        
        let decodedBody = try request.decodeBody()
        let expectedBody = "Hello from client!".data(using: .utf8)
        #expect(decodedBody == expectedBody)
    }

    @Test func decodeBodyAsDecodableType() throws {
        // Use the documentationExample which already has a simple string body
        let data = Self.documentationExample.data(using: .utf8)!
        let request = try JSONDecoder().decode(FunctionURLRequest.self, from: data)
        
        // Test that we can decode the body as String
        // The documentationExample has body: "Hello from client!" which is not valid JSON, so this should fail
        #expect(throws: DecodingError.self) {
            _ = try request.decodeBody(String.self)
        }
    }

    @Test func decodeBodyAsDecodableTypeWithBase64() throws {
        struct TestPayload: Codable, Equatable {
            let message: String
            let count: Int
        }
        
        let testPayload = TestPayload(message: "test", count: 42)
        
        let requestWithBase64JSONBody = """
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
                    "method": "POST",
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
            "body": "eyJtZXNzYWdlIjoidGVzdCIsImNvdW50Ijo0Mn0=",
            "isBase64Encoded": true
        }
        """
        
        let data = requestWithBase64JSONBody.data(using: .utf8)!
        let request = try JSONDecoder().decode(FunctionURLRequest.self, from: data)
        
        let decodedPayload = try request.decodeBody(TestPayload.self)
        #expect(decodedPayload == testPayload)
    }

    // MARK: FunctionURL Encoding Helper Tests

    @Test
    func testFunctionURLResponseEncodingHelper() throws {
        struct BusinessResponse: Codable, Equatable {
            let message: String
            let code: Int
        }
        
        // given
        let businessResponse = BusinessResponse(message: "Hello World", code: 200)

        // when
        let response = FunctionURLResponse.encoding(businessResponse)

        // then
        #expect(response.statusCode == .ok)
        #expect(response.body != nil)
        
        let bodyData = try #require(response.body?.data(using: .utf8))
        let decodedResponse = try JSONDecoder().decode(BusinessResponse.self, from: bodyData)
        #expect(decodedResponse == businessResponse)
    }

    @Test
    func testFunctionURLResponseEncodingHelperWithCustomStatus() throws {
        struct BusinessResponse: Codable, Equatable {
            let message: String
            let code: Int
        }
        
        // given
        let businessResponse = BusinessResponse(message: "Created", code: 201)

        // when
        let response = FunctionURLResponse.encoding(businessResponse, status: .created)

        // then
        #expect(response.statusCode == .created)
        #expect(response.body != nil)
        
        let bodyData = try #require(response.body?.data(using: .utf8))
        let decodedResponse = try JSONDecoder().decode(BusinessResponse.self, from: bodyData)
        #expect(decodedResponse == businessResponse)
    }

    @Test
    func testFunctionURLResponseEncodingHelperWithCustomEncoder() throws {
        struct BusinessResponse: Codable, Equatable {
            let message: String
            let code: Int
        }
        
        // given
        let businessResponse = BusinessResponse(message: "Hello World", code: 200)
        let customEncoder = JSONEncoder()
        customEncoder.outputFormatting = .prettyPrinted

        // when
        let response = FunctionURLResponse.encoding(businessResponse, using: customEncoder)

        // then
        #expect(response.statusCode == .ok)
        #expect(response.body != nil)
        #expect(response.body?.contains("\n") == true) // Pretty printed JSON should contain newlines
        
        let bodyData = try #require(response.body?.data(using: .utf8))
        let decodedResponse = try JSONDecoder().decode(BusinessResponse.self, from: bodyData)
        #expect(decodedResponse == businessResponse)
    }

    @Test
    func testFunctionURLResponseEncodingHelperWithError() throws {
        // given
        struct InvalidEncodable: Encodable {
            func encode(to encoder: Encoder) throws {
                throw TestError.encodingFailed
            }
        }
        
        enum TestError: Error {
            case encodingFailed
        }

        let invalidObject = InvalidEncodable()

        // when
        let response = FunctionURLResponse.encoding(invalidObject)

        // then
        #expect(response.statusCode == .internalServerError)
        #expect(response.body?.contains("Internal Server Error") == true)
    }

    @Test
    func testFunctionURLResponseEncodingHelperWithCustomErrorHandler() throws {
        // given
        struct InvalidEncodable: Encodable {
            func encode(to encoder: Encoder) throws {
                throw TestError.encodingFailed
            }
        }
        
        enum TestError: Error {
            case encodingFailed
        }

        let invalidObject = InvalidEncodable()
        let customErrorHandler: (Error) -> FunctionURLResponse = { _ in
            FunctionURLResponse(statusCode: .badRequest, body: "Custom error message")
        }

        // when
        let response = FunctionURLResponse.encoding(invalidObject, onError: customErrorHandler)

        // then
        #expect(response.statusCode == .badRequest)
        #expect(response.body == "Custom error message")
    }
}
