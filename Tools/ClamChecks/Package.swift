// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "ClamChecks",
  platforms: [.macOS(.v14)],
  products: [
    .executable(name: "clam-checks", targets: ["clam-checks"])
  ],
  targets: [
    .target(name: "ClamChecksCore"),
    .executableTarget(
      name: "clam-checks",
      dependencies: ["ClamChecksCore"]
    ),
    .testTarget(
      name: "ClamChecksCoreTests",
      dependencies: ["ClamChecksCore"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
