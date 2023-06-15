// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Line",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "Line", targets: ["Line"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "0.54.0"),
    ],
    targets: [
        .target(
            name: "Line"
        )
    ],
    swiftLanguageVersions: [.v5]
)
