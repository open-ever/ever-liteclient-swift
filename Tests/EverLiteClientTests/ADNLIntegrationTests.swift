import Foundation
import Testing
import EverTL
import EverLiteClientTL
import EverscaleSdkSwift
import adnl_swift
@testable import EverLiteClient

@Suite(.timeLimit(.minutes(1)))
struct ADNLIntegrationTests {
    @Test func encryptedHandshakeAndFragmentedReplies() async throws {
        let transport = EncryptedServerTransport()
        let server = try LiteServer(host: "localhost", port: 3030,
                                    publicKey: "3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c")
        let client = try LiteClient(server: server, requestTimeout: 5, transport: transport)
        let message = try BagOfCells(cell: Cell(bits: [.b1]))
        let result = try await client.sendMessage(message)
        #expect(result.isAccepted)
        #expect(await transport.body == message.data)
        #expect(await transport.waitForPong() == 42)
        await client.close()
        #expect(await transport.closed)
    }
}

private actor EncryptedServerTransport: ADNLTransport {
    private var cipher: ADNLCipher?
    private var plaintext = Data()
    private var chunks: [Data] = []
    private var reader: CheckedContinuation<Data?, any Error>?
    private var pongWaiters: [CheckedContinuation<Int64, Never>] = []
    private var pong: Int64?
    private(set) var body: Data?
    private(set) var closed = false

    func connect(host: String, port: Int) async throws {
        #expect(host == "localhost")
        #expect(port == 3030)
    }

    func send(_ data: Data) async throws {
        guard !closed else { throw LiteClientError.connectionClosed }
        guard let cipher else {
            let cipher = try ADNLHandshake.adnlHandshakeAssets(
                data, secretKey: "4ccd089b28ff96da9db6c346ec114e0f5b8a319f35aba624da8cf6ed4fb8a6fb"
            )
            self.cipher = cipher
            var output = try cipher.encryptor.adnlSerializeMessage(data: Data())
            output.append(try cipher.encryptor.adnlSerializeMessage(
                data: TLCodec.encode(TcpPingRequest(random_id: 42))
            ))
            enqueue(output)
            return
        }
        plaintext.append(try cipher.decryptor.update(data))
        while let packet = try ADNLPacket.parse(data: plaintext) {
            plaintext.removeFirst(packet.length)
            var reader = TLReader(data: packet.payload)
            if try reader.read(UInt32.self, boxed: false) == TcpPongConstructor.constructorID {
                let pong = try TLCodec.decode(TcpPongConstructor.self, from: packet.payload)
                self.pong = pong.random_id
                for waiter in pongWaiters { waiter.resume(returning: pong.random_id) }
                pongWaiters.removeAll()
            } else {
                let query = try TLCodec.decode(AdnlMessageQueryConstructor.self, from: packet.payload)
                let wrapper = try TLCodec.decode(LiteServerQueryRequest.self, from: query.query)
                body = try TLCodec.decode(LiteServerSendMessageRequest.self, from: wrapper.data).body
                let answer = try TLCodec.encode(AdnlMessageAnswerConstructor(query_id: query.query_id,
                                                                             answer: statusBody()))
                enqueue(try cipher.encryptor.adnlSerializeMessage(data: answer))
            }
        }
    }

    func receive() async throws -> Data? {
        if !chunks.isEmpty { return chunks.removeFirst() }
        if closed { return nil }
        return try await withCheckedThrowingContinuation { reader = $0 }
    }

    func close() async {
        closed = true
        reader?.resume(returning: nil)
        reader = nil
    }

    func waitForPong() async -> Int64 {
        if let pong { return pong }
        return await withCheckedContinuation { pongWaiters.append($0) }
    }

    private func enqueue(_ data: Data) {
        for byte in data { chunks.append(Data([byte])) }
        if let reader, !chunks.isEmpty {
            self.reader = nil
            reader.resume(returning: chunks.removeFirst())
        }
    }
}
