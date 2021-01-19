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
        .package(name: "danger-swift", url: "https://github.com/danger/swift.git", from: "1.0.0"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.47.10"),
        .package(url: "https://github.com/Realm/SwiftLint", from: "0.42.0"),
        .package(url: "https://github.com/orta/Komondor", from: "1.0.6"),
    ],
    targets: [
        .target(
            name: "TargetSpecifics",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Danger", package: "danger-swift")
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

#if canImport(PackageConfig)
    import PackageConfig

    let config = PackageConfiguration([
        "komondor": [
            "pre-commit": [
                "echo 'Running tests...'",
                "swift test",
                "echo 'Running SwiftFormat...'",
                "swift run swiftformat .",
                "echo 'Running SwiftLint...'",
                "swift run swiftlint autocorrect --path Sources/",
                "git add .",
            ],
        ],
    ]).write()
#endif
