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
struct APIGatewayV2IAMTests {
    static let getEventWithIAM = """
        {
            "version": "2.0",
            "routeKey": "$default",
            "rawPath": "/hello",
            "rawQueryString": "",
            "headers": {
                "accept": "*/*",
                "authorization": "AWS4-HMAC-SHA256 Credential=ASIA-redacted/us-east-1/execute-api/aws4_request, SignedHeaders=host;x-amz-date;x-amz-security-token, Signature=289b5fcef3d1156f019cc1140cb5565cc052880a5a0d5586c753e3e3c75556f9",
                "content-length": "0",
                "host": "74bxj8iqjc.execute-api.us-east-1.amazonaws.com",
                "user-agent": "curl/8.4.0",
                "x-amz-date": "20231214T203121Z",
                "x-amz-security-token": "IQoJb3JpZ2luX2VjEO3//////////-redacted",
                "x-amzn-trace-id": "Root=1-657b6619-3222de40051925dd66e1fd72",
                "x-forwarded-for": "191.95.150.52",
                "x-forwarded-port": "443",
                "x-forwarded-proto": "https"
            },
            "requestContext": {
                "accountId": "012345678912",
                "apiId": "74bxj8iqjc",
                "authorizer": {
                    "iam": {
                        "accessKey": "ASIA-redacted",
                        "accountId": "012345678912",
                        "callerId": "AIDA-redacted",
                        "cognitoIdentity": null,
                        "principalOrgId": "aws:PrincipalOrgID",
                        "userArn": "arn:aws:iam::012345678912:user/sst",
                        "userId": "AIDA-redacted"
                    }
                },
                "domainName": "74bxj8iqjc.execute-api.us-east-1.amazonaws.com",
                "domainPrefix": "74bxj8iqjc",
                "http": {
                    "method": "GET",
                    "path": "/liveness",
                    "protocol": "HTTP/1.1",
                    "sourceIp": "191.95.150.52",
                    "userAgent": "curl/8.4.0"
                },
                "requestId": "P8zkDiQ8oAMEJsQ=",
                "routeKey": "$default",
                "stage": "$default",
                "time": "14/Dec/2023:20:31:21 +0000",
                "timeEpoch": 1702585881671
            },
            "isBase64Encoded": false
        }
        """

    static let getEventWithIAMAndCognito = """
        {
            "version": "2.0",
            "routeKey": "$default",
            "rawPath": "/hello",
            "rawQueryString": "",
            "headers": {
                "accept": "*/*",
                "authorization": "AWS4-HMAC-SHA256 Credential=ASIA-redacted/us-east-1/execute-api/aws4_request, SignedHeaders=host;x-amz-date;x-amz-security-token, Signature=289b5fcef3d1156f019cc1140cb5565cc052880a5a0d5586c753e3e3c75556f9",
                "content-length": "0",
                "host": "74bxj8iqjc.execute-api.us-east-1.amazonaws.com",
                "user-agent": "curl/8.4.0",
                "x-amz-date": "20231214T203121Z",
                "x-amz-security-token": "IQoJb3JpZ2luX2VjEO3//////////-redacted",
                "x-amzn-trace-id": "Root=1-657b6619-3222de40051925dd66e1fd72",
                "x-forwarded-for": "191.95.150.52",
                "x-forwarded-port": "443",
                "x-forwarded-proto": "https"
            },
            "requestContext": {
                "accountId": "012345678912",
                "apiId": "74bxj8iqjc",
                "authorizer": {
                    "iam": {
                        "accessKey": "ASIA-redacted",
                        "accountId": "012345678912",
                        "callerId": "AROA-redacted:CognitoIdentityCredentials",
                        "cognitoIdentity": {
                            "amr": [
                                "authenticated",
                                "cognito-idp.us-east-1.amazonaws.com/us-east-1_ABCD",
                                "cognito-idp.us-east-1.amazonaws.com/us-east-1_ABCD:CognitoSignIn:04611e3d--redacted"
                            ],
                            "identityId": "us-east-1:68bc0ecd-9d5e--redacted",
                            "identityPoolId": "us-east-1:e8b526df--redacted"
                        },
                        "principalOrgId": "aws:PrincipalOrgID",
                        "userArn": "arn:aws:sts::012345678912:assumed-role/authRole/CognitoIdentityCredentials",
                        "userId": "AROA-redacted:CognitoIdentityCredentials"
                    }
                },
                "domainName": "74bxj8iqjc.execute-api.us-east-1.amazonaws.com",
                "domainPrefix": "74bxj8iqjc",
                "http": {
                    "method": "GET",
                    "path": "/liveness",
                    "protocol": "HTTP/1.1",
                    "sourceIp": "191.95.150.52",
                    "userAgent": "curl/8.4.0"
                },
                "requestId": "P8zkDiQ8oAMEJsQ=",
                "routeKey": "$default",
                "stage": "$default",
                "time": "14/Dec/2023:20:31:21 +0000",
                "timeEpoch": 1702585881671
            },
            "isBase64Encoded": false
        }
        """

    // MARK: - Request -

    // MARK: Decoding

    @Test func requestDecodingGetRequestWithIAM() throws {
        let data = APIGatewayV2IAMTests.getEventWithIAM.data(using: .utf8)!
        let req = try JSONDecoder().decode(APIGatewayV2Request.self, from: data)

        #expect(req.rawPath == "/hello")
        #expect(req.context.authorizer?.iam?.accessKey == "ASIA-redacted")
        #expect(req.context.authorizer?.iam?.accountId == "012345678912")
        #expect(req.body == nil)
    }

    @Test func requestDecodingGetRequestWithIAMWithCognito() throws {
        let data = APIGatewayV2IAMTests.getEventWithIAMAndCognito.data(using: .utf8)!
        let req = try JSONDecoder().decode(APIGatewayV2Request.self, from: data)

        #expect(req.rawPath == "/hello")
        #expect(req.context.authorizer?.iam?.accessKey == "ASIA-redacted")
        #expect(req.context.authorizer?.iam?.accountId == "012345678912")

        // test the cognito identity part
        #expect(req.context.authorizer?.iam?.cognitoIdentity?.identityId == "us-east-1:68bc0ecd-9d5e--redacted")
        #expect(req.context.authorizer?.iam?.cognitoIdentity?.amr?.count == 3)

        #expect(req.body == nil)
    }
}
