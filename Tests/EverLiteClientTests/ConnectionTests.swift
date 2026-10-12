import Foundation
import Testing
import EverTL
import EverLiteClientTL
@testable import EverLiteClient

@Suite(.timeLimit(.minutes(1)))
struct ConnectionTests {
    @Test func concurrentQueriesAcceptOutOfOrderReplies() async throws {
        let mock = MockConnection()
        let client = try makeClient(mock)
        let first = Task { try await client.sendMessage(BagOfCells(Data([11]))) }
        let second = Task { try await client.sendMessage(BagOfCells(Data([22]))) }
        let queries = try await mock.waitForQueries(2)
        #expect(queries[0].query_id != queries[1].query_id)
        for query in queries.reversed() {
            let body = try TLCodec.decode(LiteServerSendMessageRequest.self, from: requestBody(query)).body
            try await mock.answer(query, body: statusBody(Int32(body.first!)))
        }
        #expect(try await first.value.status == 11)
        #expect(try await second.value.status == 22)
        #expect(await mock.connectCount == 1)
        await client.close()
    }

    @Test func cancellationIsLimitedToOneQuery() async throws {
        let mock = MockConnection()
        let client = try makeClient(mock)
        let cancelled = Task { try await client.sendMessage(BagOfCells(Data([11]))) }
        let firstQueries = try await mock.waitForQueries(1)
        let active = Task { try await client.sendMessage(BagOfCells(Data([22]))) }
        let queries = try await mock.waitForQueries(2)
        cancelled.cancel()
        await #expect(throws: CancellationError.self) { try await cancelled.value }
        try await mock.answer(firstQueries[0], body: statusBody(11))
        try await mock.answer(queries[1], body: statusBody(22))
        #expect(try await active.value.status == 22)
        #expect(await !mock.closed)
        await client.close()
    }

    @Test func timeoutDiscardsLateReplyAndAllowsNextRequest() async throws {
        let mock = MockConnection()
        let client = try makeClient(mock, timeout: 0.05)
        let expired = Task { try await client.sendMessage(BagOfCells(Data())) }
        let oldQueries = try await mock.waitForQueries(1)
        await #expect(throws: LiteClientError.requestTimedOut) { try await expired.value }
        let next = Task { try await client.sendMessage(BagOfCells(Data())) }
        let queries = try await mock.waitForQueries(2)
        try await mock.answer(oldQueries[0], body: statusBody(99))
        try await mock.answer(queries[1], body: statusBody())
        #expect(try await next.value.isAccepted)
        await client.close()
    }

    @Test func pingPongAndEmptyFramesDoNotConsumeAnswer() async throws {
        let mock = MockConnection()
        let client = try makeClient(mock)
        let result = Task { try await client.sendMessage(BagOfCells(Data())) }
        let queries = try await mock.waitForQueries(1)
        await mock.push(Data())
        await mock.push(try TLCodec.encode(TcpPingRequest(random_id: .min)))
        #expect(await mock.waitForPong().random_id == .min)
        try await mock.answer(queries[0], body: statusBody())
        #expect(try await result.value.isAccepted)
        await client.close()
    }

    @Test func closeFailsPendingQueriesAndCannotReconnect() async throws {
        let mock = MockConnection()
        let client = try makeClient(mock)
        let request = Task { try await client.sendMessage(BagOfCells(Data())) }
        _ = try await mock.waitForQueries(1)
        await client.close()
        await #expect(throws: LiteClientError.connectionClosed) { try await request.value }
        await #expect(throws: LiteClientError.connectionClosed) { try await client.connect() }
        await #expect(throws: LiteClientError.connectionClosed) {
            try await client.sendMessage(BagOfCells(Data()))
        }
        await client.close()
    }

    @Test func eofFailsPendingQueries() async throws {
        let mock = MockConnection()
        let client = try makeClient(mock)
        let request = Task { try await client.sendMessage(BagOfCells(Data())) }
        _ = try await mock.waitForQueries(1)
        await mock.close()
        await #expect(throws: LiteClientError.connectionClosed) { try await request.value }
    }

    @Test func malformedEnvelopeTerminatesConnection() async throws {
        let mock = MockConnection()
        let client = try makeClient(mock)
        let request = Task { try await client.sendMessage(BagOfCells(Data())) }
        _ = try await mock.waitForQueries(1)
        await mock.push(Data([1]))
        await #expect(throws: TLCodecError.self) { try await request.value }
        await client.close()
        #expect(await mock.closed)
    }

    @Test func invalidReplyDoesNotDecodeTrailingBytes() async throws {
        let mock = MockConnection { _ in try statusBody() + Data([0]) }
        let client = try makeClient(mock)
        await #expect(throws: TLCodecError.trailingBytes(1)) {
            try await client.sendMessage(BagOfCells(Data()))
        }
        await client.close()
    }

    @Test func payloadLimitIncludesEnvelopes() async throws {
        let mock = MockConnection()
        let client = try makeClient(mock, limit: 40)
        await #expect(throws: LiteClientError.self) {
            try await client.sendMessage(BagOfCells(Data()))
        }
        #expect(await mock.connectCount == 0)
        await client.close()
    }

    @Test func cancellingConnectionWaiterDoesNotCancelOtherWaiters() async throws {
        let mock = MockConnection(holdConnection: true)
        let client = try makeClient(mock)
        let cancelled = Task { try await client.connect() }
        await mock.waitForConnect()
        cancelled.cancel()
        await #expect(throws: CancellationError.self) { try await cancelled.value }
        let active = Task { try await client.connect() }
        await mock.completeConnect()
        try await active.value
        #expect(await mock.connectCount == 1)
        #expect(await !mock.closed)
        await client.close()
    }

    @Test func closingDuringConnectUnblocksWaiter() async throws {
        let mock = MockConnection(holdConnection: true)
        let client = try makeClient(mock)
        let request = Task { try await client.connect() }
        await mock.waitForConnect()
        await client.close()
        await #expect(throws: LiteClientError.connectionClosed) { try await request.value }
    }

    @Test func writeFailureTerminatesConnection() async throws {
        let mock = MockConnection { _ in throw LiteClientError.invalidResponse("Write failed") }
        let client = try makeClient(mock)
        await #expect(throws: LiteClientError.invalidResponse("Write failed")) {
            try await client.sendMessage(BagOfCells(Data()))
        }
        await client.close()
        #expect(await mock.closed)
    }
}
