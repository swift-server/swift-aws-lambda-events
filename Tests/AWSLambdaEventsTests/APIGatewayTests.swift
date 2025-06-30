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
struct APIGatewayTests {
    static let exampleGetEventBody = """
          {"httpMethod": "GET", "body": null, "resource": "/test", "requestContext": {"resourceId": "123456", "apiId": "1234567890", "domainName": "1234567890.execute-api.us-east-1.amazonaws.com", "resourcePath": "/test", "httpMethod": "GET", "requestId": "c6af9ac6-7b61-11e6-9a41-93e8deadbeef", "accountId": "123456789012", "stage": "Prod", "identity": {"apiKey": null, "userArn": null, "cognitoAuthenticationType": null, "caller": null, "userAgent": "Custom User Agent String", "user": null, "cognitoIdentityPoolId": null, "cognitoAuthenticationProvider": null, "sourceIp": "127.0.0.1", "accountId": null}, "extendedRequestId": null, "path": "/test"}, "queryStringParameters": null, "multiValueQueryStringParameters": null, "headers": {"Host": "127.0.0.1:3000", "Connection": "keep-alive", "Cache-Control": "max-age=0", "Dnt": "1", "Upgrade-Insecure-Requests": "1", "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36 Edg/78.0.276.24", "Sec-Fetch-User": "?1", "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3", "Sec-Fetch-Site": "none", "Sec-Fetch-Mode": "navigate", "Accept-Encoding": "gzip, deflate, br", "Accept-Language": "en-US,en;q=0.9", "X-Forwarded-Proto": "http", "X-Forwarded-Port": "3000"}, "multiValueHeaders": {"Host": ["127.0.0.1:3000"], "Connection": ["keep-alive"], "Cache-Control": ["max-age=0"], "Dnt": ["1"], "Upgrade-Insecure-Requests": ["1"], "User-Agent": ["Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36 Edg/78.0.276.24"], "Sec-Fetch-User": ["?1"], "Accept": ["text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3"], "Sec-Fetch-Site": ["none"], "Sec-Fetch-Mode": ["navigate"], "Accept-Encoding": ["gzip, deflate, br"], "Accept-Language": ["en-US,en;q=0.9"], "X-Forwarded-Proto": ["http"], "X-Forwarded-Port": ["3000"]}, "pathParameters": null, "stageVariables": null, "path": "/test", "isBase64Encoded": false}
        """
    // This event is here to preserve backwards compatibility for events without the `domainName` field, see [discussion in #24](https://github.com/swift-server/swift-aws-lambda-events/pull/24#discussion_r969038350).
    static let exampleGetEventBodyWithoutDomainName = """
          {"httpMethod": "GET", "body": null, "resource": "/test", "requestContext": {"resourceId": "123456", "apiId": "1234567890", "resourcePath": "/test", "httpMethod": "GET", "requestId": "c6af9ac6-7b61-11e6-9a41-93e8deadbeef", "accountId": "123456789012", "stage": "Prod", "identity": {"apiKey": null, "userArn": null, "cognitoAuthenticationType": null, "caller": null, "userAgent": "Custom User Agent String", "user": null, "cognitoIdentityPoolId": null, "cognitoAuthenticationProvider": null, "sourceIp": "127.0.0.1", "accountId": null}, "extendedRequestId": null, "path": "/test"}, "queryStringParameters": null, "multiValueQueryStringParameters": null, "headers": {"Host": "127.0.0.1:3000", "Connection": "keep-alive", "Cache-Control": "max-age=0", "Dnt": "1", "Upgrade-Insecure-Requests": "1", "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36 Edg/78.0.276.24", "Sec-Fetch-User": "?1", "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3", "Sec-Fetch-Site": "none", "Sec-Fetch-Mode": "navigate", "Accept-Encoding": "gzip, deflate, br", "Accept-Language": "en-US,en;q=0.9", "X-Forwarded-Proto": "http", "X-Forwarded-Port": "3000"}, "multiValueHeaders": {"Host": ["127.0.0.1:3000"], "Connection": ["keep-alive"], "Cache-Control": ["max-age=0"], "Dnt": ["1"], "Upgrade-Insecure-Requests": ["1"], "User-Agent": ["Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36 Edg/78.0.276.24"], "Sec-Fetch-User": ["?1"], "Accept": ["text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3"], "Sec-Fetch-Site": ["none"], "Sec-Fetch-Mode": ["navigate"], "Accept-Encoding": ["gzip, deflate, br"], "Accept-Language": ["en-US,en;q=0.9"], "X-Forwarded-Proto": ["http"], "X-Forwarded-Port": ["3000"]}, "pathParameters": null, "stageVariables": null, "path": "/test", "isBase64Encoded": false}
        """

    // This event contains an authorizer which would be attached if a resource/method combo uses Cognito for authentication/authorization of API clients.
    static let exampleGetEventBodyWithAuthorizer = """
          {"httpMethod": "GET", "body": null, "resource": "/test", "requestContext": {"resourceId": "123456", "apiId": "1234567890", "domainName": "1234567890.execute-api.us-east-1.amazonaws.com", "resourcePath": "/test", "httpMethod": "GET", "requestId": "c6af9ac6-7b61-11e6-9a41-93e8deadbeef", "accountId": "123456789012", "stage": "Prod", "identity": {"apiKey": null, "userArn": null, "cognitoAuthenticationType": null, "caller": null, "userAgent": "Custom User Agent String", "user": null, "cognitoIdentityPoolId": null, "cognitoAuthenticationProvider": null, "sourceIp": "127.0.0.1", "accountId": null}, "authorizer" : {"claims": {"sub": "2592124a-27bf-4e30-b95f-2f21c862fc82", "event_id": "fbf7193a-e3b4-462b-95b4-4df60a9fe410", "token_use": "access", "scope": "aws.cognito.signin.user.admin phone openid profile email", "auth_time": "1683085806", "iss": "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_pxAHZcSSX", "exp": "Thu May 04 03:50:06 UTC 2023", "version": "2", "iat": "Wed May 03 03:50:06 UTC 2023", "client_id": "6rupb256qn12tju82occ9eppqr", "jti": "5d92ca29-677e-40d9-a074-2d86fbcb4023", "username": "richwolf"}}, "extendedRequestId": null, "path": "/test"}, "queryStringParameters": null, "multiValueQueryStringParameters": null, "headers": {"Host": "127.0.0.1:3000", "Connection": "keep-alive", "Cache-Control": "max-age=0", "Dnt": "1", "Upgrade-Insecure-Requests": "1", "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36 Edg/78.0.276.24", "Sec-Fetch-User": "?1", "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3", "Sec-Fetch-Site": "none", "Sec-Fetch-Mode": "navigate", "Accept-Encoding": "gzip, deflate, br", "Accept-Language": "en-US,en;q=0.9", "X-Forwarded-Proto": "http", "X-Forwarded-Port": "3000"}, "multiValueHeaders": {"Host": ["127.0.0.1:3000"], "Connection": ["keep-alive"], "Cache-Control": ["max-age=0"], "Dnt": ["1"], "Upgrade-Insecure-Requests": ["1"], "User-Agent": ["Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36 Edg/78.0.276.24"], "Sec-Fetch-User": ["?1"], "Accept": ["text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3"], "Sec-Fetch-Site": ["none"], "Sec-Fetch-Mode": ["navigate"], "Accept-Encoding": ["gzip, deflate, br"], "Accept-Language": ["en-US,en;q=0.9"], "X-Forwarded-Proto": ["http"], "X-Forwarded-Port": ["3000"]}, "pathParameters": null, "stageVariables": null, "path": "/test", "isBase64Encoded": false}
        """

    static let todoPostEventBody = """
          {"httpMethod": "POST", "body": "{\\"title\\":\\"a todo\\"}", "resource": "/todos", "requestContext": {"resourceId": "123456", "apiId": "1234567890", "domainName": "1234567890.execute-api.us-east-1.amazonaws.com", "resourcePath": "/todos", "httpMethod": "POST", "requestId": "c6af9ac6-7b61-11e6-9a41-93e8deadbeef", "accountId": "123456789012", "stage": "test", "identity": {"apiKey": null, "userArn": null, "cognitoAuthenticationType": null, "caller": null, "userAgent": "Custom User Agent String", "user": null, "cognitoIdentityPoolId": null, "cognitoAuthenticationProvider": null, "sourceIp": "127.0.0.1", "accountId": null}, "extendedRequestId": null, "path": "/todos"}, "queryStringParameters": null, "multiValueQueryStringParameters": null, "headers": {"Host": "127.0.0.1:3000", "Connection": "keep-alive", "Content-Length": "18", "Pragma": "no-cache", "Cache-Control": "no-cache", "Accept": "text/plain, */*; q=0.01", "Origin": "http://todobackend.com", "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.36 Safari/537.36 Edg/79.0.309.25", "Dnt": "1", "Content-Type": "application/json", "Sec-Fetch-Site": "cross-site", "Sec-Fetch-Mode": "cors", "Referer": "http://todobackend.com/specs/index.html?http://127.0.0.1:3000/todos", "Accept-Encoding": "gzip, deflate, br", "Accept-Language": "en-US,en;q=0.9", "X-Forwarded-Proto": "http", "X-Forwarded-Port": "3000"}, "multiValueHeaders": {"Host": ["127.0.0.1:3000"], "Connection": ["keep-alive"], "Content-Length": ["18"], "Pragma": ["no-cache"], "Cache-Control": ["no-cache"], "Accept": ["text/plain, */*; q=0.01"], "Origin": ["http://todobackend.com"], "User-Agent": ["Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.36 Safari/537.36 Edg/79.0.309.25"], "Dnt": ["1"], "Content-Type": ["application/json"], "Sec-Fetch-Site": ["cross-site"], "Sec-Fetch-Mode": ["cors"], "Referer": ["http://todobackend.com/specs/index.html?http://127.0.0.1:3000/todos"], "Accept-Encoding": ["gzip, deflate, br"], "Accept-Language": ["en-US,en;q=0.9"], "X-Forwarded-Proto": ["http"], "X-Forwarded-Port": ["3000"]}, "pathParameters": null, "stageVariables": null, "path": "/todos", "isBase64Encoded": false}
        """

    static let postEventBodyNilHeaders = """
          {"httpMethod": "POST", "body": "{\\"title\\":\\"a todo\\"}", "resource":"/todos", "requestContext": {"resourceId": "123456", "apiId": "1234567890", "domainName": "1234567890.execute-api.us-east-1.amazonaws.com", "resourcePath": "/todos", "httpMethod": "POST", "requestId": "c6af9ac6-7b61-11e6-9a41-93e8deadbeef", "accountId": "123456789012", "stage": "test", "identity": {"apiKey": null, "userArn": null,"cognitoAuthenticationType": null, "caller": null, "userAgent": "Custom User Agent String", "user": null, "cognitoIdentityPoolId": null, "cognitoAuthenticationProvider": null, "sourceIp": "127.0.0.1", "accountId": null}, "extendedRequestId": null, "path": "/todos"}, "multiValueHeaders": {"Host": ["127.0.0.1:3000"], "Connection": ["keep-alive"], "Content-Length": ["18"], "Pragma": ["no-cache"], "Cache-Control": ["no-cache"], "Accept": ["text/plain, */*; q=0.01"], "Origin": ["http://todobackend.com"], "User-Agent": ["Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.36 Safari/537.36 Edg/79.0.309.25"], "Dnt": ["1"], "Content-Type": ["application/json"], "Sec-Fetch-Site": ["cross-site"], "Sec-Fetch-Mode": ["cors"], "Referer": ["http://todobackend.com/specs/index.html?http://127.0.0.1:3000/todos"], "Accept-Encoding": ["gzip, deflate, br"], "Accept-Language": ["en-US,en;q=0.9"], "X-Forwarded-Proto": ["http"], "X-Forwarded-Port": ["3000"]}, "path": "/todos", "isBase64Encoded": false}
        """

    // MARK: - Request -

    // MARK: Decoding

    @Test func requestDecodingExampleGetRequest() throws {
        let data = APIGatewayTests.exampleGetEventBody.data(using: .utf8)!
        let req = try JSONDecoder().decode(APIGatewayRequest.self, from: data)

        #expect(req.path == "/test")
        #expect(req.httpMethod == .get)
    }

    @Test func requestDecodingExampleGetRequestWithoutDomainName() throws {
        let data = APIGatewayTests.exampleGetEventBodyWithoutDomainName.data(using: .utf8)!
        let req = try JSONDecoder().decode(APIGatewayRequest.self, from: data)

        #expect(req.path == "/test")
        #expect(req.httpMethod == .get)
        #expect(req.requestContext.domainName == nil)
    }

    @Test func requestDecodingExampleGetRequestWithAuthorizer() throws {
        let data = APIGatewayTests.exampleGetEventBodyWithAuthorizer.data(using: .utf8)!
        let req = try JSONDecoder().decode(APIGatewayRequest.self, from: data)

        #expect(req.path == "/test")
        #expect(req.httpMethod == .get)
        #expect(
            req.requestContext.authorizer?.claims?["scope"]
                == "aws.cognito.signin.user.admin phone openid profile email"
        )
        #expect(req.requestContext.authorizer?.claims?["username"] == "richwolf")
    }

    @Test func requestDecodingTodoPostRequest() throws {
        let data = APIGatewayTests.todoPostEventBody.data(using: .utf8)!
        let req = try JSONDecoder().decode(APIGatewayRequest.self, from: data)

        #expect(req.path == "/todos")
        #expect(req.httpMethod == .post)
    }

    // MARK: - Response -

    // MARK: Encoding

    struct JSONResponse: Codable {
        let statusCode: Int
        let headers: [String: String]?
        let body: String?
        let isBase64Encoded: Bool?
    }

    @Test func responseEncoding() throws {
        let resp = APIGatewayResponse(
            statusCode: .ok,
            headers: ["Server": "Test"],
            body: "abc123"
        )

        let data = try #require(try? JSONEncoder().encode(resp))
        let json = try JSONDecoder().decode(JSONResponse.self, from: data)

        #expect(json.statusCode == resp.statusCode.code)
        #expect(json.body == resp.body)
        #expect(json.isBase64Encoded == resp.isBase64Encoded)
        #expect(json.headers?["Server"] == "Test")
    }

    @Test func decodingNilCollections() {
        let data = APIGatewayTests.postEventBodyNilHeaders.data(using: .utf8)!
        #expect(throws: Never.self) { try JSONDecoder().decode(APIGatewayRequest.self, from: data) }
    }
}
