// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreSocialAuth",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CoreSocialAuth",
            targets: ["CoreSocialAuth"]
        ),
    ],
    dependencies: [
        .package(name: "DomainLayer", path: "../DomainLayer"),
        .package(name: "CoreDI", path: "../CoreDI"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.10.0"),
        // Google's SDK is quarantined here so it stays out of
        // PresentationLayer, which every screen in the app lives in. It is
        // not a small guest: AppAuth, GTMAppAuth, gtm-session-fetcher,
        // app-check, GoogleUtilities, promises and
        // interop-ios-for-google-sdks all come along with it, in a project
        // whose only other third-party packages are Alamofire and Swinject.
        // That dependency list is identical on 8.x, 9.x and 10.x, so there is
        // nothing to gain by pinning older.
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "10.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CoreSocialAuth",
            dependencies: [
                .product(name: "DomainLayer", package: "DomainLayer"),
                .product(name: "CoreDI", package: "CoreDI"),
                .product(name: "Swinject", package: "Swinject"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
            ]
        ),

    ]
)
