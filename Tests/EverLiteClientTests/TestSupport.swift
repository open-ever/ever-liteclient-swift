import Foundation
import EverTL
import EverLiteClientTL
@testable import EverLiteClient

let fixtureBlock = BlockID(workchain: -1, sequenceNumber: 123456, rootHash: .zero, fileHash: .zero)
let fixtureAccount = AccountID(workchain: 0, hash: .zero)

actor MockConnection: LiteConnectionTransport {
    private let handler: (@Sendable (Data) throws -> Data?)?
    private let holdConnection: Bool
    private var input: [Data] = []
    private var reader: CheckedContinuation<Data?, any Error>?
    private var connector: CheckedContinuation<Void, any Error>?
    private var queryObservers: [(Int, CheckedContinuation<[AdnlMessageQueryConstructor], any Error>)] = []
    private var pongObservers: [CheckedContinuation<TcpPongConstructor, Never>] = []
    private var connectObservers: [CheckedContinuation<Void, Never>] = []
    private(set) var queries: [AdnlMessageQueryConstructor] = []
    private(set) var pongs: [TcpPongConstructor] = []
    private(set) var connectCount = 0
    private(set) var closed = false

    init(holdConnection: Bool = false, handler: (@Sendable (Data) throws -> Data?)? = nil) {
        self.holdConnection = holdConnection
        self.handler = handler
    }

    func connect() async throws {
        connectCount += 1
        for observer in connectObservers { observer.resume() }
        connectObservers.removeAll()
        if holdConnection {
            try await withCheckedThrowingContinuation { connector = $0 }
        }
    }

    func send(_ data: Data) async throws {
        guard !closed else { throw LiteClientError.connectionClosed }
        var reader = TLReader(data: data)
        if try reader.read(UInt32.self, boxed: false) == TcpPongConstructor.constructorID {
            let pong = try TLCodec.decode(TcpPongConstructor.self, from: data)
            pongs.append(pong)
            for observer in pongObservers { observer.resume(returning: pong) }
            pongObservers.removeAll()
            return
        }
        let query = try TLCodec.decode(AdnlMessageQueryConstructor.self, from: data)
        let wrapper = try TLCodec.decode(LiteServerQueryRequest.self, from: query.query)
        queries.append(query)
        let ready = queryObservers.filter { queries.count >= $0.0 }
        queryObservers.removeAll { queries.count >= $0.0 }
        for (_, observer) in ready { observer.resume(returning: queries) }
        if let body = try handler?(wrapper.data) {
            try answer(query, body: body)
        }
    }

    func receive() async throws -> Data? {
        if !input.isEmpty { return input.removeFirst() }
        if closed { return nil }
        return try await withCheckedThrowingContinuation { reader = $0 }
    }

    func close() async {
        closed = true
        reader?.resume(returning: nil)
        reader = nil
        connector?.resume(throwing: LiteClientError.connectionClosed)
        connector = nil
        for (_, observer) in queryObservers { observer.resume(throwing: LiteClientError.connectionClosed) }
        queryObservers.removeAll()
    }

    func waitForQueries(_ count: Int) async throws -> [AdnlMessageQueryConstructor] {
        if queries.count >= count { return queries }
        return try await withCheckedThrowingContinuation { queryObservers.append((count, $0)) }
    }

    func waitForPong() async -> TcpPongConstructor {
        if let pong = pongs.last { return pong }
        return await withCheckedContinuation { pongObservers.append($0) }
    }

    func waitForConnect() async {
        if connectCount > 0 { return }
        await withCheckedContinuation { connectObservers.append($0) }
    }

    func completeConnect() {
        connector?.resume()
        connector = nil
    }

    func answer(_ query: AdnlMessageQueryConstructor, body: Data) throws {
        push(try TLCodec.encode(AdnlMessageAnswerConstructor(query_id: query.query_id, answer: body)))
    }

    func push(_ data: Data) {
        if let reader {
            self.reader = nil
            reader.resume(returning: data)
        } else {
            input.append(data)
        }
    }
}

func makeClient(_ mock: MockConnection, timeout: TimeInterval = 2, limit: Int = 1 << 20) throws -> LiteClient {
    try LiteClient(connection: LiteConnection(adnl: mock, requestTimeout: timeout, maximumPayloadSize: limit))
}

func requestBody(_ query: AdnlMessageQueryConstructor) throws -> Data {
    try TLCodec.decode(LiteServerQueryRequest.self, from: query.query).data
}

func statusBody(_ status: Int32 = 1) throws -> Data {
    try TLCodec.encode(LiteServerSendMsgStatusConstructor(status: status))
}
