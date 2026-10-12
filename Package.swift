// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ever-liteclient-swift",
    platforms: [.macOS(.v13), .iOS(.v13)],
    products: [
        .library(name: "EverLiteClient", targets: ["EverLiteClient"]),
        .library(name: "EverLiteClientTL", targets: ["EverLiteClientTL"])
    ],
    dependencies: [
        .package(url: "https://github.com/open-ever/ever-tl-swift", from: "1.0.0"),
        .package(url: "https://github.com/nerzh/adnl-swift", from: "1.1.1"),
        .package(url: "https://github.com/open-ever/everscale-sdk-swift", from: "1.0.0"),
        .package(url: "https://github.com/nerzh/swift-extensions-pack", from: "2.10.0")
    ],
    targets: [
        .target(
            name: "EverLiteClientTL",
            dependencies: [
                .product(name: "EverTL", package: "ever-tl-swift")
            ]
        ),
        .target(
            name: "EverLiteClient",
            dependencies: [
                "EverLiteClientTL",
                .product(name: "EverTL", package: "ever-tl-swift"),
                .product(name: "adnl-swift", package: "adnl-swift"),
                .product(name: "EverscaleSdkSwift", package: "everscale-sdk-swift"),
                .product(name: "SwiftExtensionsPack", package: "swift-extensions-pack")
            ]
        ),
        .testTarget(name: "EverLiteClientTests", dependencies: [
            "EverLiteClient",
            .product(name: "EverTLCodegen", package: "ever-tl-swift")
        ])
    ]
)
