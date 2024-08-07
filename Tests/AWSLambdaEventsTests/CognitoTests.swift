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

        guard case .preSignUp(let params, let request) = event else {
            XCTFail()
            return
        }

        XCTAssertEqual(params.triggerSource, .preSignUp_SignUp)

        let signUp = CognitoEvent.PreSignUp(userAttributes: ["string": "string"],
                                            validationData: ["string": "string"],
                                            clientMetadata: ["string": "string"])
        XCTAssertEqual(request, signUp)
    }

    func testPreSignUpResponse() throws {
        let params = CognitoEvent.Parameters(version: "1",
                                             triggerSource: .preSignUp_SignUp,
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

        let response = CognitoEventResponse.preSignUp(params, request, signUpResponse)

        let data = try JSONEncoder().encode(response)

        let decodedResponse = try JSONDecoder().decode(CognitoEventResponse.self, from: data)

        guard case .preSignUp(let decodedParams, let decodedRequest, let decodedResponse) = decodedResponse else {
            XCTFail()
            return
        }

        XCTAssertEqual(decodedParams, params)
        XCTAssertEqual(decodedRequest, request)
        XCTAssertEqual(decodedResponse, signUpResponse)
    }

    func testPostConfirmationRequest() throws {
        let json = """
        {
         "version": "1",
         "triggerSource": "PostConfirmation_ConfirmSignUp",
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
          "clientMetadata": {
           "string": "string"
          }
         },
         "response": {}
        }
        """
        let event = try JSONDecoder().decode(CognitoEvent.self, from: json.data(using: .utf8)!)

        guard case .postConfirmation(let params, let request) = event else {
            XCTFail()
            return
        }

        XCTAssertEqual(params.triggerSource, .postConfirmation_ConfirmSignUp)

        let postConfirmation = CognitoEvent.PostConfirmation(userAttributes: ["string": "string"],
                                                             clientMetadata: ["string": "string"])
        XCTAssertEqual(request, postConfirmation)
    }

    func testPostConfirmationResponse() throws {
        let params = CognitoEvent.Parameters(version: "1",
                                             triggerSource: .postConfirmation_ConfirmSignUp,
                                             region: .us_east_1,
                                             userPoolId: "abc",
                                             userName: "blob",
                                             callerContext: .init(awsSdkVersion: "1", clientId: "abc"))
        let request = CognitoEvent.PostConfirmation(userAttributes: ["string": "string"],
                                                    clientMetadata: ["string": "string"])

        let postConfirmationResponse = CognitoEventResponse.EmptyResponse()

        let response = CognitoEventResponse.postConfirmation(params, request, postConfirmationResponse)

        let data = try JSONEncoder().encode(response)

        let decodedResponse = try JSONDecoder().decode(CognitoEventResponse.self, from: data)

        guard case .postConfirmation(let decodedParams, let decodedRequest, let decodedResponse) = decodedResponse else {
            XCTFail()
            return
        }

        XCTAssertEqual(decodedParams, params)
        XCTAssertEqual(decodedRequest, request)
        XCTAssertEqual(decodedResponse, postConfirmationResponse)
    }

    func testPostAuthenticationRequest() throws {
        let json = """
        {
         "version": "1",
         "triggerSource": "PostAuthentication_Authentication",
         "region": "us-east-1",
         "userPoolId": "abc",
         "userName": "blob",
         "callerContext": {
          "awsSdkVersion": "1",
          "clientId": "abc",
         },
         "request": {
          "newDeviceUsed": false,
          "userAttributes": {
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

        guard case .postAuthentication(let params, let request) = event else {
            XCTFail()
            return
        }

        XCTAssertEqual(params.triggerSource, .postAuthentication_Authentication)

        let postAuthentication = CognitoEvent.PostAuthentication(newDeviceUsed: false,
                                                                 userAttributes: ["string": "string"],
                                                                 clientMetadata: ["string": "string"])
        XCTAssertEqual(request, postAuthentication)
    }

    func testPostAuthenticationResponse() throws {
        let params = CognitoEvent.Parameters(version: "1",
                                             triggerSource: .postAuthentication_Authentication,
                                             region: .us_east_1,
                                             userPoolId: "abc",
                                             userName: "blob",
                                             callerContext: .init(awsSdkVersion: "1", clientId: "abc"))
        let request = CognitoEvent.PostAuthentication(newDeviceUsed: false,
                                                      userAttributes: ["string": "string"],
                                                      clientMetadata: ["string": "string"])

        let postAuthenticationResponse = CognitoEventResponse.EmptyResponse()

        let response = CognitoEventResponse.postAuthentication(params, request, postAuthenticationResponse)

        let data = try JSONEncoder().encode(response)

        let decodedResponse = try JSONDecoder().decode(CognitoEventResponse.self, from: data)

        guard case .postAuthentication(let decodedParams, let decodedRequest, let decodedResponse) = decodedResponse else {
            XCTFail()
            return
        }

        XCTAssertEqual(decodedParams, params)
        XCTAssertEqual(decodedRequest, request)
        XCTAssertEqual(decodedResponse, postAuthenticationResponse)
    }

    func testCustomMessageRequest() throws {
        let json = """
        {
         "version": "1",
         "triggerSource": "CustomMessage_AdminCreateUser",
         "region": "us-east-1",
         "userPoolId": "abc",
         "userName": "blob",
         "callerContext": {
          "awsSdkVersion": "1",
          "clientId": "abc",
         },
         "request": {
          "codeParameter": "######",
          "usernameParameter": "user123",
          "userAttributes": {
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

        guard case .customMessage(let params, let request) = event else {
            XCTFail()
            return
        }

        XCTAssertEqual(params.triggerSource, .customMessage_AdminCreateUser)

        let postAuthentication = CognitoEvent.CustomMessage(codeParameter: "######",
                                                            usernameParameter: "user123",
                                                            userAttributes: ["string": "string"],
                                                            clientMetadata: ["string": "string"])
        XCTAssertEqual(request, postAuthentication)
    }

    func testCustomMessageResponse() throws {
        let params = CognitoEvent.Parameters(version: "1",
                                             triggerSource: .customMessage_AdminCreateUser,
                                             region: .us_east_1,
                                             userPoolId: "abc",
                                             userName: "blob",
                                             callerContext: .init(awsSdkVersion: "1", clientId: "abc"))
        let request = CognitoEvent.CustomMessage(codeParameter: "######",
                                                 usernameParameter: "user123",
                                                 userAttributes: ["string": "string"],
                                                 clientMetadata: ["string": "string"])

        let customMessageResponse = CognitoEventResponse.CustomMessage(smsMessage: nil, emailMessage: "<html><body>Your code is ######</body></html>", emailSubject: "Sign up code")

        let response = CognitoEventResponse.customMessage(params, request, customMessageResponse)

        let data = try JSONEncoder().encode(response)

        let decodedResponse = try JSONDecoder().decode(CognitoEventResponse.self, from: data)

        guard case .customMessage(let decodedParams, let decodedRequest, let decodedResponse) = decodedResponse else {
            XCTFail()
            return
        }

        XCTAssertEqual(decodedParams, params)
        XCTAssertEqual(decodedRequest, request)
        XCTAssertEqual(decodedResponse, customMessageResponse)
    }
}
