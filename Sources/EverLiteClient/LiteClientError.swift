import Foundation

public enum LiteClientError: Error, Equatable, Sendable, LocalizedError {
    case invalidArgument(String)
    case connectionClosed
    case requestTimedOut
    case server(code: Int32, message: String)
    case invalidResponse(String)

    public var errorDescription: String? {
        switch self {
        case .invalidArgument(let message), .invalidResponse(let message): return message
        case .connectionClosed: return "The lite server connection is closed. Create a new LiteClient to reconnect."
        case .requestTimedOut: return "The lite server request timed out."
        case .server(let code, let message): return "Lite server error \(code): \(message)"
        }
    }
}
