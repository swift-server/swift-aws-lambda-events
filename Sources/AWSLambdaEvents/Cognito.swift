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

enum CognitoEventError: Error {
    case unimplementedEvent(String)
}

/// https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools-working-with-aws-lambda-triggers.html
public enum CognitoEvent: Equatable {
    public struct CallerContext: Codable, Hashable {
        let awsSdkVersion: String
        let clientId: String
    }

    public struct Parameters: Codable, Equatable {
        let version: String
        let triggerSource: String
        let region: AWSRegion
        let userPoolId: String
        let userName: String
        let callerContext: CallerContext
    }

    case preSignUpSignUp(Parameters, PreSignUp)

    public struct PreSignUp: Codable, Hashable {
        /// One or more name-value pairs representing user attributes. The attribute names are the keys.
        public let userAttributes: [String: String]
        /// One or more name-value pairs containing the validation data in the request to register a user.
        ///
        /// The validation data is set and then passed from the client in the request to register a user. You can pass this data to your Lambda function by using the ClientMetadata parameter in the InitiateAuth and AdminInitiateAuth API actions.
        public let validationData: [String: String]?
        /// One or more key-value pairs that you can provide as custom input to the Lambda function that you specify for the pre sign-up trigger.
        ///
        /// You can pass this data to your Lambda function by using the ClientMetadata parameter in the following API actions: AdminCreateUser, AdminRespondToAuthChallenge, ForgotPassword, and SignUp.
        public let clientMetadata: [String: String]?
    }

    public var commonParameters: Parameters {
        switch self {
        case .preSignUpSignUp(let params, _):
            return params
        }
    }
}

extension CognitoEvent: Codable {
    public enum CodingKeys: String, CodingKey {
        case version
        case triggerSource
        case region
        case userPoolId
        case userName
        case callerContext
        case request
        case response
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let version = try container.decode(String.self, forKey: .version)
        let triggerSource = try container.decode(String.self, forKey: .triggerSource)
        let region = try container.decode(AWSRegion.self, forKey: .region)
        let userPoolId = try container.decode(String.self, forKey: .userPoolId)
        let userName = try container.decode(String.self, forKey: .userName)
        let callerContext = try container.decode(CallerContext.self, forKey: .callerContext)

        let params = CognitoEvent.Parameters(version: version, triggerSource: triggerSource, region: region, userPoolId: userPoolId, userName: userName, callerContext: callerContext)

        switch triggerSource {
        case "PreSignUp_SignUp":
            let value = try container.decode(CognitoEvent.PreSignUp.self, forKey: .request)

            self = .preSignUpSignUp(params, value)
        default:
            throw CognitoEventError.unimplementedEvent(triggerSource)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let params = self.commonParameters

        try container.encode(params.version, forKey: .version)
        try container.encode(params.triggerSource, forKey: .triggerSource)
        try container.encode(params.region, forKey: .region)
        try container.encode(params.userPoolId, forKey: .userPoolId)
        try container.encode(params.userName, forKey: .userName)
        try container.encode(params.callerContext, forKey: .callerContext)

        switch self {
        case .preSignUpSignUp(_, let value):
            try container.encode(value, forKey: .response)
        }
    }
}

public enum CognitoEventResponse {
    case preSignUpSignUp(CognitoEvent.Parameters, CognitoEvent.PreSignUp, PreSignUp)

    public struct PreSignUp: Codable, Hashable {
        public let autoConfirmUser: Bool
        public let autoVerifyPhone: Bool
        public let autoVerifyEmail: Bool

        public init(autoConfirmUser: Bool, autoVerifyPhone: Bool, autoVerifyEmail: Bool) {
            self.autoConfirmUser = autoConfirmUser
            self.autoVerifyPhone = autoVerifyPhone
            self.autoVerifyEmail = autoVerifyEmail
        }
    }

    public var commonParameters: CognitoEvent.Parameters {
        switch self {
        case .preSignUpSignUp(let params, _, _):
            return params
        }
    }
}

extension CognitoEventResponse: Codable {
    public enum CodingKeys: String, CodingKey {
        case version
        case triggerSource
        case region
        case userPoolId
        case userName
        case callerContext
        case request
        case response
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let version = try container.decode(String.self, forKey: .version)
        let triggerSource = try container.decode(String.self, forKey: .triggerSource)
        let region = try container.decode(AWSRegion.self, forKey: .region)
        let userPoolId = try container.decode(String.self, forKey: .userPoolId)
        let userName = try container.decode(String.self, forKey: .userName)
        let callerContext = try container.decode(CognitoEvent.CallerContext.self, forKey: .callerContext)

        let params = CognitoEvent.Parameters(version: version, triggerSource: triggerSource, region: region, userPoolId: userPoolId, userName: userName, callerContext: callerContext)

        switch triggerSource {
        case "PreSignUp_SignUp":
            let request = try container.decode(CognitoEvent.PreSignUp.self, forKey: .request)
            let response = try container.decode(CognitoEventResponse.PreSignUp.self, forKey: .response)

            self = .preSignUpSignUp(params, request, response)
        default:
            throw CognitoEventError.unimplementedEvent(triggerSource)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let params = self.commonParameters

        try container.encode(params.version, forKey: .version)
        try container.encode(params.triggerSource, forKey: .triggerSource)
        try container.encode(params.region, forKey: .region)
        try container.encode(params.userPoolId, forKey: .userPoolId)
        try container.encode(params.userName, forKey: .userName)
        try container.encode(params.callerContext, forKey: .callerContext)

        switch self {
        case .preSignUpSignUp(_, let request, let response):
            try container.encode(request, forKey: .request)
            try container.encode(response, forKey: .response)
        }
    }
}
