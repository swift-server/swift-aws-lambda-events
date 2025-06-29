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
struct AppSyncTests {
    static let exampleEventBody = """
        {
          "arguments": {
        	"id": "my identifier"
          },
          "identity": {
        	"claims": {
        	  "sub": "192879fc-a240-4bf1-ab5a-d6a00f3063f9",
        	  "email_verified": true,
        	  "iss": "https://cognito-idp.us-west-2.amazonaws.com/us-west-xxxxxxxxxxx",
        	  "phone_number_verified": false,
        	  "cognito:username": "jdoe",
        	  "aud": "7471s60os7h0uu77i1tk27sp9n",
        	  "event_id": "bc334ed8-a938-4474-b644-9547e304e606",
        	  "token_use": "id",
        	  "auth_time": 1599154213,
        	  "phone_number": "+19999999999",
        	  "exp": 1599157813,
        	  "iat": 1599154213,
        	  "email": "jdoe@email.com"
        	},
        	"defaultAuthStrategy": "ALLOW",
        	"groups": null,
        	"issuer": "https://cognito-idp.us-west-2.amazonaws.com/us-west-xxxxxxxxxxx",
        	"sourceIp": [
        	  "1.1.1.1"
        	],
        	"sub": "192879fc-a240-4bf1-ab5a-d6a00f3063f9",
        	"username": "jdoe"
          },
          "source": null,
          "request": {
        	"headers": {
        	  "x-forwarded-for": "1.1.1.1, 2.2.2.2",
        	  "cloudfront-viewer-country": "US",
        	  "cloudfront-is-tablet-viewer": "false",
        	  "via": "2.0 xxxxxxxxxxxxxxxx.cloudfront.net (CloudFront)",
        	  "cloudfront-forwarded-proto": "https",
        	  "origin": "https://us-west-1.console.aws.amazon.com",
        	  "content-length": "217",
        	  "accept-language": "en-US,en;q=0.9",
        	  "host": "xxxxxxxxxxxxxxxx.appsync-api.us-west-1.amazonaws.com",
        	  "x-forwarded-proto": "https",
        	  "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.83 Safari/537.36",
        	  "accept": "*/*",
        	  "cloudfront-is-mobile-viewer": "false",
        	  "cloudfront-is-smarttv-viewer": "false",
        	  "accept-encoding": "gzip, deflate, br",
        	  "referer": "https://us-west-1.console.aws.amazon.com/appsync/home?region=us-west-1",
        	  "content-type": "application/json",
        	  "sec-fetch-mode": "cors",
        	  "x-amz-cf-id": "3aykhqlUwQeANU-HGY7E_guV5EkNeMMtwyOgiA==",
        	  "x-amzn-trace-id": "Root=1-5f512f51-fac632066c5e848ae714",
        	  "authorization": "eyJraWQiOiJScWFCSlJqYVJlM0hrSnBTUFpIcVRXazNOW...",
        	  "sec-fetch-dest": "empty",
        	  "x-amz-user-agent": "AWS-Console-AppSync/",
        	  "cloudfront-is-desktop-viewer": "true",
        	  "sec-fetch-site": "cross-site",
        	  "x-forwarded-port": "443"
        	}
          },
          "prev": null,
          "info": {
        	"selectionSetList": [
        	  "id",
        	  "field1",
        	  "field2"
        	],
        	"selectionSetGraphQL": "{ id }",
        	"parentTypeName": "Mutation",
        	"fieldName": "createSomething",
        	"variables": {}
          },
          "stash": {}
        }
        """

    // MARK: Decoding

    @Test func requestDecodingExampleEvent() throws {
        let data = AppSyncTests.exampleEventBody.data(using: .utf8)!
        let event = try JSONDecoder().decode(AppSyncEvent.self, from: data)

        #expect(event.arguments["id"] == .string("my identifier"))
        #expect(event.info.fieldName == "createSomething")
        #expect(event.info.parentTypeName == "Mutation")
        #expect(event.info.selectionSetList == ["id", "field1", "field2"])
        #expect(event.request.headers["accept-language"] == "en-US,en;q=0.9")

        switch event.identity {
        case .cognitoUserPools(let cognitoIdentity):
            #expect(cognitoIdentity.defaultAuthStrategy == "ALLOW")
            #expect(cognitoIdentity.issuer == "https://cognito-idp.us-west-2.amazonaws.com/us-west-xxxxxxxxxxx")
            #expect(cognitoIdentity.sourceIp == ["1.1.1.1"])
            #expect(cognitoIdentity.username == "jdoe")
            #expect(cognitoIdentity.sub == "192879fc-a240-4bf1-ab5a-d6a00f3063f9")
        default:
            #expect(false, "a cognito identity was expected, but didn't find one.")
        }
    }

    @Test func requestDecodingEventWithSource() throws {
        let eventBody = """
            {
                "arguments": {},
                "identity": null,
                "source": {
                    "name": "Hello",
                    "id": "1"
                },
                "request": {
                    "headers": {
                        "x-forwarded-for": "1.1.1.1, 2.2.2.2",
                        "accept-encoding": "gzip, deflate, br",
                        "cloudfront-viewer-country": "CA",
                        "cloudfront-is-tablet-viewer": "false",
                        "referer": "https://us-west-2.console.aws.amazon.com/",
                        "via": "2.0 xxxxxx.cloudfront.net (CloudFront)",
                        "cloudfront-forwarded-proto": "https",
                        "origin": "https://us-west-2.console.aws.amazon.com",
                        "x-api-key": "xxxxxxxxxxxxxxxxxxxxx",
                        "content-type": "application/json",
                        "x-amzn-trace-id": "Root=1-5fcd9a24-364c62405b418bd53c7984ce",
                        "x-amz-cf-id": "3aykhqlUwQeANU-HGY7E_guV5EkNeMMtwyOgiA==",
                        "content-length": "173",
                        "x-amz-user-agent": "AWS-Console-AppSync/",
                        "x-forwarded-proto": "https",
                        "host": "xxxxxxxxxxxxxxxx.appsync-api.us-west-2.amazonaws.com",
                        "accept-language": "en-ca",
                        "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Safari/605.1.15",
                        "cloudfront-is-desktop-viewer": "true",
                        "cloudfront-is-mobile-viewer": "false",
                        "accept": "*/*",
                        "x-forwarded-port": "443",
                        "cloudfront-is-smarttv-viewer": "false"
                    }
                },
                "prev": null,
                "info": {
                    "selectionSetList": [
                        "address",
                        "id"
                    ],
                    "selectionSetGraphQL": "{ address id}",
                    "parentTypeName": "Customer",
                    "fieldName": "address",
                    "variables": {}
                },
                "stash": {}
            }
            """

        let data = eventBody.data(using: .utf8)!
        let event = try JSONDecoder().decode(AppSyncEvent.self, from: data)
        #expect(event.source?["name"] == "Hello")
        #expect(event.stash?.isEmpty ?? false, "stash dictionary must be empty")
        #expect(event.identity == nil)
    }

    @Test func requestDecodingIamIdentity() throws {
        let eventBody = """
            {
                "arguments": {},
                "identity": {
                    "accountId" : "accountId1",
                    "cognitoIdentityPoolId" : "cognitoIdentityPool2",
                    "cognitoIdentityId" : "cognitoIdentity3",
                    "sourceIp" : ["1.1.1.1"],
                    "username" : null,
                    "userArn" : "arn123",
                    "cognitoIdentityAuthType" : "authenticated",
                    "cognitoIdentityAuthProvider" : "authprovider"
                },
                "source": {
                    "name": "Hello",
                    "id": "1"
                },
                "request": {
                    "headers": {
                        "x-forwarded-for": "1.1.1.1, 2.2.2.2",
                        "accept-encoding": "gzip, deflate, br",
                        "cloudfront-viewer-country": "CA",
                        "cloudfront-is-tablet-viewer": "false",
                        "referer": "https://us-west-2.console.aws.amazon.com/",
                        "via": "2.0 xxxxxx.cloudfront.net (CloudFront)",
                        "cloudfront-forwarded-proto": "https",
                        "origin": "https://us-west-2.console.aws.amazon.com",
                        "x-api-key": "xxxxxxxxxxxxxxxxxxxxx",
                        "content-type": "application/json",
                        "x-amzn-trace-id": "Root=1-5fcd9a24-364c62405b418bd53c7984ce",
                        "x-amz-cf-id": "3aykhqlUwQeANU-HGY7E_guV5EkNeMMtwyOgiA==",
                        "content-length": "173",
                        "x-amz-user-agent": "AWS-Console-AppSync/",
                        "x-forwarded-proto": "https",
                        "host": "xxxxxxxxxxxxxxxx.appsync-api.us-west-2.amazonaws.com",
                        "accept-language": "en-ca",
                        "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Safari/605.1.15",
                        "cloudfront-is-desktop-viewer": "true",
                        "cloudfront-is-mobile-viewer": "false",
                        "accept": "*/*",
                        "x-forwarded-port": "443",
                        "cloudfront-is-smarttv-viewer": "false"
                    }
                },
                "prev": null,
                "info": {
                    "selectionSetList": [
                        "address",
                        "id"
                    ],
                    "selectionSetGraphQL": "{ address id}",
                    "parentTypeName": "Customer",
                    "fieldName": "address",
                    "variables": {}
                },
                "stash": {}
            }
            """

        let data = eventBody.data(using: .utf8)!
        let event = try JSONDecoder().decode(AppSyncEvent.self, from: data)
        switch event.identity {
        case .iam(let iamIdentity):
            #expect(iamIdentity.accountId == "accountId1")
            #expect(iamIdentity.cognitoIdentityPoolId == "cognitoIdentityPool2")
            #expect(iamIdentity.cognitoIdentityId == "cognitoIdentity3")
            #expect(iamIdentity.sourceIp == ["1.1.1.1"])
            #expect(iamIdentity.username == nil)
            #expect(iamIdentity.userArn == "arn123")
            #expect(iamIdentity.cognitoIdentityAuthType == "authenticated")
            #expect(iamIdentity.cognitoIdentityAuthProvider == "authprovider")
        default:
            #expect(false, "an iam identity was expected, but didn't find one.")
        }
    }
}

extension AppSyncEvent.ArgumentValue: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.string(let lhsString), .string(let rhsString)):
            return lhsString == rhsString
        case (.dictionary(let lhsDictionary), .dictionary(let rhsDictionary)):
            return lhsDictionary == rhsDictionary
        default:
            return false
        }
    }
}
