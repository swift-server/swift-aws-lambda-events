//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAwsLambda open source project
//
// Copyright (c) 2017-2018 Apple Inc. and the SwiftAwsLambda project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAwsLambda project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

import Backtrace
import Foundation // for URL
import Logging
import NIO
import NIOConcurrencyHelpers

public enum Lambda {
    /// Run a Lambda defined by implementing the `LambdaClosure` closure.
    ///
    /// - note: This is a blocking operation that will run forever, as it's lifecycle is managed by the AWS Lambda Runtime Engine.
    @inlinable
    public static func run(_ closure: @escaping LambdaClosure) {
        self.run(closure: closure)
    }

    /// Run a Lambda defined by implementing the `LambdaHandler` protocol.
    ///
    /// - note: This is a blocking operation that will run forever, as it's lifecycle is managed by the AWS Lambda Runtime Engine.
    @inlinable
    public static func run(_ handler: LambdaHandler) {
        self.run(handler: handler)
    }

    // for testing and internal use
    @usableFromInline
    @discardableResult
    internal static func run(configuration: Configuration = .init(), closure: @escaping LambdaClosure) -> LambdaLifecycleResult {
        return self.run(handler: LambdaClosureWrapper(closure), configuration: configuration)
    }

    // for testing and internal use
    @usableFromInline
    @discardableResult
    internal static func run(handler: LambdaHandler, configuration: Configuration = .init()) -> LambdaLifecycleResult {
        do {
            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
            defer { try! eventLoopGroup.syncShutdownGracefully() }
            let result = try self.runAsync(eventLoopGroup: eventLoopGroup, handler: handler, configuration: configuration).wait()
            return .success(result)
        } catch {
            return .failure(error)
        }
    }

    internal static func runAsync(eventLoopGroup: EventLoopGroup, handler: LambdaHandler, configuration: Configuration) -> EventLoopFuture<Int> {
        Backtrace.install()
        var logger = Logger(label: "Lambda")
        logger.logLevel = configuration.general.logLevel
        let lifecycle = Lifecycle(eventLoop: eventLoopGroup.next(), logger: logger, configuration: configuration, handler: handler)
        let signalSource = trap(signal: configuration.lifecycle.stopSignal) { signal in
            logger.info("intercepted signal: \(signal)")
            lifecycle.stop()
        }
        return lifecycle.start().always { _ in
            lifecycle.shutdown()
            signalSource.cancel()
        }
    }

    private final class Lifecycle {
        private let eventLoop: EventLoop
        private let logger: Logger
        private let configuration: Configuration
        private let handler: LambdaHandler

        private var _state = LifecycleState.idle
        private let stateLock = Lock()

        init(eventLoop: EventLoop, logger: Logger, configuration: Configuration, handler: LambdaHandler) {
            self.eventLoop = eventLoop
            self.logger = logger
            self.configuration = configuration
            self.handler = handler
        }

        deinit {
            precondition(self.state == .shutdown, "invalid state \(self.state)")
        }

        private var state: LifecycleState {
            get {
                return self.stateLock.withLock {
                    self._state
                }
            }
            set {
                self.stateLock.withLockVoid {
                    precondition(newValue.rawValue > _state.rawValue, "invalid state \(newValue) after \(_state)")
                    self._state = newValue
                }
            }
        }

        func start() -> EventLoopFuture<Int> {
            logger.info("lambda lifecycle starting with \(self.configuration)")
            self.state = .initializing
            var logger = self.logger
            logger[metadataKey: "lifecycleId"] = .string(self.configuration.lifecycle.id)
            let runner = LambdaRunner(eventLoop: self.eventLoop, configuration: self.configuration, lambdaHandler: self.handler)
            return runner.initialize(logger: logger).flatMap { _ in
                self.state = .active
                return self.run(logger: logger, runner: runner, count: 0)
            }
        }

        func stop() {
            self.logger.info("lambda lifecycle stopping")
            self.state = .stopping
        }

        func shutdown() {
            self.logger.info("lambda lifecycle shutdown")
            self.state = .shutdown
        }

        private func run(logger: Logger, runner: LambdaRunner, count: Int) -> EventLoopFuture<Int> {
            switch self.state {
            case .active:
                if self.configuration.lifecycle.maxTimes > 0, count >= self.configuration.lifecycle.maxTimes {
                    return self.eventLoop.makeSucceededFuture(count)
                }
                var logger = logger
                logger[metadataKey: "lifecycleIteration"] = "\(count)"
                return runner.run(logger: logger).flatMap { _ in
                    // recursive! per aws lambda runtime spec the polling requests are to be done one at a time
                    self.run(logger: logger, runner: runner, count: count + 1)
                }
            case .stopping, .shutdown:
                return self.eventLoop.makeSucceededFuture(count)
            default:
                preconditionFailure("invalid run state: \(self.state)")
            }
        }
    }

    @usableFromInline
    internal struct Configuration: CustomStringConvertible {
        let general: General
        let lifecycle: Lifecycle
        let runtimeEngine: RuntimeEngine

        @usableFromInline
        init() {
            self.init(general: .init(), lifecycle: .init(), runtimeEngine: .init())
        }

        init(general: General? = nil, lifecycle: Lifecycle? = nil, runtimeEngine: RuntimeEngine? = nil) {
            self.general = general ?? General()
            self.lifecycle = lifecycle ?? Lifecycle()
            self.runtimeEngine = runtimeEngine ?? RuntimeEngine()
        }

        struct General: CustomStringConvertible {
            let logLevel: Logger.Level

            init(logLevel: Logger.Level? = nil) {
                self.logLevel = logLevel ?? env("LOG_LEVEL").flatMap(Logger.Level.init) ?? .info
            }

            var description: String {
                return "\(General.self)(logLevel: \(self.logLevel))"
            }
        }

        struct Lifecycle: CustomStringConvertible {
            let id: String
            let maxTimes: Int
            let stopSignal: Signal

            init(id: String? = nil, maxTimes: Int? = nil, stopSignal: Signal? = nil) {
                self.id = id ?? UUID().uuidString
                self.maxTimes = maxTimes ?? env("MAX_REQUESTS").flatMap(Int.init) ?? 0
                self.stopSignal = stopSignal ?? env("STOP_SIGNAL").flatMap(Int32.init).flatMap(Signal.init) ?? Signal.TERM
                precondition(self.maxTimes >= 0, "maxTimes must be equal or larger than 0")
            }

            var description: String {
                return "\(Lifecycle.self)(id: \(self.id), maxTimes: \(self.maxTimes), stopSignal: \(self.stopSignal))"
            }
        }

        struct RuntimeEngine: CustomStringConvertible {
            let baseURL: HTTPURL
            let keepAlive: Bool
            let requestTimeout: TimeAmount?
            let offload: Bool

            init(baseURL: String? = nil, keepAlive: Bool? = nil, requestTimeout: TimeAmount? = nil, offload: Bool? = nil) {
                self.baseURL = HTTPURL(baseURL ?? "http://\(env("AWS_LAMBDA_RUNTIME_API") ?? "127.0.0.1:7000")")
                self.keepAlive = keepAlive ?? env("KEEP_ALIVE").flatMap(Bool.init) ?? true
                self.requestTimeout = requestTimeout ?? env("REQUEST_TIMEOUT").flatMap(Int64.init).flatMap { .milliseconds($0) }
                self.offload = offload ?? env("OFFLOAD").flatMap(Bool.init) ?? false
            }

            var description: String {
                return "\(RuntimeEngine.self)(baseURL: \(self.baseURL), keepAlive: \(self.keepAlive), requestTimeout: \(String(describing: self.requestTimeout)), offload: \(self.offload)"
            }
        }

        @usableFromInline
        var description: String {
            return "\(Configuration.self)\n  \(self.general))\n  \(self.lifecycle)\n  \(self.runtimeEngine)"
        }
    }

    internal struct HTTPURL: Equatable, CustomStringConvertible {
        private let url: URL
        let host: String
        let port: Int

        init(_ url: String) {
            guard let url = Foundation.URL(string: url) else {
                preconditionFailure("invalid url")
            }
            guard let host = url.host else {
                preconditionFailure("invalid url host")
            }
            guard let port = url.port else {
                preconditionFailure("invalid url port")
            }
            self.url = url
            self.host = host
            self.port = port
        }

        init(url: URL, host: String, port: Int) {
            self.url = url
            self.host = host
            self.port = port
        }

        func appendingPathComponent(_ pathComponent: String) -> HTTPURL {
            return .init(url: self.url.appendingPathComponent(pathComponent), host: self.host, port: self.port)
        }

        var path: String {
            return self.url.path
        }

        var query: String? {
            return self.url.query
        }

        var description: String {
            return self.url.description
        }
    }

    private enum LifecycleState: Int {
        case idle
        case initializing
        case active
        case stopping
        case shutdown
    }
}

/// A result type for a Lambda that returns a `[UInt8]`.
public typealias LambdaResult = Result<[UInt8], Error>

public typealias LambdaCallback = (LambdaResult) -> Void

/// A processing closure for a Lambda that takes a `[UInt8]` and returns a `LambdaResult` result type asynchronously.
public typealias LambdaClosure = (LambdaContext, [UInt8], LambdaCallback) -> Void

/// A result type for a Lambda initialization.
public typealias LambdaInitResult = Result<Void, Error>

/// A callback to provide the result of Lambda initialization.
public typealias LambdaInitCallBack = (LambdaInitResult) -> Void

/// A processing protocol for a Lambda that takes a `[UInt8]` and returns a `LambdaResult` result type asynchronously.
public protocol LambdaHandler {
    /// Initializes the `LambdaHandler`.
    func initialize(callback: @escaping LambdaInitCallBack)
    func handle(context: LambdaContext, payload: [UInt8], callback: @escaping LambdaCallback)
}

extension LambdaHandler {
    @inlinable
    public func initialize(callback: @escaping LambdaInitCallBack) {
        callback(.success(()))
    }
}

public struct LambdaContext {
    // from aws
    public let requestId: String
    public let traceId: String?
    public let invokedFunctionArn: String?
    public let cognitoIdentity: String?
    public let clientContext: String?
    public let deadline: String?
    // utliity
    public let logger: Logger

    public init(requestId: String,
                traceId: String? = nil,
                invokedFunctionArn: String? = nil,
                cognitoIdentity: String? = nil,
                clientContext: String? = nil,
                deadline: String? = nil,
                logger: Logger) {
        self.requestId = requestId
        self.traceId = traceId
        self.invokedFunctionArn = invokedFunctionArn
        self.cognitoIdentity = cognitoIdentity
        self.clientContext = clientContext
        self.deadline = deadline
        // mutate logger with context
        var logger = logger
        logger[metadataKey: "awsRequestId"] = .string(requestId)
        if let traceId = traceId {
            logger[metadataKey: "awsTraceId"] = .string(traceId)
        }
        self.logger = logger
    }
}

@usableFromInline
internal typealias LambdaLifecycleResult = Result<Int, Error>

private struct LambdaClosureWrapper: LambdaHandler {
    private let closure: LambdaClosure
    init(_ closure: @escaping LambdaClosure) {
        self.closure = closure
    }

    func handle(context: LambdaContext, payload: [UInt8], callback: @escaping LambdaCallback) {
        self.closure(context, payload, callback)
    }
}
