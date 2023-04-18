# Swift AWS Lambda Events

## Overview

Swift AWS Lambda Runtime was designed to make building Lambda functions in Swift simple and safe. The library is an implementation of the [AWS Lambda Runtime API](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-custom.html) and uses an embedded asynchronous HTTP Client based on [SwiftNIO](http://github.com/apple/swift-nio) that is fine-tuned for performance in the AWS Runtime context. The library provides a multi-tier API that allows building a range of Lambda functions: From quick and simple closures to complex, performance-sensitive event handlers.

Swift AWS Lambda Events is a supporting library for the [Swift AWS Lambda Runtime](http://github.com/swift-server/swift-aws-lambda-runtime) library, providing abstractions for popular AWS events.

## Integration with AWS Platform Events

AWS Lambda functions can be invoked directly from the AWS Lambda console UI, AWS Lambda API, AWS SDKs, AWS CLI, and AWS toolkits. More commonly, they are invoked as a reaction to an events coming from the AWS platform. To make it easier to integrate with AWS platform events, this library includes an `AWSLambdaEvents` target which provides abstractions for many commonly used events. Additional events can be easily modeled when needed following the same patterns set by `AWSLambdaEvents`. Integration points with the AWS Platform include:

* [APIGateway Proxy](https://docs.aws.amazon.com/lambda/latest/dg/services-apigateway.html)
* [S3 Events](https://docs.aws.amazon.com/lambda/latest/dg/with-s3.html)
* [SES Events](https://docs.aws.amazon.com/lambda/latest/dg/services-ses.html)
* [SNS Events](https://docs.aws.amazon.com/lambda/latest/dg/with-sns.html)
* [SQS Events](https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html)
* [CloudWatch Events](https://docs.aws.amazon.com/lambda/latest/dg/services-cloudwatchevents.html)
* [Cognito Lambda Triggers](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools-working-with-aws-lambda-triggers.html)

**Note**: Each one of the integration points mentioned above includes a set of `Codable` structs that mirror AWS' data model for these APIs.

## Getting started

If you have never used AWS Lambda or Docker before, check out this [getting started guide](https://fabianfett.dev/getting-started-with-swift-aws-lambda-runtime) which helps you with every step from zero to a running Lambda.

Swift AWS Lambda Events is a supporting library for the [Swift AWS Lambda Runtime](http://github.com/swift-server/swift-aws-lambda-runtime) library, where you can find further documentation and examples.

## Project status

This is the beginning of a community-driven open-source project actively seeking contributions.
While the core API is considered stable, the API may still evolve as we get closer to a `1.0` version.
There are several areas which need additional attention, including but not limited to:

* Additional events
* Additional documentation and best practices
* Additional examples

## Security

Please see [SECURITY.md](SECURITY.md) for details on the security process.
