import Foundation
import EverscaleSdkSwift

public struct BagOfCells: Equatable, Sendable {
    public let data: Data

    public init(_ data: Data) { self.data = Data(data) }

    public init(cell: Cell) throws { data = try cell.toBoc() }

    public init(cells: [Cell]) throws { data = try Boc.serialize(root: cells) }

    public var isEmpty: Bool { data.isEmpty }

    public func cells() throws -> [Cell] {
        if isEmpty { return [] }
        return try Boc.deserialize(data: data)
    }

    public func singleCell() throws -> Cell? {
        let roots = try cells()
        guard roots.count <= 1 else {
            throw LiteClientError.invalidResponse("Expected a BOC containing at most one root cell.")
        }
        return roots.first
    }
}
