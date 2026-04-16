// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SharedKit",
    platforms: [
        .iOS(.v17)
        // watchOS target is v2 scope — add .watchOS(.v10) when Watch specs are written
    ],
    products: [
        .library(
            name: "SharedKit",
            targets: ["SharedKit"]
        )
    ],
    dependencies: [
        // Pure Swift — no external dependencies
    ],
    targets: [
        .target(
            name: "SharedKit",
            dependencies: [],
            path: "Sources/SharedKit",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SharedKitTests",
            dependencies: ["SharedKit"],
            path: "Tests/SharedKitTests",
            resources: [
                .process("Fixtures")
            ]
        )
    ]
)
