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
        try #require(response?.body != nil)

        // when
        let body = response?.body?.data(using: .utf8)
        try #require(body != nil)

        #expect(throws: Never.self) {
            let encodedBody = try JSONDecoder().decode(BusinessResponse.self, from: body!)

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
        try #require(body != nil)

        #expect(throws: Never.self) {
            let encodedBody = try JSONDecoder().decode(BusinessResponse.self, from: body!)

            // then
            #expect(encodedBody == businessResponse)
        }
    }
}
