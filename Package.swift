// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MiniNote",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "MiniNote",
            targets: ["MiniNote"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MiniNote",
            dependencies: [],
            path: "Sources"
        )
    ]
)
