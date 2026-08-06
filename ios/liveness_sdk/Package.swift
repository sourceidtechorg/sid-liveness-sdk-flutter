// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "liveness_sdk",
    platforms: [
        .iOS("14.0")
    ],
    products: [
        .library(name: "liveness-sdk", targets: ["liveness_sdk"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/sourceidtechorg/sid-liveness-sdk-ios.git",
            from: "1.8.0"
        )
    ],
    targets: [
        .target(
            name: "liveness_sdk",
            dependencies: [
                .product(name: "LivenessCheck", package: "sid-liveness-sdk-ios")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
