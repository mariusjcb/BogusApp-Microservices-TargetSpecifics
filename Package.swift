// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "BogusApp-Microservices-TargetSpecifics",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(name: "BogusApp-Common-Models", url: "../../Common/BogusApp-Common-Models", .branch("master")),
        .package(name: "BogusApp-Common-MockDataProvider", url: "../../Common/BogusApp-Common-MockDataProvider", .branch("master"))
    ],
    targets: [
        .target(
            name: "TargetSpecifics",
            dependencies: [
                .product(name: "BogusApp-Common-Models", package: "BogusApp-Common-Models"),
                .product(name: "BogusApp-Common-MockDataProvider", package: "BogusApp-Common-MockDataProvider"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
            ],
            path: "Sources/App",
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run TargetSpecifics", dependencies: [.target(name: "TargetSpecifics")], path: "Sources/Run"),
        .testTarget(
            name: "TargetSpecifics Tests",
            dependencies: [
                .target(name: "TargetSpecifics"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            path: "Tests/AppTests"
        )
    ]
)
