import ProjectDescription

let project = Project(
  name: "LittleMoments",
  settings: .settings(
    configurations: [
      .debug(name: "Debug", xcconfig: "Config/Debug.xcconfig"),
      .release(name: "Release", xcconfig: "Config/Release.xcconfig"),
    ]
  ),
  targets: [
    .target(
      name: "LittleMoments",
      destinations: .iOS,
      product: .app,
      bundleId: "net.bomash.illya.LittleMoments",
      infoPlist: .file(path: "Little-Moments-Info.plist"),
      sources: ["LittleMoments/Core/**", "LittleMoments/Features/**", "LittleMoments/App/iOS/**"],
      resources: ["LittleMoments/Resources/**"],
      entitlements: .file(path: "Little Moments.entitlements"),
      dependencies: []
    ),
    .target(
      name: "LittleMomentsTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "net.bomash.illya.LittleMomentsTests",
      infoPlist: .default,
      sources: ["LittleMoments/Tests/**"],
      dependencies: [
        .target(name: "LittleMoments")
      ]
    ),
  ]
)
