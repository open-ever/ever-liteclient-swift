import Foundation
import EverTL
import EverLiteClientTL
import EverscaleSdkSwift
import adnl_swift

public struct LiteClient: Sendable {
    private let connection: LiteConnection
    private let registry: TLRegistry

    public init(
        server: LiteServer,
        connectionTimeout: TimeInterval = 10,
        requestTimeout: TimeInterval = 15,
        maximumPayloadSize: Int = (1 << 24) - 64,
        transport: (any ADNLTransport)? = nil
    ) throws {
        guard requestTimeout.isFinite, requestTimeout > 0, requestTimeout <= 86_400 else {
            throw LiteClientError.invalidArgument("Request timeout must be greater than zero and at most 86400 seconds.")
        }
        let adnl = try ADNLClient(host: server.host, port: server.port, peerPublicKey: server.publicKey,
                                  transport: transport, connectionTimeout: connectionTimeout,
                                  maximumPayloadSize: maximumPayloadSize)
        connection = LiteConnection(adnl: adnl, requestTimeout: requestTimeout,
                                    maximumPayloadSize: maximumPayloadSize)
        registry = try EverTLSchema.makeRegistry()
    }

    init(connection: LiteConnection) throws {
        self.connection = connection
        registry = try EverTLSchema.makeRegistry()
    }

    public func connect() async throws { try await connection.connect() }
    public func close() async { await connection.close() }

    public func sendMessage(_ message: BagOfCells) async throws -> MessageSubmission {
        let reply = try await query(LiteServerSendMessageRequest(body: message.data))
        switch reply {
        case .liteServerSendMsgStatus(let value): return MessageSubmission(status: value.status)
        }
    }

    public func sendMessage(_ message: Cell) async throws -> MessageSubmission {
        try await sendMessage(BagOfCells(cell: message))
    }

    public func getAccountState(account: AccountID, at block: BlockID = .latest) async throws -> AccountState {
        let reply = try await query(LiteServerGetAccountStateRequest(id: block.tl, account: account.tl))
        switch reply {
        case .liteServerAccountState(let value): return AccountState(value)
        }
    }

    public func runMethod(
        account: AccountID,
        at block: BlockID = .latest,
        methodID: Int64,
        parameters: BagOfCells,
        options: RunMethodOptions = .result
    ) async throws -> RunMethodResult {
        let reply = try await query(LiteServerRunSmcMethodRequest(
            mode: options.rawValue, id: block.tl, account: account.tl,
            method_id: methodID, params: parameters.data
        ))
        switch reply {
        case .liteServerRunMethodResult(let value): return RunMethodResult(value)
        }
    }

    public func getTransaction(
        account: AccountID, at block: BlockID, logicalTime: UInt64
    ) async throws -> TransactionInfo {
        let reply = try await query(LiteServerGetOneTransactionRequest(
            id: block.tl, account: account.tl, lt: Int64(bitPattern: logicalTime)
        ))
        switch reply {
        case .liteServerTransactionInfo(let value): return TransactionInfo(value)
        }
    }

    public func getTransactions(
        account: AccountID, from transaction: TransactionID, count: Int = 10
    ) async throws -> TransactionList {
        guard count > 0, let count = UInt32(exactly: count) else {
            throw LiteClientError.invalidArgument("Transaction count must be between 1 and 4294967295.")
        }
        let reply = try await query(LiteServerGetTransactionsRequest(
            count: count, account: account.tl, lt: Int64(bitPattern: transaction.logicalTime), hash: transaction.hash.tl
        ))
        switch reply {
        case .liteServerTransactionList(let value): return TransactionList(value)
        }
    }

    public func query<Request: TLFunction>(_ request: Request) async throws -> Request.Reply {
        let body: Data
        if let wrapper = request as? LiteServerQueryRequest {
            body = wrapper.data
        } else {
            body = try TLCodec.encode(request)
        }
        let response = try await connection.exchange(body)
        var reader = TLReader(data: response)
        if response.count >= 4, try reader.read(UInt32.self, boxed: false) == LiteServerErrorConstructor.constructorID {
            let error = try TLCodec.decode(LiteServerErrorConstructor.self, from: response)
            throw LiteClientError.server(code: error.code, message: error.message)
        }
        return try TLCodec.decode(Request.Reply.self, from: response,
                                  boxed: Request.replyBoxed, registry: registry)
    }
}
