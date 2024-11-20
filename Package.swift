// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPipeline",
    products: [
        .library(
            name: "SwiftPipeline",
            targets: ["SwiftPipeline"]),
    ],
    targets: [
        .target(
            name: "SwiftPipeline"),
        .testTarget(
            name: "SwiftPipelineTests",
            dependencies: ["SwiftPipeline"]
        ),
    ]
)
