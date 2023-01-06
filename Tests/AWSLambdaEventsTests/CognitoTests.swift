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

final class CognitoTests: XCTestCase {
    func testPreSignUpRequest() throws {
        let json = """
{
 "version": "1",
 "triggerSource": "PreSignUp_SignUp",
 "region": "us-east-1",
 "userPoolId": "abc",
 "userName": "blob",
 "callerContext": {
  "awsSdkVersion": "1",
  "clientId": "abc",
 },
 "request": {
  "userAttributes": {
   "string": "string"
  },
  "validationData": {
   "string": "string"
   },
  "clientMetadata": {
   "string": "string"
   }
 },

 "response": {}
}
"""
        let event = try JSONDecoder().decode(CognitoEvent.self, from: json.data(using: .utf8)!)

        guard case .preSignUpSignUp(let params, let request) = event else {
            XCTFail()
            return
        }

        XCTAssertEqual(params.triggerSource, "PreSignUp_SignUp")

        let signUp = CognitoEvent.PreSignUp(userAttributes: ["string": "string"],
                                            validationData: ["string": "string"],
                                            clientMetadata: ["string": "string"])
        XCTAssertEqual(request, signUp)
    }

    func testPreSignUpResponse() throws {
        let params = CognitoEvent.Parameters(version: "1",
                                             triggerSource: "PreSignUp_SignUp",
                                             region: .us_east_1,
                                             userPoolId: "abc",
                                             userName: "blob",
                                             callerContext: .init(awsSdkVersion: "1", clientId: "abc"))
        let request = CognitoEvent.PreSignUp(userAttributes: ["string": "string"],
                                             validationData: ["string": "string"],
                                             clientMetadata: ["string": "string"])

        let signUpResponse = CognitoEventResponse.PreSignUp(autoConfirmUser: true,
                                                            autoVerifyPhone: true,
                                                            autoVerifyEmail: true)

        let response = CognitoEventResponse.preSignUpSignUp(params, request, signUpResponse)

        let data = try JSONEncoder().encode(response)

        let decodedResponse = try JSONDecoder().decode(CognitoEventResponse.self, from: data)

        guard case .preSignUpSignUp(let decodedParams, let decodedRequest, let decodedResponse) = decodedResponse else {
            XCTFail()
            return
        }

        XCTAssertEqual(decodedParams, params)
        XCTAssertEqual(decodedRequest, request)
        XCTAssertEqual(decodedResponse, signUpResponse)
    }

}
