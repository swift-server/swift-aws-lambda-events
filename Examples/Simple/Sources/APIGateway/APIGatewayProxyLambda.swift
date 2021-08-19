//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAWSLambdaRuntime open source project
//
// Copyright (c) 2020 Apple Inc. and the SwiftAWSLambdaRuntime project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAWSLambdaRuntime project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import AWSLambdaEvents
import AWSLambdaRuntime
import NIO

// MARK: - Run Lambda

// FIXME: Use proper Event abstractions once added to AWSLambdaRuntime
@main
struct APIGatewayProxyLambda: AsyncLambdaHandler {
    typealias In = APIGatewayV2Request
    typealias Out = APIGatewayV2Response

    init(context: Lambda.InitializationContext) async throws {
        
    }
    
    func handle(event: APIGatewayV2Request, context: Lambda.Context) async throws -> APIGatewayV2Response {
        context.logger.debug("hello, api gateway!")
        return APIGatewayV2Response(statusCode: .ok, body: "hello, world!")
    }
}
