// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "swift-aws-lambda-events",
    products: [
        .library(name: "AWSLambdaEvents", targets: ["AWSLambdaEvents"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(name: "AWSLambdaEvents", dependencies: []),
        .testTarget(name: "AWSLambdaEventsTests", dependencies: ["AWSLambdaEvents"]),
    ]
)
