// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "swift-aws-lambda-events",
    products: [
        .library(name: "AWSLambdaEvents", targets: ["AWSLambdaEvents"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "AWSLambdaEvents", dependencies: []),
        .testTarget(name: "AWSLambdaEventsTests", dependencies: ["AWSLambdaEvents"]),
    ]
)
