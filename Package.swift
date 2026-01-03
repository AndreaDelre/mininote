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
    dependencies: [
        .package(url: "https://github.com/apple/swift-markdown.git", branch: "main"),
        .package(url: "https://github.com/JohnSundell/Splash.git", from: "0.16.0")
    ],
    targets: [
        .executableTarget(
            name: "MiniNote",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "Splash", package: "Splash")
            ],
            path: "Sources"
        )
    ]
)
