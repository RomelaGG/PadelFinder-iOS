// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreNavigation",
    platforms: [ .iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CoreNavigation",
            targets: ["CoreNavigation"]
        ),
    ],
    dependencies: [ .package(name: "DesignSystem", path: "../DesignSystem")],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CoreNavigation",
            dependencies: [
                .product(name: "DesignSystem", package: "DesignSystem")
            ]
        ),

    ]
)
