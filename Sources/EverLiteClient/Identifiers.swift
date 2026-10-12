import Foundation
import EverTL
import EverLiteClientTL
import EverscaleSdkSwift
import SwiftExtensionsPack

public struct Hash256: Hashable, Sendable, CustomStringConvertible {
    public let data: Data

    public init(_ data: Data) throws {
        guard data.count == 32 else {
            throw LiteClientError.invalidArgument("A 256-bit hash must contain exactly 32 bytes.")
        }
        self.data = Data(data)
    }

    public init(hex: String) throws {
        let text = hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex
        guard text.utf8.count == 64, let data = Data(hexString: text) else {
            throw LiteClientError.invalidArgument("A 256-bit hash must contain 64 hexadecimal digits.")
        }
        try self.init(data)
    }

    public static let zero = Self(tl: TLBytes256())
    public var hex: String { data.toHexadecimal }
    public var description: String { hex }

    init(tl: TLBytes256) { data = tl.data }
    var tl: TLBytes256 { get throws { try TLBytes256(data) } }
}

public struct AccountID: Hashable, Sendable, CustomStringConvertible {
    public let workchain: Int32
    public let hash: Hash256

    public init(workchain: Int32, hash: Hash256) {
        self.workchain = workchain
        self.hash = hash
    }

    public init(_ rawAddress: String) throws {
        let parts = rawAddress.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ":", omittingEmptySubsequences: false)
        guard parts.count == 2, let workchain = Int32(parts[0]) else {
            throw LiteClientError.invalidArgument("An account address must use workchain:hex format.")
        }
        self.init(workchain: workchain, hash: try Hash256(hex: String(parts[1])))
    }

    public init(_ address: Address) throws {
        self.init(workchain: Int32(address.workchain), hash: try Hash256(address.hash))
    }

    public var description: String { "\(workchain):\(hash.hex)" }
    var tl: LiteServerAccountIdConstructor {
        get throws { try .init(workchain: workchain, id: hash.tl) }
    }
}

public struct BlockID: Hashable, Sendable {
    public static let fullShard: UInt64 = 0x8000_0000_0000_0000

    /// Selects the latest applied masterchain block for getAccountState and runMethod.
    /// Compatible lite servers return the resolved block ID in the response.
    public static let latest = Self(
        workchain: -1,
        shard: fullShard,
        sequenceNumber: .max,
        rootHash: .zero,
        fileHash: .zero
    )

    public let workchain: Int32
    public let shard: UInt64
    public let sequenceNumber: UInt32
    public let rootHash: Hash256
    public let fileHash: Hash256

    public init(
        workchain: Int32,
        shard: UInt64 = Self.fullShard,
        sequenceNumber: UInt32,
        rootHash: Hash256,
        fileHash: Hash256
    ) {
        self.workchain = workchain
        self.shard = shard
        self.sequenceNumber = sequenceNumber
        self.rootHash = rootHash
        self.fileHash = fileHash
    }

    init(tl: TonNodeBlockIdExtConstructor) {
        self.init(workchain: tl.workchain, shard: UInt64(bitPattern: tl.shard),
                  sequenceNumber: UInt32(bitPattern: tl.seqno),
                  rootHash: Hash256(tl: tl.root_hash), fileHash: Hash256(tl: tl.file_hash))
    }

    var tl: TonNodeBlockIdExtConstructor {
        get throws {
            try .init(workchain: workchain, shard: Int64(bitPattern: shard),
                      seqno: Int32(bitPattern: sequenceNumber), root_hash: rootHash.tl, file_hash: fileHash.tl)
        }
    }
}

public struct TransactionID: Hashable, Sendable {
    public let logicalTime: UInt64
    public let hash: Hash256

    public init(logicalTime: UInt64, hash: Hash256) {
        self.logicalTime = logicalTime
        self.hash = hash
    }
}
