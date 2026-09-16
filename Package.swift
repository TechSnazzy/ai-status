// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "AIStatus",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "AIStatus",
            path: "Sources/AIStatus"
        )
    ]
)
