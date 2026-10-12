import Foundation
import EverTL
import EverLiteClientTL
import SwiftExtensionsPack
import adnl_swift

protocol LiteConnectionTransport: Sendable {
    func connect() async throws
    func send(_ data: Data) async throws
    func receive() async throws -> Data?
    func close() async
}

extension ADNLClient: LiteConnectionTransport {}

actor LiteConnection {
    private enum State { case idle, connecting, connected, closed }
    private struct Pending {
        let continuation: CheckedContinuation<Data, any Error>
        let deadline: Task<Void, Never>
    }
    private struct Outgoing {
        let queryID: TLBytes256?
        let data: Data
    }

    private let adnl: any LiteConnectionTransport
    private let requestTimeout: UInt64
    private let maximumPayloadSize: Int
    private var state: State = .idle
    private var terminalError: (any Error)?
    private var connectionWaiters: [UUID: CheckedContinuation<Void, any Error>] = [:]
    private var pending: [TLBytes256: Pending] = [:]
    private var outgoing: [Outgoing] = []
    private var connectionTask: Task<Void, Never>?
    private var receiveTask: Task<Void, Never>?
    private var sendTask: Task<Void, Never>?

    init(adnl: any LiteConnectionTransport, requestTimeout: TimeInterval,
         maximumPayloadSize: Int = (1 << 24) - 64) {
        self.adnl = adnl
        self.requestTimeout = UInt64(requestTimeout * 1_000_000_000)
        self.maximumPayloadSize = maximumPayloadSize
    }

    func connect() async throws {
        try Task.checkCancellation()
        if state == .connected { return }
        if state == .closed { throw terminalError ?? LiteClientError.connectionClosed }
        let waiterID = UUID()
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
                if Task.isCancelled {
                    continuation.resume(throwing: CancellationError())
                    return
                }
                connectionWaiters[waiterID] = continuation
                if state == .idle {
                    state = .connecting
                    connectionTask = Task { [weak self, adnl] in
                        do {
                            try await adnl.connect()
                            await self?.didConnect()
                        } catch {
                            await self?.fail(error)
                        }
                    }
                }
            }
        } onCancel: {
            Task { await self.cancelConnect(waiterID) }
        }
        try Task.checkCancellation()
    }

    func exchange(_ request: Data) async throws -> Data {
        let queryID = try TLBytes256(randomData(count: 32))
        let wrapped = try TLCodec.encode(LiteServerQueryRequest(data: request))
        let message = try TLCodec.encode(AdnlMessageQueryConstructor(query_id: queryID, query: wrapped))
        guard message.count <= maximumPayloadSize else {
            throw LiteClientError.invalidArgument("The encoded request exceeds the ADNL payload limit.")
        }
        try await connect()
        try Task.checkCancellation()
        guard state == .connected else { throw terminalError ?? LiteClientError.connectionClosed }
        let response: Data = try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                if Task.isCancelled {
                    continuation.resume(throwing: CancellationError())
                    return
                }
                let deadline = Task { [weak self, requestTimeout] in
                    do { try await Task.sleep(nanoseconds: requestTimeout) } catch { return }
                    await self?.finish(queryID, result: .failure(LiteClientError.requestTimedOut))
                }
                pending[queryID] = Pending(continuation: continuation, deadline: deadline)
                enqueue(Outgoing(queryID: queryID, data: message))
            }
        } onCancel: {
            Task { await self.finish(queryID, result: .failure(CancellationError())) }
        }
        try Task.checkCancellation()
        return response
    }

    func close() async {
        await fail(LiteClientError.connectionClosed)
        await adnl.close()
    }

    private func cancelConnect(_ id: UUID) {
        connectionWaiters.removeValue(forKey: id)?.resume(throwing: CancellationError())
    }

    private func didConnect() {
        guard state == .connecting else { return }
        state = .connected
        connectionTask = nil
        receiveTask = Task { [weak self, adnl] in
            do {
                while let data = try await adnl.receive() {
                    guard let self else { return }
                    try await self.receive(data)
                }
                await self?.fail(LiteClientError.connectionClosed)
            } catch {
                await self?.fail(error)
            }
        }
        let waiters = connectionWaiters
        connectionWaiters.removeAll()
        for waiter in waiters.values { waiter.resume() }
    }

    private func receive(_ data: Data) throws {
        guard state == .connected, !data.isEmpty else { return }
        var reader = TLReader(data: data)
        let constructorID = try reader.read(UInt32.self, boxed: false)
        if constructorID == TcpPingRequest.constructorID {
            let ping = try TLCodec.decode(TcpPingRequest.self, from: data)
            let pong = try TLCodec.encode(TcpPongConstructor(random_id: ping.random_id))
            enqueue(Outgoing(queryID: nil, data: pong))
        } else {
            let answer = try TLCodec.decode(AdnlMessageAnswerConstructor.self, from: data)
            // Late answers to timed-out or cancelled queries are safe to discard.
            finish(answer.query_id, result: .success(answer.answer))
        }
    }

    private func enqueue(_ item: Outgoing) {
        outgoing.append(item)
        if sendTask == nil {
            sendTask = Task { [weak self] in await self?.sendQueuedMessages() }
        }
    }

    private func sendQueuedMessages() async {
        defer { sendTask = nil }
        do {
            while state == .connected, !outgoing.isEmpty {
                let item = outgoing.removeFirst()
                if let queryID = item.queryID, pending[queryID] == nil { continue }
                try await adnl.send(item.data)
            }
        } catch {
            await fail(error)
        }
    }

    private func finish(_ id: TLBytes256, result: Result<Data, any Error>) {
        guard let request = pending.removeValue(forKey: id) else { return }
        request.deadline.cancel()
        request.continuation.resume(with: result)
    }

    private func fail(_ error: any Error) async {
        guard state != .closed else { return }
        state = .closed
        terminalError = error
        connectionTask?.cancel()
        receiveTask?.cancel()
        sendTask?.cancel()
        outgoing.removeAll()
        let waiters = connectionWaiters
        connectionWaiters.removeAll()
        for waiter in waiters.values { waiter.resume(throwing: error) }
        let requests = pending
        pending.removeAll()
        for request in requests.values {
            request.deadline.cancel()
            request.continuation.resume(throwing: error)
        }
        await adnl.close()
    }

    deinit {
        connectionTask?.cancel()
        receiveTask?.cancel()
        sendTask?.cancel()
        for request in pending.values {
            request.deadline.cancel()
            request.continuation.resume(throwing: LiteClientError.connectionClosed)
        }
        for waiter in connectionWaiters.values { waiter.resume(throwing: LiteClientError.connectionClosed) }
        let adnl = adnl
        Task { await adnl.close() }
    }
}
