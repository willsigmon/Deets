// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Deets",
    platforms: [
        .iOS(.v17) // Minimum iOS 17 for SwiftData
    ],
    products: [
        // Main app target
        .library(
            name: "DeetsKit",
            targets: ["DeetsKit"]
        )
    ],
    dependencies: [
        // No third-party dependencies for v1.0 (privacy-first approach)
        // Future potential dependencies (commented for reference):
        // .package(url: "https://github.com/realm/SwiftLint", from: "0.55.0"), // Dev only
        // .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.0") // Test only
    ],
    targets: [
        // Main library target
        .target(
            name: "DeetsKit",
            dependencies: [],
            path: "Sources",
            exclude: [
                "Resources/README.md",
                "Docs/",
                "Tests/"
            ],
            resources: [
                .process("Resources/Assets.xcassets"),
                .process("Resources/Localizable.xcstrings")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ImplicitOpenExistentials"),
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        // Unit tests
        .testTarget(
            name: "DeetsKitTests",
            dependencies: ["DeetsKit"],
            path: "Tests/Unit"
        ),

        // Integration tests
        .testTarget(
            name: "DeetsIntegrationTests",
            dependencies: ["DeetsKit"],
            path: "Tests/Integration"
        )
    ],
    swiftLanguageVersions: [.v5]
)
