#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

import HTTPTypes

public extension APIGatewayV2Request {
    /// Decodes the body of the request into a `Data` object.
    ///
    /// - Returns: The decoded body as `Data` or `nil` if the body is empty.
    func decodeBody() throws -> Data? {
        guard let body else { return nil }

        if isBase64Encoded,
           let base64Decoded = Data(base64Encoded: body) {
            return base64Decoded
        }

        return body.data(using: .utf8)
    }

    /// Decodes the body of the request into a decodable object. When the
    /// body is empty, an error is thrown.
    ///
    /// - Parameters:
    ///   - type: The type to decode the body into.
    ///   - decoder: The decoder to use. Defaults to `JSONDecoder()`.
    ///
    /// - Returns: The decoded body as `T`.
    /// - Throws: An error if the body cannot be decoded.
    func decodeBody<T>(
        _ type: T.Type,
        using decoder: JSONDecoder = JSONDecoder()
    ) throws -> T where T: Decodable {
        let bodyData = body?.data(using: .utf8) ?? Data()

        var requestData = bodyData

        if isBase64Encoded,
           let base64Decoded = Data(base64Encoded: requestData) {
            requestData = base64Decoded
        }

        return try decoder.decode(T.self, from: requestData)
    }
}
