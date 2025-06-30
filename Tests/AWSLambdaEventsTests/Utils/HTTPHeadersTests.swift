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

import AWSLambdaEvents
import Testing

@Suite
struct HTTPHeadersTests {
    @Test func first() throws {
        let headers: HTTPHeaders = [
            ":method": "GET",
            "foo": "bar",
            "custom-key": "value-1,value-2",
        ]

        #expect(headers.first(name: ":method") == "GET")
        #expect(headers.first(name: "Foo") == "bar")
        #expect(headers.first(name: "custom-key") == "value-1,value-2")
        #expect(headers.first(name: "not-present") == nil)
    }
}
