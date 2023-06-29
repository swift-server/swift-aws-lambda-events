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
import XCTest

class HTTPHeadersTests: XCTestCase {
    func first() throws {
        let headers: HTTPHeaders = [
            ":method": "GET",
            "foo": "bar",
            "custom-key": "value-1,value-2"
        ]

        XCTAssertEqual(headers.first(name: ":method"), "GET")
        XCTAssertEqual(headers.first(name: "Foo"), "bar")
        XCTAssertEqual(headers.first(name: "custom-key"), "value-1,value-2")
        XCTAssertNil(headers.first(name: "not-present"))
    }
}
