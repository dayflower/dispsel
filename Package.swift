// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "dispsel",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "dispsel", targets: ["dispsel"])
    ],
    dependencies: [
        .package(url: "https://github.com/waydabber/AppleSiliconDDC.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.7.0"),
        .package(url: "https://github.com/swiftlang/swift-testing.git", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "dispsel",
            dependencies: [
                "DispselCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(
            name: "DispselCore",
            dependencies: [
                .product(name: "AppleSiliconDDC", package: "AppleSiliconDDC")
            ]
        ),
        .testTarget(
            name: "DispselCoreTests",
            dependencies: [
                "DispselCore",
                .product(name: "Testing", package: "swift-testing")
            ]
        )
    ]
)
