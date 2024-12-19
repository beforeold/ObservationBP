// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "ObservationBP",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "ObservationBP",
      targets: ["ObservationBP"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-perception.git", .upToNextMajor(from: "1.3.5"))
  ],
  targets: [

    // Library that exposes a macro as part of its API, which is used in client programs.
    .target(
      name: "ObservationBP",
      dependencies: [
        .product(name: "Perception", package: "swift-perception")
      ]
    ),

    // A test target used to develop the macro implementation.
    .testTarget(
      name: "ObservationBPTests",
      dependencies: [
        "ObservationBP"
      ]
    ),
  ]
)
