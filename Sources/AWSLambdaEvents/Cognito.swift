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

enum CognitoEventError: Error, Sendable {
    case unimplementedEvent(String)
}

/// https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools-working-with-aws-lambda-triggers.html
public enum CognitoEvent: Equatable, Sendable {
    public struct CallerContext: Codable, Hashable, Sendable {
        let awsSdkVersion: String
        let clientId: String
    }

    public enum TriggerSource: String, Codable, Sendable {
        case preSignUp_SignUp = "PreSignUp_SignUp"
        case preSignUp_ExternalProvider = "PreSignUp_ExternalProvider"
        case postConfirmation_ConfirmSignUp = "PostConfirmation_ConfirmSignUp"
        case preAuthentication_Authentication = "PreAuthentication_Authentication"
        case postAuthentication_Authentication = "PostAuthentication_Authentication"
        case customMessage_SignUp = "CustomMessage_SignUp"
        case customMessage_AdminCreateUser = "CustomMessage_AdminCreateUser"
        case customMessage_ResendCode = "CustomMessage_ResendCode"
        case customMessage_ForgotPassword = "CustomMessage_ForgotPassword"
        case customMessage_UpdateUserAttribute = "CustomMessage_UpdateUserAttribute"
        case customMessage_VerifyUserAttribute = "CustomMessage_VerifyUserAttribute"
        case customMessage_Authentication = "CustomMessage_Authentication"
        case defineAuthChallenge_Authentication = "DefineAuthChallenge_Authentication"
        case createAuthChallenge_Authentication = "CreateAuthChallenge_Authentication"
        case verifyAuthChallengeResponse_Authentication = "VerifyAuthChallengeResponse_Authentication"
        case preSignUp_AdminCreateUser = "PreSignUp_AdminCreateUser"
        case postConfirmation_ConfirmForgotPassword = "PostConfirmation_ConfirmForgotPassword"
        case tokenGeneration_HostedAuth = "TokenGeneration_HostedAuth"
        case tokenGeneration_Authentication = "TokenGeneration_Authentication"
        case tokenGeneration_NewPasswordChallenge = "TokenGeneration_NewPasswordChallenge"
        case tokenGeneration_AuthenticateDevice = "TokenGeneration_AuthenticateDevice"
        case tokenGeneration_RefreshTokens = "TokenGeneration_RefreshTokens"
        case userMigration_Authentication = "UserMigration_Authentication"
        case userMigration_ForgotPassword = "UserMigration_ForgotPassword"
    }

    public struct Parameters: Codable, Equatable, Sendable {
        let version: String
        let triggerSource: TriggerSource
        let region: AWSRegion
        let userPoolId: String
        let userName: String
        let callerContext: CallerContext
    }

    case preSignUpSignUp(Parameters, PreSignUp)

    public struct PreSignUp: Codable, Hashable, Sendable {
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

    case postConfirmation(Parameters, PostConfirmation)

    public struct PostConfirmation: Codable, Equatable, Sendable {
        /// One or more key-value pairs representing user attributes.
        public let userAttributes: [String: String]

        /// One or more key-value pairs that you can provide as custom input to the Lambda function that you specify for the post confirmation trigger.
        ///
        /// You can pass this data to your Lambda function by using the ClientMetadata parameter in the following API actions: AdminConfirmSignUp, ConfirmForgotPassword, ConfirmSignUp, and SignUp.
        public let clientMetadata: [String: String]?
    }

    case postAuthentication(Parameters, PostAuthentication)

    public struct PostAuthentication: Codable, Equatable, Sendable {
        /// This flag indicates if the user has signed in on a new device. Amazon Cognito only sets this flag if the remembered devices value of the user pool is Always or User Opt-In.
        public let newDeviceUsed: Bool

        /// One or more name-value pairs representing user attributes.
        public let userAttributes: [String: String]

        /// One or more key-value pairs that you can provide as custom input to the Lambda function that you specify for the post authentication trigger.
        ///
        /// To pass this data to your Lambda function, you can use the ClientMetadata parameter in the AdminRespondToAuthChallenge and RespondToAuthChallenge API actions.
        /// Amazon Cognito doesn't include data from the ClientMetadata parameter in AdminInitiateAuth and InitiateAuth API operations in the request that it passes to the post authentication function.
        public let clientMetadata: [String: String]?
    }

    case customMessage(Parameters, CustomMessage)

    public struct CustomMessage: Codable, Equatable, Sendable {
        /// A string for you to use as the placeholder for the verification code in the custom message.
        public let codeParameter: String?

        /// The user name. Amazon Cognito includes this parameter in requests that result from admin-created users.
        public let usernameParameter: String?

        /// One or more name-value pairs representing user attributes.
        public let userAttributes: [String: String]

        /// One or more key-value pairs that you can provide as custom input to the Lambda function that you specify for the custom message trigger.
        ///
        /// The request that invokes a custom message function doesn't include data passed in the ClientMetadata parameter in AdminInitiateAuth and InitiateAuth API operations. To pass this data to your Lambda function, you can use the ClientMetadata parameter in the following API actions:
        /// - AdminResetUserPassword
        /// - AdminRespondToAuthChallenge
        /// - AdminUpdateUserAttributes
        /// - ForgotPassword
        /// - GetUserAttributeVerificationCode
        /// - ResendConfirmationCode
        /// - SignUp
        /// - UpdateUserAttributes
        public let clientMetadata: [String: String]?
    }

    public var commonParameters: Parameters {
        switch self {
        case .preSignUpSignUp(let params, _):
            return params
        case .postConfirmation(let params, _):
            return params
        case .postAuthentication(let params, _):
            return params
        case .customMessage(let params, _):
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
        let triggerSource = try container.decode(TriggerSource.self, forKey: .triggerSource)
        let region = try container.decode(AWSRegion.self, forKey: .region)
        let userPoolId = try container.decode(String.self, forKey: .userPoolId)
        let userName = try container.decode(String.self, forKey: .userName)
        let callerContext = try container.decode(CallerContext.self, forKey: .callerContext)

        let params = CognitoEvent.Parameters(version: version, triggerSource: triggerSource, region: region, userPoolId: userPoolId, userName: userName, callerContext: callerContext)

        switch triggerSource {
        case .preSignUp_SignUp:
            let value = try container.decode(CognitoEvent.PreSignUp.self, forKey: .request)
            self = .preSignUpSignUp(params, value)

        case .postConfirmation_ConfirmSignUp, .postConfirmation_ConfirmForgotPassword:
            let value = try container.decode(CognitoEvent.PostConfirmation.self, forKey: .request)
            self = .postConfirmation(params, value)

        case .postAuthentication_Authentication:
            let value = try container.decode(CognitoEvent.PostAuthentication.self, forKey: .request)
            self = .postAuthentication(params, value)

        case .customMessage_SignUp, .customMessage_AdminCreateUser, .customMessage_ResendCode, .customMessage_ForgotPassword, .customMessage_UpdateUserAttribute, .customMessage_VerifyUserAttribute, .customMessage_Authentication:
            let value = try container.decode(CognitoEvent.CustomMessage.self, forKey: .request)
            self = .customMessage(params, value)

        default:
            throw CognitoEventError.unimplementedEvent(triggerSource.rawValue)
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
        case .postConfirmation(_, let value):
            try container.encode(value, forKey: .response)
        case .postAuthentication(_, let value):
            try container.encode(value, forKey: .response)
        case .customMessage(_, let value):
            try container.encode(value, forKey: .response)
        }
    }
}

public enum CognitoEventResponse: Sendable {
    // Used for when there are no parameters expected in the response
    public struct EmptyResponse: Codable, Equatable, Sendable {
        public init() {}
    }

    case preSignUpSignUp(CognitoEvent.Parameters, CognitoEvent.PreSignUp, PreSignUp)

    public struct PreSignUp: Codable, Hashable, Sendable {
        public let autoConfirmUser: Bool
        public let autoVerifyPhone: Bool
        public let autoVerifyEmail: Bool

        public init(autoConfirmUser: Bool, autoVerifyPhone: Bool, autoVerifyEmail: Bool) {
            self.autoConfirmUser = autoConfirmUser
            self.autoVerifyPhone = autoVerifyPhone
            self.autoVerifyEmail = autoVerifyEmail
        }
    }

    case postConfirmation(CognitoEvent.Parameters, CognitoEvent.PostConfirmation, EmptyResponse)

    case postAuthentication(CognitoEvent.Parameters, CognitoEvent.PostAuthentication, EmptyResponse)

    case customMessage(CognitoEvent.Parameters, CognitoEvent.CustomMessage, CustomMessage)

    public struct CustomMessage: Codable, Equatable, Sendable {
        public init(smsMessage: String? = nil, emailMessage: String? = nil, emailSubject: String? = nil) {
            self.smsMessage = smsMessage
            self.emailMessage = emailMessage
            self.emailSubject = emailSubject
        }

        /// The custom SMS message to be sent to your users. Must include the codeParameter value that you received in the request.
        public let smsMessage: String?

        /// The custom email message to send to your users. You can use HTML formatting in the emailMessage parameter. Must include the codeParameter value that you received in the request as the variable {####}.
        public let emailMessage: String?

        /// The subject line for the custom message
        public let emailSubject: String?
    }

    public var commonParameters: CognitoEvent.Parameters {
        switch self {
        case .preSignUpSignUp(let params, _, _):
            return params
        case .postConfirmation(let params, _, _):
            return params
        case .postAuthentication(let params, _, _):
            return params
        case .customMessage(let params, _, _):
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
        let triggerSource = try container.decode(CognitoEvent.TriggerSource.self, forKey: .triggerSource)
        let region = try container.decode(AWSRegion.self, forKey: .region)
        let userPoolId = try container.decode(String.self, forKey: .userPoolId)
        let userName = try container.decode(String.self, forKey: .userName)
        let callerContext = try container.decode(CognitoEvent.CallerContext.self, forKey: .callerContext)

        let params = CognitoEvent.Parameters(version: version, triggerSource: triggerSource, region: region, userPoolId: userPoolId, userName: userName, callerContext: callerContext)

        switch triggerSource {
        case .preSignUp_SignUp:
            let request = try container.decode(CognitoEvent.PreSignUp.self, forKey: .request)
            let response = try container.decode(CognitoEventResponse.PreSignUp.self, forKey: .response)

            self = .preSignUpSignUp(params, request, response)

        case .postConfirmation_ConfirmSignUp, .postConfirmation_ConfirmForgotPassword:
            let request = try container.decode(CognitoEvent.PostConfirmation.self, forKey: .request)
            let response = try container.decode(CognitoEventResponse.EmptyResponse.self, forKey: .response)

            self = .postConfirmation(params, request, response)

        case .postAuthentication_Authentication:
            let request = try container.decode(CognitoEvent.PostAuthentication.self, forKey: .request)
            let response = try container.decode(CognitoEventResponse.EmptyResponse.self, forKey: .response)

            self = .postAuthentication(params, request, response)

        case .customMessage_SignUp, .customMessage_AdminCreateUser, .customMessage_ResendCode, .customMessage_ForgotPassword, .customMessage_UpdateUserAttribute, .customMessage_VerifyUserAttribute, .customMessage_Authentication:
            let request = try container.decode(CognitoEvent.CustomMessage.self, forKey: .request)
            let response = try container.decode(CognitoEventResponse.CustomMessage.self, forKey: .response)

            self = .customMessage(params, request, response)

        default:
            throw CognitoEventError.unimplementedEvent(triggerSource.rawValue)
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
        case .postConfirmation(_, let request, let response):
            try container.encode(request, forKey: .request)
            try container.encode(response, forKey: .response)
        case .postAuthentication(_, let request, let response):
            try container.encode(request, forKey: .request)
            try container.encode(response, forKey: .response)
        case .customMessage(_, let request, let response):
            try container.encode(request, forKey: .request)
            try container.encode(response, forKey: .response)
        }
    }
}
