// swift-tools-version: 6.0
import PackageDescription

let strictSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
]

let package = Package(
    name: "SwiftA2UIHost",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),        // `swift test` on the Mac
        .macCatalyst(.v17),
        .visionOS(.v1),
    ],
    products: [
        // A2UI protocol and surface state, with no UI: decoding, bindings, functions, actions.
        .library(name: "SwiftA2UIHost", targets: ["SwiftA2UIHost"]),
        // Native SwiftUI rendering: the 18 basic-catalog components plus your own.
        .library(name: "SwiftA2UIHostUI", targets: ["SwiftA2UIHostUI"]),
    ],
    // No dependencies, by design.
    targets: [
        .target(
            name: "SwiftA2UIHost",
            swiftSettings: strictSettings
        ),
        .target(
            name: "SwiftA2UIHostUI",
            dependencies: ["SwiftA2UIHost"],
            swiftSettings: strictSettings
        ),
        .testTarget(
            name: "SwiftA2UIHostTests",
            dependencies: ["SwiftA2UIHost", "SwiftA2UIHostUI"],
            // Google's official A2UI 1.0 examples (Apache-2.0), for the conformance tests.
            resources: [.copy("Fixtures")],
            swiftSettings: strictSettings
        ),
    ],
    swiftLanguageModes: [.v6]
)
