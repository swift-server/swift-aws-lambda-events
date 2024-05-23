// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "swift-aws-lambda-events",
    products: [
        .library(name: "AWSLambdaEvents", targets: ["AWSLambdaEvents"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "AWSLambdaEvents",
                dependencies: [.product(name: "HTTPTypes", package: "swift-http-types")],
                swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]),
        .testTarget(name: "AWSLambdaEventsTests",
                    dependencies: ["AWSLambdaEvents"],
                    swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]),
    ]
)
