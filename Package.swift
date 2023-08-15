// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Line",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "Line", targets: ["Line"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: ("1.1.0")),
    ],
    targets: [
        .target(
            name: "Line",
            dependencies: [
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                )
            ],
            path: ""
        )
    ],
    swiftLanguageVersions: [.v5]
)
