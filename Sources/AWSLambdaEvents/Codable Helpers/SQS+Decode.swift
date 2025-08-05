#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public extension SQSEvent {
    /// Decodes the records included in the event into an array of decodable objects.
    ///
    /// - Parameters:
    ///   - type: The type to decode the body into.
    ///   - decoder: The decoder to use. Defaults to a new `JSONDecoder`.
    ///
    /// - Returns: The decoded records as `[T]`.
    /// - Throws: An error if any of the records cannot be decoded.
    func decodeBody<T>(
        _ type: T.Type,
        using decoder: JSONDecoder = JSONDecoder()
    ) throws -> [T] where T: Decodable {
        try records.map {
            try $0.decodeBody(type, using: decoder)
        }
    }
}

public extension SQSEvent.Message {
    /// Decodes the body of the message into a decodable object.
    ///
    /// - Parameters:
    ///   - type: The type to decode the body into.
    ///   - decoder: The decoder to use. Defaults to a new `JSONDecoder`.
    ///
    /// - Returns: The decoded body as `T`.
    /// - Throws: An error if the body cannot be decoded.
    func decodeBody<T>(
        _ type: T.Type,
        using decoder: JSONDecoder = JSONDecoder()
    ) throws -> T where T: Decodable {
        try decoder.decode(T.self, from: body.data(using: .utf8) ?? Data())
    }
}