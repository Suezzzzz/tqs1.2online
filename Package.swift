// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TruckQueue",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "TruckQueue",
            targets: ["TruckQueue"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TruckQueue",
            dependencies: []),
        .testTarget(
            name: "TruckQueueTests",
            dependencies: ["TruckQueue"]),
    ]
) 