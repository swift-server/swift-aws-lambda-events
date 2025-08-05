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

struct APIGatewayEncodableResponseTests {

    // MARK: Encoding
    struct BusinessResponse: Codable, Equatable {
        let message: String
        let code: Int
    }

    @Test
    func testResponseEncodingV2() throws {

        // given
        let businessResponse = BusinessResponse(message: "Hello World", code: 200)

        var response: APIGatewayV2Response? = nil
        #expect(throws: Never.self) {
            try response = APIGatewayV2Response(statusCode: .ok, encodableBody: businessResponse)
        }

        // when
        let body = try #require(response?.body?.data(using: .utf8))

        #expect(throws: Never.self) {
            let encodedBody = try JSONDecoder().decode(BusinessResponse.self, from: body)

            // then
            #expect(encodedBody == businessResponse)
        }
    }

    @Test
    func testResponseEncoding() throws {

        // given
        let businessResponse = BusinessResponse(message: "Hello World", code: 200)

        var response: APIGatewayResponse? = nil
        #expect(throws: Never.self) {
            try response = APIGatewayResponse(statusCode: .ok, encodableBody: businessResponse)
        }
        try #require(response?.body != nil)

        // when
        let body = response?.body?.data(using: .utf8)

        #expect(throws: Never.self) {
            let encodedBody = try JSONDecoder().decode(BusinessResponse.self, from: body!)

            // then
            #expect(encodedBody == businessResponse)
        }
    }

    // MARK: APIGatewayV2 Encoding Helper Tests

    @Test
    func testAPIGatewayV2ResponseEncodingHelper() throws {
        // given
        let businessResponse = BusinessResponse(message: "Hello World", code: 200)

        // when
        let response = APIGatewayV2Response.encoding(businessResponse)

        // then
        #expect(response.statusCode == .ok)
        #expect(response.body != nil)
        
        let bodyData = try #require(response.body?.data(using: .utf8))
        let decodedResponse = try JSONDecoder().decode(BusinessResponse.self, from: bodyData)
        #expect(decodedResponse == businessResponse)
    }

    @Test
    func testAPIGatewayV2ResponseEncodingHelperWithCustomStatus() throws {
        // given
        let businessResponse = BusinessResponse(message: "Created", code: 201)

        // when
        let response = APIGatewayV2Response.encoding(businessResponse, status: .created)

        // then
        #expect(response.statusCode == .created)
        #expect(response.body != nil)
        
        let bodyData = try #require(response.body?.data(using: .utf8))
        let decodedResponse = try JSONDecoder().decode(BusinessResponse.self, from: bodyData)
        #expect(decodedResponse == businessResponse)
    }

    @Test
    func testAPIGatewayV2ResponseEncodingHelperWithCustomEncoder() throws {
        // given
        let businessResponse = BusinessResponse(message: "Hello World", code: 200)
        let customEncoder = JSONEncoder()
        customEncoder.outputFormatting = .prettyPrinted

        // when
        let response = APIGatewayV2Response.encoding(businessResponse, using: customEncoder)

        // then
        #expect(response.statusCode == .ok)
        #expect(response.body != nil)
        #expect(response.body?.contains("\n") == true) // Pretty printed JSON should contain newlines
        
        let bodyData = try #require(response.body?.data(using: .utf8))
        let decodedResponse = try JSONDecoder().decode(BusinessResponse.self, from: bodyData)
        #expect(decodedResponse == businessResponse)
    }

    @Test
    func testAPIGatewayV2ResponseEncodingHelperWithError() throws {
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
        let response = APIGatewayV2Response.encoding(invalidObject)

        // then
        #expect(response.statusCode == .internalServerError)
        #expect(response.body?.contains("Internal Server Error") == true)
    }

    @Test
    func testAPIGatewayV2ResponseEncodingHelperWithCustomErrorHandler() throws {
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
        let customErrorHandler: (Error) -> APIGatewayV2Response = { _ in
            APIGatewayV2Response(statusCode: .badRequest, body: "Custom error message")
        }

        // when
        let response = APIGatewayV2Response.encoding(invalidObject, onError: customErrorHandler)

        // then
        #expect(response.statusCode == .badRequest)
        #expect(response.body == "Custom error message")
    }

}
