// Generated from a TL schema. Do not edit manually.

import Foundation

import EverTL

public struct AdnlMessageAnswerConstructor: TLConstructor, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0x0fac8416 }
    public var query_id: TLBytes256
    public var answer: Foundation.Data

    public init(query_id _tlArgument0: TLBytes256, answer _tlArgument1: Foundation.Data) {
        self.query_id = _tlArgument0
        self.answer = _tlArgument1
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(TLBytes256.self, boxed: false)
        let _tlField1 = try reader.read(Foundation.Data.self, boxed: false)
        return Self(query_id: _tlField0, answer: _tlField1)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.write(self.query_id, boxed: false)
        try writer.write(self.answer, boxed: false)
    }
}

public struct AdnlMessageQueryConstructor: TLConstructor, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0xb48bf97a }
    public var query_id: TLBytes256
    public var query: Foundation.Data

    public init(query_id _tlArgument0: TLBytes256, query _tlArgument1: Foundation.Data) {
        self.query_id = _tlArgument0
        self.query = _tlArgument1
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(TLBytes256.self, boxed: false)
        let _tlField1 = try reader.read(Foundation.Data.self, boxed: false)
        return Self(query_id: _tlField0, query: _tlField1)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.write(self.query_id, boxed: false)
        try writer.write(self.query, boxed: false)
    }
}

public struct LiteServerAccountIdConstructor: TLConstructor, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0x75a0e2c5 }
    public var workchain: Swift.Int32
    public var id: TLBytes256

    public init(workchain _tlArgument0: Swift.Int32, id _tlArgument1: TLBytes256) {
        self.workchain = _tlArgument0
        self.id = _tlArgument1
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(Swift.Int32.self, boxed: false)
        let _tlField1 = try reader.read(TLBytes256.self, boxed: false)
        return Self(workchain: _tlField0, id: _tlField1)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.write(self.workchain, boxed: false)
        try writer.write(self.id, boxed: false)
    }
}

public struct LiteServerAccountStateConstructor: TLConstructor, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0x7079c751 }
    public var id: TonNodeBlockIdExtConstructor
    public var shardblk: TonNodeBlockIdExtConstructor
    public var shard_proof: Foundation.Data
    public var proof: Foundation.Data
    public var state: Foundation.Data

    public init(id _tlArgument0: TonNodeBlockIdExtConstructor, shardblk _tlArgument1: TonNodeBlockIdExtConstructor, shard_proof _tlArgument2: Foundation.Data, proof _tlArgument3: Foundation.Data, state _tlArgument4: Foundation.Data) {
        self.id = _tlArgument0
        self.shardblk = _tlArgument1
        self.shard_proof = _tlArgument2
        self.proof = _tlArgument3
        self.state = _tlArgument4
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(TonNodeBlockIdExtConstructor.self, boxed: false)
        let _tlField1 = try reader.read(TonNodeBlockIdExtConstructor.self, boxed: false)
        let _tlField2 = try reader.read(Foundation.Data.self, boxed: false)
        let _tlField3 = try reader.read(Foundation.Data.self, boxed: false)
        let _tlField4 = try reader.read(Foundation.Data.self, boxed: false)
        return Self(id: _tlField0, shardblk: _tlField1, shard_proof: _tlField2, proof: _tlField3, state: _tlField4)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.write(self.id, boxed: false)
        try writer.write(self.shardblk, boxed: false)
        try writer.write(self.shard_proof, boxed: false)
        try writer.write(self.proof, boxed: false)
        try writer.write(self.state, boxed: false)
    }
}

public struct LiteServerErrorConstructor: TLConstructor, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0xbba9e148 }
    public var code: Swift.Int32
    public var message: Swift.String

    public init(code _tlArgument0: Swift.Int32, message _tlArgument1: Swift.String) {
        self.code = _tlArgument0
        self.message = _tlArgument1
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(Swift.Int32.self, boxed: false)
        let _tlField1 = try reader.read(Swift.String.self, boxed: false)
        return Self(code: _tlField0, message: _tlField1)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.write(self.code, boxed: false)
        try writer.write(self.message, boxed: false)
    }
}

public struct LiteServerGetAccountStateRequest: TLConstructor, TLFunction, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0x6b890e25 }
    public typealias Reply = LiteServerAccountState
    public static var replyBoxed: Swift.Bool { true }
    public var id: TonNodeBlockIdExtConstructor
    public var account: LiteServerAccountIdConstructor

    public init(id _tlArgument0: TonNodeBlockIdExtConstructor, account _tlArgument1: LiteServerAccountIdConstructor) {
        self.id = _tlArgument0
        self.account = _tlArgument1
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(TonNodeBlockIdExtConstructor.self, boxed: false)
        let _tlField1 = try reader.read(LiteServerAccountIdConstructor.self, boxed: false)
        return Self(id: _tlField0, account: _tlField1)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.write(self.id, boxed: false)
        try writer.write(self.account, boxed: false)
    }
}

public struct LiteServerGetOneTransactionRequest: TLConstructor, TLFunction, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0xd40f24ea }
    public typealias Reply = LiteServerTransactionInfo
    public static var replyBoxed: Swift.Bool { true }
    public var id: TonNodeBlockIdExtConstructor
    public var account: LiteServerAccountIdConstructor
    public var lt: Swift.Int64

    public init(id _tlArgument0: TonNodeBlockIdExtConstructor, account _tlArgument1: LiteServerAccountIdConstructor, lt _tlArgument2: Swift.Int64) {
        self.id = _tlArgument0
        self.account = _tlArgument1
        self.lt = _tlArgument2
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(TonNodeBlockIdExtConstructor.self, boxed: false)
        let _tlField1 = try reader.read(LiteServerAccountIdConstructor.self, boxed: false)
        let _tlField2 = try reader.read(Swift.Int64.self, boxed: false)
        return Self(id: _tlField0, account: _tlField1, lt: _tlField2)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.write(self.id, boxed: false)
        try writer.write(self.account, boxed: false)
        try writer.write(self.lt, boxed: false)
    }
}

public struct LiteServerGetTransactionsRequest: TLConstructor, TLFunction, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0x1c40e7a1 }
    public typealias Reply = LiteServerTransactionList
    public static var replyBoxed: Swift.Bool { true }
    public var count: Swift.UInt32
    public var account: LiteServerAccountIdConstructor
    public var lt: Swift.Int64
    public var hash: TLBytes256

    public init(count _tlArgument0: Swift.UInt32, account _tlArgument1: LiteServerAccountIdConstructor, lt _tlArgument2: Swift.Int64, hash _tlArgument3: TLBytes256) {
        self.count = _tlArgument0
        self.account = _tlArgument1
        self.lt = _tlArgument2
        self.hash = _tlArgument3
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(Swift.UInt32.self, boxed: false)
        let _tlField1 = try reader.read(LiteServerAccountIdConstructor.self, boxed: false)
        let _tlField2 = try reader.read(Swift.Int64.self, boxed: false)
        let _tlField3 = try reader.read(TLBytes256.self, boxed: false)
        return Self(count: _tlField0, account: _tlField1, lt: _tlField2, hash: _tlField3)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.write(self.count, boxed: false)
        try writer.write(self.account, boxed: false)
        try writer.write(self.lt, boxed: false)
        try writer.write(self.hash, boxed: false)
    }
}

public struct LiteServerQueryRequest: TLConstructor, TLFunction, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0x798c06df }
    public typealias Reply = TLObject
    public static var replyBoxed: Swift.Bool { true }
    public var data: Foundation.Data

    public init(data _tlArgument0: Foundation.Data) {
        self.data = _tlArgument0
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(Foundation.Data.self, boxed: false)
        return Self(data: _tlField0)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.write(self.data, boxed: false)
    }
}

public struct LiteServerRunMethodResultConstructor: TLConstructor, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0xa39a616b }
    public var mode: Swift.UInt32
    public var id: TonNodeBlockIdExtConstructor
    public var shardblk: TonNodeBlockIdExtConstructor
    public var shard_proof: Foundation.Data?
    public var proof: Foundation.Data?
    public var state_proof: Foundation.Data?
    public var init_c7: Foundation.Data?
    public var lib_extras: Foundation.Data?
    public var exit_code: Swift.Int32
    public var result: Foundation.Data?

    public init(mode _tlArgument0: Swift.UInt32 = 0, id _tlArgument1: TonNodeBlockIdExtConstructor, shardblk _tlArgument2: TonNodeBlockIdExtConstructor, shard_proof _tlArgument3: Foundation.Data? = nil, proof _tlArgument4: Foundation.Data? = nil, state_proof _tlArgument5: Foundation.Data? = nil, init_c7 _tlArgument6: Foundation.Data? = nil, lib_extras _tlArgument7: Foundation.Data? = nil, exit_code _tlArgument8: Swift.Int32, result _tlArgument9: Foundation.Data? = nil) {
        self.mode = _tlArgument0
        self.id = _tlArgument1
        self.shardblk = _tlArgument2
        self.shard_proof = _tlArgument3
        self.proof = _tlArgument4
        self.state_proof = _tlArgument5
        self.init_c7 = _tlArgument6
        self.lib_extras = _tlArgument7
        self.exit_code = _tlArgument8
        self.result = _tlArgument9
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(Swift.UInt32.self, boxed: false)
        let _tlField1 = try reader.read(TonNodeBlockIdExtConstructor.self, boxed: false)
        let _tlField2 = try reader.read(TonNodeBlockIdExtConstructor.self, boxed: false)
        let _tlField3: Foundation.Data? = (_tlField0 & (Swift.UInt32(1) << 0)) != 0 ? try reader.read(Foundation.Data.self, boxed: false) : nil
        let _tlField4: Foundation.Data? = (_tlField0 & (Swift.UInt32(1) << 0)) != 0 ? try reader.read(Foundation.Data.self, boxed: false) : nil
        let _tlField5: Foundation.Data? = (_tlField0 & (Swift.UInt32(1) << 1)) != 0 ? try reader.read(Foundation.Data.self, boxed: false) : nil
        let _tlField6: Foundation.Data? = (_tlField0 & (Swift.UInt32(1) << 3)) != 0 ? try reader.read(Foundation.Data.self, boxed: false) : nil
        let _tlField7: Foundation.Data? = (_tlField0 & (Swift.UInt32(1) << 4)) != 0 ? try reader.read(Foundation.Data.self, boxed: false) : nil
        let _tlField8 = try reader.read(Swift.Int32.self, boxed: false)
        let _tlField9: Foundation.Data? = (_tlField0 & (Swift.UInt32(1) << 2)) != 0 ? try reader.read(Foundation.Data.self, boxed: false) : nil
        return Self(mode: _tlField0, id: _tlField1, shardblk: _tlField2, shard_proof: _tlField3, proof: _tlField4, state_proof: _tlField5, init_c7: _tlField6, lib_extras: _tlField7, exit_code: _tlField8, result: _tlField9)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        var _tlMask0 = self.mode
        guard (self.shard_proof != nil) == (self.proof != nil) else {
            throw TLCodecError.inconsistentFlags("liteServer.runMethodResult: mode.0 requires shard_proof, proof to be present together")
        }
        if self.shard_proof != nil { _tlMask0 |= (Swift.UInt32(1) << 0) } else { _tlMask0 &= ~(Swift.UInt32(1) << 0) }
        if self.state_proof != nil { _tlMask0 |= (Swift.UInt32(1) << 1) } else { _tlMask0 &= ~(Swift.UInt32(1) << 1) }
        if self.result != nil { _tlMask0 |= (Swift.UInt32(1) << 2) } else { _tlMask0 &= ~(Swift.UInt32(1) << 2) }
        if self.init_c7 != nil { _tlMask0 |= (Swift.UInt32(1) << 3) } else { _tlMask0 &= ~(Swift.UInt32(1) << 3) }
        if self.lib_extras != nil { _tlMask0 |= (Swift.UInt32(1) << 4) } else { _tlMask0 &= ~(Swift.UInt32(1) << 4) }
        try writer.write(_tlMask0, boxed: false)
        try writer.write(self.id, boxed: false)
        try writer.write(self.shardblk, boxed: false)
        if let _tlValue3 = self.shard_proof {
            try writer.write(_tlValue3, boxed: false)
        }
        if let _tlValue4 = self.proof {
            try writer.write(_tlValue4, boxed: false)
        }
        if let _tlValue5 = self.state_proof {
            try writer.write(_tlValue5, boxed: false)
        }
        if let _tlValue6 = self.init_c7 {
            try writer.write(_tlValue6, boxed: false)
        }
        if let _tlValue7 = self.lib_extras {
            try writer.write(_tlValue7, boxed: false)
        }
        try writer.write(self.exit_code, boxed: false)
        if let _tlValue9 = self.result {
            try writer.write(_tlValue9, boxed: false)
        }
    }
}

public struct LiteServerRunSmcMethodRequest: TLConstructor, TLFunction, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0x5cc65dd2 }
    public typealias Reply = LiteServerRunMethodResult
    public static var replyBoxed: Swift.Bool { true }
    public var mode: Swift.UInt32
    public var id: TonNodeBlockIdExtConstructor
    public var account: LiteServerAccountIdConstructor
    public var method_id: Swift.Int64
    public var params: Foundation.Data

    public init(mode _tlArgument0: Swift.UInt32, id _tlArgument1: TonNodeBlockIdExtConstructor, account _tlArgument2: LiteServerAccountIdConstructor, method_id _tlArgument3: Swift.Int64, params _tlArgument4: Foundation.Data) {
        self.mode = _tlArgument0
        self.id = _tlArgument1
        self.account = _tlArgument2
        self.method_id = _tlArgument3
        self.params = _tlArgument4
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(Swift.UInt32.self, boxed: false)
        let _tlField1 = try reader.read(TonNodeBlockIdExtConstructor.self, boxed: false)
        let _tlField2 = try reader.read(LiteServerAccountIdConstructor.self, boxed: false)
        let _tlField3 = try reader.read(Swift.Int64.self, boxed: false)
        let _tlField4 = try reader.read(Foundation.Data.self, boxed: false)
        return Self(mode: _tlField0, id: _tlField1, account: _tlField2, method_id: _tlField3, params: _tlField4)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.write(self.mode, boxed: false)
        try writer.write(self.id, boxed: false)
        try writer.write(self.account, boxed: false)
        try writer.write(self.method_id, boxed: false)
        try writer.write(self.params, boxed: false)
    }
}

public struct LiteServerSendMessageRequest: TLConstructor, TLFunction, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0x690ad482 }
    public typealias Reply = LiteServerSendMsgStatus
    public static var replyBoxed: Swift.Bool { true }
    public var body: Foundation.Data

    public init(body _tlArgument0: Foundation.Data) {
        self.body = _tlArgument0
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(Foundation.Data.self, boxed: false)
        return Self(body: _tlField0)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.write(self.body, boxed: false)
    }
}

public struct LiteServerSendMsgStatusConstructor: TLConstructor, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0x3950e597 }
    public var status: Swift.Int32

    public init(status _tlArgument0: Swift.Int32) {
        self.status = _tlArgument0
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(Swift.Int32.self, boxed: false)
        return Self(status: _tlField0)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.write(self.status, boxed: false)
    }
}

public struct LiteServerTransactionInfoConstructor: TLConstructor, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0x0edeed47 }
    public var id: TonNodeBlockIdExtConstructor
    public var proof: Foundation.Data
    public var transaction: Foundation.Data

    public init(id _tlArgument0: TonNodeBlockIdExtConstructor, proof _tlArgument1: Foundation.Data, transaction _tlArgument2: Foundation.Data) {
        self.id = _tlArgument0
        self.proof = _tlArgument1
        self.transaction = _tlArgument2
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(TonNodeBlockIdExtConstructor.self, boxed: false)
        let _tlField1 = try reader.read(Foundation.Data.self, boxed: false)
        let _tlField2 = try reader.read(Foundation.Data.self, boxed: false)
        return Self(id: _tlField0, proof: _tlField1, transaction: _tlField2)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.write(self.id, boxed: false)
        try writer.write(self.proof, boxed: false)
        try writer.write(self.transaction, boxed: false)
    }
}

public struct LiteServerTransactionListConstructor: TLConstructor, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0x6f26c60b }
    public var ids: [TonNodeBlockIdExtConstructor]
    public var transactions: Foundation.Data

    public init(ids _tlArgument0: [TonNodeBlockIdExtConstructor], transactions _tlArgument1: Foundation.Data) {
        self.ids = _tlArgument0
        self.transactions = _tlArgument1
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.readVector(TonNodeBlockIdExtConstructor.self, elementBoxed: false)
        let _tlField1 = try reader.read(Foundation.Data.self, boxed: false)
        return Self(ids: _tlField0, transactions: _tlField1)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.writeVector(self.ids, elementBoxed: false)
        try writer.write(self.transactions, boxed: false)
    }
}

public struct TcpPingRequest: TLConstructor, TLFunction, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0x4d082b9a }
    public typealias Reply = TcpPong
    public static var replyBoxed: Swift.Bool { true }
    public var random_id: Swift.Int64

    public init(random_id _tlArgument0: Swift.Int64) {
        self.random_id = _tlArgument0
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(Swift.Int64.self, boxed: false)
        return Self(random_id: _tlField0)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.write(self.random_id, boxed: false)
    }
}

public struct TcpPongConstructor: TLConstructor, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0xdc69fb03 }
    public var random_id: Swift.Int64

    public init(random_id _tlArgument0: Swift.Int64) {
        self.random_id = _tlArgument0
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(Swift.Int64.self, boxed: false)
        return Self(random_id: _tlField0)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.write(self.random_id, boxed: false)
    }
}

public struct TonNodeBlockIdExtConstructor: TLConstructor, Equatable, Sendable {
    public static var constructorID: Swift.UInt32 { 0x6752eb78 }
    public var workchain: Swift.Int32
    public var shard: Swift.Int64
    public var seqno: Swift.Int32
    public var root_hash: TLBytes256
    public var file_hash: TLBytes256

    public init(workchain _tlArgument0: Swift.Int32, shard _tlArgument1: Swift.Int64, seqno _tlArgument2: Swift.Int32, root_hash _tlArgument3: TLBytes256, file_hash _tlArgument4: TLBytes256) {
        self.workchain = _tlArgument0
        self.shard = _tlArgument1
        self.seqno = _tlArgument2
        self.root_hash = _tlArgument3
        self.file_hash = _tlArgument4
    }

    public static func readBare(from reader: inout TLReader) throws -> Self {
        let _tlField0 = try reader.read(Swift.Int32.self, boxed: false)
        let _tlField1 = try reader.read(Swift.Int64.self, boxed: false)
        let _tlField2 = try reader.read(Swift.Int32.self, boxed: false)
        let _tlField3 = try reader.read(TLBytes256.self, boxed: false)
        let _tlField4 = try reader.read(TLBytes256.self, boxed: false)
        return Self(workchain: _tlField0, shard: _tlField1, seqno: _tlField2, root_hash: _tlField3, file_hash: _tlField4)
    }

    public func writeBare(to writer: inout TLWriter) throws {
        try writer.write(self.workchain, boxed: false)
        try writer.write(self.shard, boxed: false)
        try writer.write(self.seqno, boxed: false)
        try writer.write(self.root_hash, boxed: false)
        try writer.write(self.file_hash, boxed: false)
    }
}

public indirect enum AdnlMessage: TLBoxedSerializable, Equatable, Sendable {
    case adnlMessageAnswer(AdnlMessageAnswerConstructor)
    case adnlMessageQuery(AdnlMessageQueryConstructor)

    public static func read(from reader: inout TLReader, boxed: Swift.Bool) throws -> Self {
        guard boxed else { throw TLCodecError.unsupported("adnl.message requires a constructor identifier") }
        let _tlID = try reader.read(Swift.UInt32.self, boxed: false)
        switch _tlID {
        case 0x0fac8416: return .adnlMessageAnswer(try AdnlMessageAnswerConstructor.readBare(from: &reader))
        case 0xb48bf97a: return .adnlMessageQuery(try AdnlMessageQueryConstructor.readBare(from: &reader))
        default: throw TLCodecError.unknownConstructor(_tlID)
        }
    }

    public func write(to writer: inout TLWriter, boxed: Swift.Bool) throws {
        guard boxed else { throw TLCodecError.unsupported("adnl.message requires a constructor identifier") }
        switch self {
        case .adnlMessageAnswer(let _tlValue): try _tlValue.write(to: &writer, boxed: true)
        case .adnlMessageQuery(let _tlValue): try _tlValue.write(to: &writer, boxed: true)
        }
    }
}

public indirect enum LiteServerAccountId: TLBoxedSerializable, Equatable, Sendable {
    case liteServerAccountId(LiteServerAccountIdConstructor)

    public static func read(from reader: inout TLReader, boxed: Swift.Bool) throws -> Self {
        guard boxed else { throw TLCodecError.unsupported("liteServer.accountId requires a constructor identifier") }
        let _tlID = try reader.read(Swift.UInt32.self, boxed: false)
        switch _tlID {
        case 0x75a0e2c5: return .liteServerAccountId(try LiteServerAccountIdConstructor.readBare(from: &reader))
        default: throw TLCodecError.unknownConstructor(_tlID)
        }
    }

    public func write(to writer: inout TLWriter, boxed: Swift.Bool) throws {
        guard boxed else { throw TLCodecError.unsupported("liteServer.accountId requires a constructor identifier") }
        switch self {
        case .liteServerAccountId(let _tlValue): try _tlValue.write(to: &writer, boxed: true)
        }
    }
}

public indirect enum LiteServerAccountState: TLBoxedSerializable, Equatable, Sendable {
    case liteServerAccountState(LiteServerAccountStateConstructor)

    public static func read(from reader: inout TLReader, boxed: Swift.Bool) throws -> Self {
        guard boxed else { throw TLCodecError.unsupported("liteServer.accountState requires a constructor identifier") }
        let _tlID = try reader.read(Swift.UInt32.self, boxed: false)
        switch _tlID {
        case 0x7079c751: return .liteServerAccountState(try LiteServerAccountStateConstructor.readBare(from: &reader))
        default: throw TLCodecError.unknownConstructor(_tlID)
        }
    }

    public func write(to writer: inout TLWriter, boxed: Swift.Bool) throws {
        guard boxed else { throw TLCodecError.unsupported("liteServer.accountState requires a constructor identifier") }
        switch self {
        case .liteServerAccountState(let _tlValue): try _tlValue.write(to: &writer, boxed: true)
        }
    }
}

public indirect enum LiteServerError: TLBoxedSerializable, Equatable, Sendable {
    case liteServerError(LiteServerErrorConstructor)

    public static func read(from reader: inout TLReader, boxed: Swift.Bool) throws -> Self {
        guard boxed else { throw TLCodecError.unsupported("liteServer.error requires a constructor identifier") }
        let _tlID = try reader.read(Swift.UInt32.self, boxed: false)
        switch _tlID {
        case 0xbba9e148: return .liteServerError(try LiteServerErrorConstructor.readBare(from: &reader))
        default: throw TLCodecError.unknownConstructor(_tlID)
        }
    }

    public func write(to writer: inout TLWriter, boxed: Swift.Bool) throws {
        guard boxed else { throw TLCodecError.unsupported("liteServer.error requires a constructor identifier") }
        switch self {
        case .liteServerError(let _tlValue): try _tlValue.write(to: &writer, boxed: true)
        }
    }
}

public indirect enum LiteServerRunMethodResult: TLBoxedSerializable, Equatable, Sendable {
    case liteServerRunMethodResult(LiteServerRunMethodResultConstructor)

    public static func read(from reader: inout TLReader, boxed: Swift.Bool) throws -> Self {
        guard boxed else { throw TLCodecError.unsupported("liteServer.runMethodResult requires a constructor identifier") }
        let _tlID = try reader.read(Swift.UInt32.self, boxed: false)
        switch _tlID {
        case 0xa39a616b: return .liteServerRunMethodResult(try LiteServerRunMethodResultConstructor.readBare(from: &reader))
        default: throw TLCodecError.unknownConstructor(_tlID)
        }
    }

    public func write(to writer: inout TLWriter, boxed: Swift.Bool) throws {
        guard boxed else { throw TLCodecError.unsupported("liteServer.runMethodResult requires a constructor identifier") }
        switch self {
        case .liteServerRunMethodResult(let _tlValue): try _tlValue.write(to: &writer, boxed: true)
        }
    }
}

public indirect enum LiteServerSendMsgStatus: TLBoxedSerializable, Equatable, Sendable {
    case liteServerSendMsgStatus(LiteServerSendMsgStatusConstructor)

    public static func read(from reader: inout TLReader, boxed: Swift.Bool) throws -> Self {
        guard boxed else { throw TLCodecError.unsupported("liteServer.sendMsgStatus requires a constructor identifier") }
        let _tlID = try reader.read(Swift.UInt32.self, boxed: false)
        switch _tlID {
        case 0x3950e597: return .liteServerSendMsgStatus(try LiteServerSendMsgStatusConstructor.readBare(from: &reader))
        default: throw TLCodecError.unknownConstructor(_tlID)
        }
    }

    public func write(to writer: inout TLWriter, boxed: Swift.Bool) throws {
        guard boxed else { throw TLCodecError.unsupported("liteServer.sendMsgStatus requires a constructor identifier") }
        switch self {
        case .liteServerSendMsgStatus(let _tlValue): try _tlValue.write(to: &writer, boxed: true)
        }
    }
}

public indirect enum LiteServerTransactionInfo: TLBoxedSerializable, Equatable, Sendable {
    case liteServerTransactionInfo(LiteServerTransactionInfoConstructor)

    public static func read(from reader: inout TLReader, boxed: Swift.Bool) throws -> Self {
        guard boxed else { throw TLCodecError.unsupported("liteServer.transactionInfo requires a constructor identifier") }
        let _tlID = try reader.read(Swift.UInt32.self, boxed: false)
        switch _tlID {
        case 0x0edeed47: return .liteServerTransactionInfo(try LiteServerTransactionInfoConstructor.readBare(from: &reader))
        default: throw TLCodecError.unknownConstructor(_tlID)
        }
    }

    public func write(to writer: inout TLWriter, boxed: Swift.Bool) throws {
        guard boxed else { throw TLCodecError.unsupported("liteServer.transactionInfo requires a constructor identifier") }
        switch self {
        case .liteServerTransactionInfo(let _tlValue): try _tlValue.write(to: &writer, boxed: true)
        }
    }
}

public indirect enum LiteServerTransactionList: TLBoxedSerializable, Equatable, Sendable {
    case liteServerTransactionList(LiteServerTransactionListConstructor)

    public static func read(from reader: inout TLReader, boxed: Swift.Bool) throws -> Self {
        guard boxed else { throw TLCodecError.unsupported("liteServer.transactionList requires a constructor identifier") }
        let _tlID = try reader.read(Swift.UInt32.self, boxed: false)
        switch _tlID {
        case 0x6f26c60b: return .liteServerTransactionList(try LiteServerTransactionListConstructor.readBare(from: &reader))
        default: throw TLCodecError.unknownConstructor(_tlID)
        }
    }

    public func write(to writer: inout TLWriter, boxed: Swift.Bool) throws {
        guard boxed else { throw TLCodecError.unsupported("liteServer.transactionList requires a constructor identifier") }
        switch self {
        case .liteServerTransactionList(let _tlValue): try _tlValue.write(to: &writer, boxed: true)
        }
    }
}

public indirect enum TcpPong: TLBoxedSerializable, Equatable, Sendable {
    case tcpPong(TcpPongConstructor)

    public static func read(from reader: inout TLReader, boxed: Swift.Bool) throws -> Self {
        guard boxed else { throw TLCodecError.unsupported("tcp.pong requires a constructor identifier") }
        let _tlID = try reader.read(Swift.UInt32.self, boxed: false)
        switch _tlID {
        case 0xdc69fb03: return .tcpPong(try TcpPongConstructor.readBare(from: &reader))
        default: throw TLCodecError.unknownConstructor(_tlID)
        }
    }

    public func write(to writer: inout TLWriter, boxed: Swift.Bool) throws {
        guard boxed else { throw TLCodecError.unsupported("tcp.pong requires a constructor identifier") }
        switch self {
        case .tcpPong(let _tlValue): try _tlValue.write(to: &writer, boxed: true)
        }
    }
}

public indirect enum TonNodeBlockIdExt: TLBoxedSerializable, Equatable, Sendable {
    case tonNodeBlockIdExt(TonNodeBlockIdExtConstructor)

    public static func read(from reader: inout TLReader, boxed: Swift.Bool) throws -> Self {
        guard boxed else { throw TLCodecError.unsupported("tonNode.blockIdExt requires a constructor identifier") }
        let _tlID = try reader.read(Swift.UInt32.self, boxed: false)
        switch _tlID {
        case 0x6752eb78: return .tonNodeBlockIdExt(try TonNodeBlockIdExtConstructor.readBare(from: &reader))
        default: throw TLCodecError.unknownConstructor(_tlID)
        }
    }

    public func write(to writer: inout TLWriter, boxed: Swift.Bool) throws {
        guard boxed else { throw TLCodecError.unsupported("tonNode.blockIdExt requires a constructor identifier") }
        switch self {
        case .tonNodeBlockIdExt(let _tlValue): try _tlValue.write(to: &writer, boxed: true)
        }
    }
}

public enum EverTLSchema {
    public static let layer: Swift.UInt32? = nil
    public static let constructorCount: Swift.Int = 18
    public static func makeRegistry() throws -> TLRegistry {
        var registry = TLRegistry()
        try registry.register(AdnlMessageAnswerConstructor.self, id: 0x0fac8416, name: "adnl.message.answer")
        try registry.register(AdnlMessageQueryConstructor.self, id: 0xb48bf97a, name: "adnl.message.query")
        try registry.register(LiteServerAccountIdConstructor.self, id: 0x75a0e2c5, name: "liteServer.accountId")
        try registry.register(LiteServerAccountStateConstructor.self, id: 0x7079c751, name: "liteServer.accountState")
        try registry.register(LiteServerErrorConstructor.self, id: 0xbba9e148, name: "liteServer.error")
        try registry.register(LiteServerGetAccountStateRequest.self, id: 0x6b890e25, name: "liteServer.getAccountState")
        try registry.register(LiteServerGetOneTransactionRequest.self, id: 0xd40f24ea, name: "liteServer.getOneTransaction")
        try registry.register(LiteServerGetTransactionsRequest.self, id: 0x1c40e7a1, name: "liteServer.getTransactions")
        try registry.register(LiteServerQueryRequest.self, id: 0x798c06df, name: "liteServer.query")
        try registry.register(LiteServerRunMethodResultConstructor.self, id: 0xa39a616b, name: "liteServer.runMethodResult")
        try registry.register(LiteServerRunSmcMethodRequest.self, id: 0x5cc65dd2, name: "liteServer.runSmcMethod")
        try registry.register(LiteServerSendMessageRequest.self, id: 0x690ad482, name: "liteServer.sendMessage")
        try registry.register(LiteServerSendMsgStatusConstructor.self, id: 0x3950e597, name: "liteServer.sendMsgStatus")
        try registry.register(LiteServerTransactionInfoConstructor.self, id: 0x0edeed47, name: "liteServer.transactionInfo")
        try registry.register(LiteServerTransactionListConstructor.self, id: 0x6f26c60b, name: "liteServer.transactionList")
        try registry.register(TcpPingRequest.self, id: 0x4d082b9a, name: "tcp.ping")
        try registry.register(TcpPongConstructor.self, id: 0xdc69fb03, name: "tcp.pong")
        try registry.register(TonNodeBlockIdExtConstructor.self, id: 0x6752eb78, name: "tonNode.blockIdExt")
        return registry
    }
}
