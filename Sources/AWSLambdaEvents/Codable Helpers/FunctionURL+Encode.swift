#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import HTTPTypes

public extension FunctionURLResponse {
    /// Encodes a given encodable object into a `FunctionURLResponse` object.
    ///
    /// - Parameters:
    ///   - encodable: The object to encode.
    ///   - status: The status code to use. Defaults to `ok`.
    ///   - encoder: The encoder to use. Defaults to a new `JSONEncoder`.
    ///   - onError: A closure to handle errors, and transform them into a `FunctionURLResponse`. Defaults
    /// to converting the error into a 500 (Internal Server Error) response with the error message as the body.
    static func encoding<T>(
        _ encodable: T,
        status: HTTPResponse.Status = .ok,
        using encoder: JSONEncoder = JSONEncoder(),
        onError: ((Error) -> Self)? = nil
    ) -> Self where T: Encodable {
        do {
            let encodedResponse = try encoder.encode(encodable)
            return FunctionURLResponse(
                statusCode: status,
                body: String(data: encodedResponse, encoding: .utf8)
            )
        } catch {
            return (onError ?? defaultErrorHandler)(error)
        }
    }
}

private func defaultErrorHandler(_ error: Error) -> FunctionURLResponse {
    FunctionURLResponse(
        statusCode: .internalServerError,
        body: "Internal Server Error: \(String(describing: error))"
    )
}
