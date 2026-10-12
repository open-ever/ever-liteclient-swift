import Foundation
import EverLiteClientTL

public struct MessageSubmission: Equatable, Sendable {
    public let status: Int32
    public var isAccepted: Bool { status == 1 }
}

public struct AccountState: Equatable, Sendable {
    public let block: BlockID
    public let shardBlock: BlockID
    public let shardProof: BagOfCells
    public let proof: BagOfCells
    public let state: BagOfCells

    init(_ value: LiteServerAccountStateConstructor) {
        block = BlockID(tl: value.id)
        shardBlock = BlockID(tl: value.shardblk)
        shardProof = BagOfCells(value.shard_proof)
        proof = BagOfCells(value.proof)
        state = BagOfCells(value.state)
    }
}

public struct RunMethodOptions: OptionSet, Hashable, Sendable {
    public let rawValue: UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }

    public static let accountProofs = Self(rawValue: 1 << 0)
    public static let stateProof = Self(rawValue: 1 << 1)
    public static let result = Self(rawValue: 1 << 2)
    public static let initialContext = Self(rawValue: 1 << 3)
    public static let libraryExtras = Self(rawValue: 1 << 4)
}

public struct RunMethodResult: Equatable, Sendable {
    public let options: RunMethodOptions
    public let block: BlockID
    public let shardBlock: BlockID
    public let exitCode: Int32
    public let result: BagOfCells?
    public let shardProof: BagOfCells?
    public let proof: BagOfCells?
    public let stateProof: BagOfCells?
    public let initialContext: BagOfCells?
    public let libraryExtras: BagOfCells?

    public var isSuccessful: Bool { exitCode == 0 || exitCode == 1 }

    init(_ value: LiteServerRunMethodResultConstructor) {
        options = RunMethodOptions(rawValue: value.mode)
        block = BlockID(tl: value.id)
        shardBlock = BlockID(tl: value.shardblk)
        exitCode = value.exit_code
        result = value.result.map(BagOfCells.init)
        shardProof = value.shard_proof.map(BagOfCells.init)
        proof = value.proof.map(BagOfCells.init)
        stateProof = value.state_proof.map(BagOfCells.init)
        initialContext = value.init_c7.map(BagOfCells.init)
        libraryExtras = value.lib_extras.map(BagOfCells.init)
    }
}

public struct TransactionInfo: Equatable, Sendable {
    public let block: BlockID
    public let proof: BagOfCells
    public let transaction: BagOfCells

    init(_ value: LiteServerTransactionInfoConstructor) {
        block = BlockID(tl: value.id)
        proof = BagOfCells(value.proof)
        transaction = BagOfCells(value.transaction)
    }
}

public struct TransactionList: Equatable, Sendable {
    public let blocks: [BlockID]
    public let transactions: BagOfCells

    init(_ value: LiteServerTransactionListConstructor) {
        blocks = value.ids.map(BlockID.init(tl:))
        transactions = BagOfCells(value.transactions)
    }
}
