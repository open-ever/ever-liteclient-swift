import Foundation
import adnl_swift

public struct LiteServer: Equatable, Sendable {
    public let host: String
    public let port: Int
    public let publicKey: Data

    public init(host: String, port: Int, publicKey: Data) throws {
        let host = host.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !host.isEmpty, (1...65535).contains(port) else {
            throw LiteClientError.invalidArgument("A host and a port between 1 and 65535 are required.")
        }
        self.host = host
        self.port = port
        self.publicKey = try ADNLAddress(publicKey: publicKey).publicKey
    }

    public init(host: String, port: Int, publicKey: String) throws {
        try self.init(host: host, port: port,
                      publicKey: ADNLAddress(publicKey: publicKey.trimmingCharacters(in: .whitespacesAndNewlines)).publicKey)
    }
}
