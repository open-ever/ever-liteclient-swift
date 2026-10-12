# EverLiteClient

An asynchronous Swift client for Everscale lite servers over ADNL. It provides typed APIs for reading account state, running smart contract methods, retrieving transactions, and submitting messages.

The package exposes two libraries:

- `EverLiteClient`: the client, identifiers, response models, and bag-of-cells helpers.
- `EverLiteClientTL`: generated TL requests and responses for the schemas in `Schema/`.

## Quick start

Supply the lite server's `host`, `port`, and `serverPublicKey`, plus an account's `rawAddress`. The public key can be a hexadecimal or Base64 string, or 32 bytes of `Data`. Account strings use `workchain:hex` format, where the hash contains 64 hexadecimal digits.

Run this example in an asynchronous, throwing context:

```swift
import EverLiteClient

let server = try LiteServer(
    host: host,
    port: port,
    publicKey: serverPublicKey
)
let client = try LiteClient(server: server)
let account = try AccountID(rawAddress)

do {
    let state = try await client.getAccountState(account: account)
    print("Masterchain block:", state.block.sequenceNumber)
    print("State BOC bytes:", state.state.data.count)
    await client.close()
} catch {
    await client.close()
    throw error
}
```

Requests connect automatically. You can also call `try await client.connect()` to establish the connection explicitly. Reuse a client for multiple requests, including concurrent requests, and close it when finished. After closing or a terminal connection failure, create a new `LiteClient` to reconnect.

Connection and request timeouts default to 10 and 15 seconds respectively. Override them with `LiteClient(server:connectionTimeout:requestTimeout:)`; the request timeout must be greater than zero and at most 86,400 seconds. The initializer also accepts a custom `ADNLTransport` and a `maximumPayloadSize` limit.

## Account state and blocks

The following examples assume an open `client` and an `account` of type `AccountID`, and run in an asynchronous, throwing context.

```swift
let state = try await client.getAccountState(account: account, at: .latest)
let stateCell = try state.state.singleCell()

print("Resolved masterchain block:", state.block.sequenceNumber)
print("Shard block:", state.shardBlock.sequenceNumber)
print("Empty state:", stateCell == nil)
```

`getAccountState` and `runMethod` default to `BlockID.latest`, which asks a compatible lite server for its latest applied masterchain block. Their responses contain the resolved block IDs. To query a specific block, supply its workchain, shard, sequence number, root hash, and file hash:

```swift
let block = BlockID(
    workchain: -1,
    shard: BlockID.fullShard,
    sequenceNumber: sequenceNumber,
    rootHash: try Hash256(hex: rootHashHex),
    fileHash: try Hash256(hex: fileHashHex)
)
let historicalState = try await client.getAccountState(account: account, at: block)
```

Use values from the target block for `sequenceNumber`, `rootHashHex`, and `fileHashHex`. `AccountState` preserves the account state, account proof, and shard proof as `BagOfCells` values.

## Run a smart contract method

Provide the numeric `methodID` and `stackBOCData` containing the serialized TVM argument stack. Parameters are stack BOC data, rather than ABI JSON.

```swift
let result = try await client.runMethod(
    account: account,
    methodID: methodID,
    parameters: BagOfCells(stackBOCData),
    options: [.result, .accountProofs]
)

print("TVM exit code:", result.exitCode)
if result.isSuccessful, let stackBOC = result.result {
    print("Result stack BOC bytes:", stackBOC.data.count)
}
```

The default options request only `.result`. Available options are:

| Option | Response fields |
| --- | --- |
| `.result` | `result` |
| `.accountProofs` | `shardProof`, `proof` |
| `.stateProof` | `stateProof` |
| `.initialContext` | `initialContext` |
| `.libraryExtras` | `libraryExtras` |

`isSuccessful` is true for exit codes `0` and `1`. A TVM failure is returned in `exitCode`; it does not throw a client error. Optional fields depend on the response, and `result.options` records the fields returned by the server. Stack serialization and interpretation are handled by the caller.

## Transactions

Retrieve a single transaction using its account, logical time, and containing block. Supply an actual `BlockID` as `transactionBlock`:

```swift
let transaction = try await client.getTransaction(
    account: account,
    at: transactionBlock,
    logicalTime: logicalTime
)
let transactionCell = try transaction.transaction.singleCell()
```

To retrieve a transaction list, supply a known transaction's logical time and hash as the starting cursor:

```swift
let cursor = TransactionID(
    logicalTime: lastLogicalTime,
    hash: try Hash256(hex: lastTransactionHashHex)
)
let history = try await client.getTransactions(
    account: account,
    from: cursor,
    count: 10
)
let transactionCells = try history.transactions.cells()
print("Transaction roots:", transactionCells.count)
```

`getTransactions` defaults to 10 entries and accepts counts from 1 through `UInt32.max`. `TransactionList` contains the returned block IDs and transaction BOC. Logical times use `UInt64` throughout the public API.

## Submit a message

Supply `messageBOCData` containing a fully encoded external message:

```swift
let submission = try await client.sendMessage(BagOfCells(messageBOCData))
print("Submission status:", submission.status)
print("Accepted:", submission.isAccepted)
```

You can also pass an `EverscaleSdkSwift.Cell` directly to `sendMessage`. `isAccepted` means the server returned status `1`; transaction execution must be checked separately. Message construction and signing are handled by the caller.

## Bags of cells

`BagOfCells` stores raw BOC bytes in `data` and interoperates with cells from `EverscaleSdkSwift`:

```swift
import EverscaleSdkSwift

let cell = try Cell(bits: [.b1, .b0, .b1])
let boc = try BagOfCells(cell: cell)
let decodedCell = try boc.singleCell()

let multiRootBOC = try BagOfCells(cells: [cell, Cell(bits: [.b0])])
let roots = try multiRootBOC.cells()
```

`BagOfCells(data)` preserves bytes without validating them. Decoding happens in `cells()` or `singleCell()`. Empty data decodes to an empty array or `nil`; `singleCell()` throws if the BOC has more than one root. Proofs are returned as BOC data and are not verified by the client.

`AccountID` also accepts an `EverscaleSdkSwift.Address`. `Hash256` accepts exactly 32 bytes or 64 hexadecimal digits, with an optional `0x` prefix.

## Typed TL queries

Use `query(_:)` with a generated `EverLiteClientTL` request to receive its typed reply. The client handles TL and ADNL request envelopes:

```swift
import EverLiteClientTL

let reply = try await client.query(
    LiteServerSendMessageRequest(body: messageBOCData)
)
switch reply {
case .liteServerSendMsgStatus(let status):
    print(status.status)
}
```

## Errors

| Error | Meaning |
| --- | --- |
| `LiteClientError.invalidArgument` | Invalid input or an encoded request exceeding the payload limit. |
| `LiteClientError.requestTimedOut` | The request did not receive a reply before its deadline. |
| `LiteClientError.connectionClosed` | The connection was closed. Create a new client to reconnect. |
| `LiteClientError.server(code:message:)` | A lite server error with the original code and message. |
| `LiteClientError.invalidResponse` | A response BOC has more roots than `singleCell()` allows. |

Transport, TL decoding, and BOC decoding errors propagate to the caller. Task cancellation throws `CancellationError`. Cancelling or timing out one request leaves the connection available for other requests; server errors also leave it available.
