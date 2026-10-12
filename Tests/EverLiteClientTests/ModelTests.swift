import Foundation
import Testing
import EverTL
import EverTLCodegen
import EverLiteClientTL
import EverscaleSdkSwift
@testable import EverLiteClient

struct ModelTests {
    @Test func generatedSourceMatchesSchemas() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
        let input = try ["lite_api.tl", "tcp_api.tl"].map {
            try String(contentsOf: root.appendingPathComponent("Schema/\($0)"), encoding: .utf8)
        }.joined(separator: "\n")
        let schema = try TLParser.parse(input)
        let generated = try TLSwiftGenerator.generate(schema: schema)
        let saved = try String(contentsOf: root.appendingPathComponent("Sources/EverLiteClientTL/Generated/LiteAPI.swift"), encoding: .utf8)
        #expect(generated == saved)
    }

    @Test func constructorIDsMatchProtocolVectors() {
        #expect(LiteServerSendMessageRequest.constructorID == 0x690ad482)
        #expect(LiteServerQueryRequest.constructorID == 0x798c06df)
        #expect(AdnlMessageQueryConstructor.constructorID == 0xb48bf97a)
        #expect(AdnlMessageAnswerConstructor.constructorID == 0x0fac8416)
        #expect(LiteServerSendMsgStatusConstructor.constructorID == 0x3950e597)
        #expect(LiteServerErrorConstructor.constructorID == 0xbba9e148)
        #expect(TcpPingRequest.constructorID == 0x4d082b9a)
        #expect(TcpPongConstructor.constructorID == 0xdc69fb03)
    }

    @Test func requestMatchesIndependentWireVector() throws {
        let body = try TLCodec.encode(LiteServerSendMessageRequest(body: Data([0xaa, 0xbb, 0xcc])))
        let wrapper = try TLCodec.encode(LiteServerQueryRequest(data: body))
        let message = try TLCodec.encode(AdnlMessageQueryConstructor(query_id: TLBytes256(), query: wrapper))
        let expected = Data([0x7a, 0xf9, 0x8b, 0xb4]) + Data(repeating: 0, count: 32) + Data([
            0x10, 0xdf, 0x06, 0x8c, 0x79, 0x08, 0x82, 0xd4, 0x0a, 0x69,
            0x03, 0xaa, 0xbb, 0xcc, 0, 0, 0, 0, 0, 0
        ])
        #expect(message == expected)
    }

    @Test func signedTLFieldsPreserveUnsignedValues() throws {
        let block = try BlockID.latest.tl
        #expect(block.shard == Int64.min)
        #expect(block.seqno == -1)
        #expect(BlockID(tl: block) == .latest)
        #expect(try TLCodec.encode(block, boxed: false).count == 80)
    }

    @Test func addressAndHashInputs() throws {
        let text = String(repeating: "ab", count: 32)
        let hash = try Hash256(hex: "0x" + text)
        #expect(hash.description == text)
        let account = try AccountID(" -1:\(text) ")
        #expect(account.description == "-1:\(text)")
        #expect(try AccountID(Address(address: account.description)) == account)
        #expect(try AccountID("1000:\(text)").workchain == 1000)
        #expect(throws: LiteClientError.self) { try Hash256(Data(repeating: 0, count: 31)) }
        #expect(throws: LiteClientError.self) { try Hash256(hex: "00") }
        #expect(throws: LiteClientError.self) { try AccountID("invalid") }
        #expect(throws: LiteClientError.self) { try AccountID("0:\(String(repeating: "g", count: 64))") }
    }

    @Test func cellBOCConvenienceMethods() throws {
        let cell = try Cell(bits: [.b1, .b0, .b1])
        let boc = try BagOfCells(cell: cell)
        #expect(try boc.singleCell()?.bits == cell.bits)
        #expect(try BagOfCells(Data()).cells().isEmpty)
        let multiRoot = try BagOfCells(cells: [cell, Cell(bits: [.b0])])
        #expect(throws: LiteClientError.self) { try multiRoot.singleCell() }
        #expect(throws: (any Error).self) { try BagOfCells(Data([0])).cells() }
    }

    @Test func serverAndTimeoutValidation() throws {
        let key = Data(repeating: 1, count: 32)
        let server = try LiteServer(host: " localhost ", port: 3030, publicKey: key)
        #expect(server.host == "localhost")
        #expect(try LiteServer(host: "localhost", port: 3030, publicKey: key.base64EncodedString()) == server)
        #expect(throws: LiteClientError.self) { try LiteServer(host: "", port: 3030, publicKey: key) }
        #expect(throws: LiteClientError.self) { try LiteServer(host: "localhost", port: 0, publicKey: key) }
        #expect(throws: (any Error).self) { try LiteServer(host: "localhost", port: 3030, publicKey: Data()) }
        for timeout in [0.0, -1, Double.nan, Double.infinity, 86_401] {
            #expect(throws: LiteClientError.self) { try LiteClient(server: server, requestTimeout: timeout) }
        }
    }
}
