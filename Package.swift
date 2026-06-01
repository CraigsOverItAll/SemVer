// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SemVer",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(name: "SemVer", targets: ["SemVer"]),
    ],
    targets: [
        .target(
            name: "SemVer",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "SemVerTests",
            dependencies: ["SemVer"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
