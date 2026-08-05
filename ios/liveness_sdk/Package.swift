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
            url: "https://github.com/EQua-Dev/ios-single-liveness-expo.git",
            from: "1.7.1"
        )
    ],
    targets: [
        .target(
            name: "liveness_sdk",
            dependencies: [
                .product(name: "LivenessCheck", package: "ios-single-liveness-expo")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
