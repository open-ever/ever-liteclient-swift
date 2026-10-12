import Foundation
import Testing
import EverTL
import EverLiteClientTL
import EverscaleSdkSwift
@testable import EverLiteClient

@Suite(.timeLimit(.minutes(1)))
struct APITests {
    @Test func sendMessageUsesNestedTLEnvelopes() async throws {
        let cell = try Cell(bits: [.b1, .b0, .b1])
        let boc = try BagOfCells(cell: cell)
        let mock = MockConnection { data in
            let request = try TLCodec.decode(LiteServerSendMessageRequest.self, from: data)
            #expect(request.body == boc.data)
            return try statusBody()
        }
        let client = try makeClient(mock)
        let response = try await client.sendMessage(cell)
        #expect(response.status == 1)
        #expect(response.isAccepted)
        #expect(await mock.connectCount == 1)
        await client.close()
    }

    @Test func nonAcceptedSubmissionPreservesStatus() async throws {
        let mock = MockConnection { _ in try statusBody(0) }
        let client = try makeClient(mock)
        let response = try await client.sendMessage(BagOfCells(Data()))
        #expect(!response.isAccepted)
        #expect(response.status == 0)
        await client.close()
    }

    @Test func accountStatePreservesProofsAndEmptyState() async throws {
        let mock = MockConnection { data in
            let request = try TLCodec.decode(LiteServerGetAccountStateRequest.self, from: data)
            #expect(try request.account == fixtureAccount.tl)
            #expect(try request.id == fixtureBlock.tl)
            return try TLCodec.encode(LiteServerAccountStateConstructor(
                id: request.id, shardblk: request.id,
                shard_proof: Data([1]), proof: Data([2]), state: Data()
            ))
        }
        let client = try makeClient(mock)
        let response = try await client.getAccountState(account: fixtureAccount, at: fixtureBlock)
        #expect(response.block == fixtureBlock)
        #expect(response.shardBlock == fixtureBlock)
        #expect(response.shardProof.data == Data([1]))
        #expect(response.proof.data == Data([2]))
        #expect(try response.state.singleCell() == nil)
        await client.close()
    }

    @Test(arguments: [true, false])
    func latestAccountStateReturnsResolvedBlockID(explicitLatest: Bool) async throws {
        let resolvedBlock = BlockID(workchain: -1, sequenceNumber: 123456,
                                    rootHash: try Hash256(Data(repeating: 0x11, count: 32)),
                                    fileHash: try Hash256(Data(repeating: 0x22, count: 32)))
        let mock = MockConnection { data in
            let request = try TLCodec.decode(LiteServerGetAccountStateRequest.self, from: data)
            #expect(request.id.workchain == -1)
            #expect(request.id.shard == Int64.min)
            #expect(request.id.seqno == -1)
            #expect(request.id.root_hash == TLBytes256())
            #expect(request.id.file_hash == TLBytes256())
            return try TLCodec.encode(LiteServerAccountStateConstructor(
                id: resolvedBlock.tl, shardblk: resolvedBlock.tl,
                shard_proof: Data(), proof: Data(), state: Data()
            ))
        }
        let client = try makeClient(mock)
        let state: AccountState
        if explicitLatest {
            state = try await client.getAccountState(account: fixtureAccount, at: .latest)
        } else {
            state = try await client.getAccountState(account: fixtureAccount)
        }
        #expect(state.block == resolvedBlock)
        #expect(state.block.sequenceNumber == 123456)
        #expect(state.block != .latest)
        await client.close()
    }

    @Test(arguments: [true, false])
    func latestRunMethodReturnsResolvedBlockID(explicitLatest: Bool) async throws {
        let parameters = BagOfCells(Data([0xaa]))
        let mock = MockConnection { data in
            let request = try TLCodec.decode(LiteServerRunSmcMethodRequest.self, from: data)
            #expect(request.id.workchain == -1)
            #expect(request.id.shard == Int64.min)
            #expect(request.id.seqno == -1)
            #expect(request.id.root_hash == TLBytes256())
            #expect(request.id.file_hash == TLBytes256())
            #expect(request.mode == 4)
            #expect(request.method_id == 123)
            #expect(request.params == parameters.data)
            return try TLCodec.encode(LiteServerRunMethodResultConstructor(
                id: fixtureBlock.tl, shardblk: fixtureBlock.tl, exit_code: 0, result: Data([0xbb])
            ))
        }
        let client = try makeClient(mock)
        let response: RunMethodResult
        if explicitLatest {
            response = try await client.runMethod(account: fixtureAccount, at: .latest,
                                                  methodID: 123, parameters: parameters)
        } else {
            response = try await client.runMethod(account: fixtureAccount,
                                                  methodID: 123, parameters: parameters)
        }
        #expect(response.block == fixtureBlock)
        #expect(response.block != .latest)
        #expect(response.shardBlock == fixtureBlock)
        #expect(response.isSuccessful)
        #expect(response.result?.data == Data([0xbb]))
        await client.close()
    }

    @Test func runMethodHandlesEveryOptionalField() async throws {
        let parameters = BagOfCells(Data([0xaa]))
        let options: RunMethodOptions = [.result, .accountProofs, .stateProof, .initialContext, .libraryExtras]
        let mock = MockConnection { data in
            let request = try TLCodec.decode(LiteServerRunSmcMethodRequest.self, from: data)
            #expect(request.mode == options.rawValue)
            #expect(request.method_id == 0x12345678)
            #expect(request.params == parameters.data)
            #expect(try request.id == fixtureBlock.tl)
            #expect(try request.account == fixtureAccount.tl)
            return try TLCodec.encode(LiteServerRunMethodResultConstructor(
                id: request.id, shardblk: request.id, shard_proof: Data([1]), proof: Data([2]),
                state_proof: Data([3]), init_c7: Data([4]), lib_extras: Data([5]),
                exit_code: 0, result: Data([6])
            ))
        }
        let client = try makeClient(mock)
        let response = try await client.runMethod(account: fixtureAccount, at: fixtureBlock,
                                                  methodID: 0x12345678, parameters: parameters, options: options)
        #expect(response.options == options)
        #expect(response.isSuccessful)
        #expect(response.shardProof?.data == Data([1]))
        #expect(response.proof?.data == Data([2]))
        #expect(response.stateProof?.data == Data([3]))
        #expect(response.initialContext?.data == Data([4]))
        #expect(response.libraryExtras?.data == Data([5]))
        #expect(response.result?.data == Data([6]))
        await client.close()
    }

    @Test func runMethodDefaultsToResultAndPreservesVMFailure() async throws {
        let mock = MockConnection { data in
            let request = try TLCodec.decode(LiteServerRunSmcMethodRequest.self, from: data)
            #expect(request.mode == 4)
            return try TLCodec.encode(LiteServerRunMethodResultConstructor(
                id: request.id, shardblk: request.id, exit_code: -256
            ))
        }
        let client = try makeClient(mock)
        let response = try await client.runMethod(account: fixtureAccount, at: fixtureBlock,
                                                  methodID: 0, parameters: BagOfCells(Data()))
        #expect(!response.isSuccessful)
        #expect(response.exitCode == -256)
        #expect(response.result == nil)
        #expect(response.options.isEmpty)
        await client.close()
    }

    @Test func transactionLogicalTimeKeepsAll64Bits() async throws {
        let mock = MockConnection { data in
            let request = try TLCodec.decode(LiteServerGetOneTransactionRequest.self, from: data)
            #expect(request.lt == -1)
            #expect(try request.account == fixtureAccount.tl)
            return try TLCodec.encode(LiteServerTransactionInfoConstructor(
                id: request.id, proof: Data([1]), transaction: Data([2])
            ))
        }
        let client = try makeClient(mock)
        let response = try await client.getTransaction(account: fixtureAccount, at: fixtureBlock, logicalTime: .max)
        #expect(response.block == fixtureBlock)
        #expect(response.proof.data == Data([1]))
        #expect(response.transaction.data == Data([2]))
        await client.close()
    }

    @Test func transactionListPreservesRootOrder() async throws {
        let first = try Cell(bits: [.b1])
        let second = try Cell(bits: [.b0])
        let boc = try BagOfCells(cells: [first, second])
        let mock = MockConnection { data in
            let request = try TLCodec.decode(LiteServerGetTransactionsRequest.self, from: data)
            #expect(request.count == 10)
            #expect(request.lt == -1)
            #expect(request.hash == TLBytes256())
            #expect(try request.account == fixtureAccount.tl)
            return try TLCodec.encode(LiteServerTransactionListConstructor(
                ids: [fixtureBlock.tl, fixtureBlock.tl], transactions: boc.data
            ))
        }
        let client = try makeClient(mock)
        let response = try await client.getTransactions(account: fixtureAccount,
                                                        from: TransactionID(logicalTime: .max, hash: .zero))
        #expect(response.blocks == [fixtureBlock, fixtureBlock])
        let roots = try response.transactions.cells()
        #expect(roots.count == 2)
        #expect(roots[0].bits == [.b1])
        #expect(roots[1].bits == [.b0])
        await client.close()
    }

    @Test(arguments: [0, -1, Int(UInt32.max) + 1])
    func invalidCountFailsBeforeConnecting(_ count: Int) async throws {
        let mock = MockConnection()
        let client = try makeClient(mock)
        await #expect(throws: LiteClientError.self) {
            try await client.getTransactions(account: fixtureAccount,
                                              from: TransactionID(logicalTime: 0, hash: .zero), count: count)
        }
        #expect(await mock.connectCount == 0)
        await client.close()
    }

    @Test func serverErrorIsTypedAndConnectionRemainsUsable() async throws {
        let mock = MockConnection { data in
            let request = try TLCodec.decode(LiteServerSendMessageRequest.self, from: data)
            if request.body.isEmpty {
                return try TLCodec.encode(LiteServerErrorConstructor(code: -400, message: "Invalid BOC"))
            }
            return try statusBody()
        }
        let client = try makeClient(mock)
        await #expect(throws: LiteClientError.server(code: -400, message: "Invalid BOC")) {
            try await client.sendMessage(BagOfCells(Data()))
        }
        let response = try await client.sendMessage(BagOfCells(Data([1])))
        #expect(response.isAccepted)
        #expect(await mock.connectCount == 1)
        await client.close()
    }

    @Test func typedQuerySupportsDynamicObjectReply() async throws {
        let mock = MockConnection { data in
            let request = try TLCodec.decode(LiteServerSendMessageRequest.self, from: data)
            #expect(request.body == Data([7]))
            return try statusBody()
        }
        let client = try makeClient(mock)
        let body = try TLCodec.encode(LiteServerSendMessageRequest(body: Data([7])))
        let object = try await client.query(LiteServerQueryRequest(data: body))
        #expect(object.cast(to: LiteServerSendMsgStatusConstructor.self)?.status == 1)
        await client.close()
    }
}
