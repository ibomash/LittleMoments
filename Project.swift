import ProjectDescription

let project = Project(
  name: "LittleMoments",
  settings: .settings(
    configurations: [
      .debug(name: "Debug", xcconfig: "../Config/Debug.xcconfig"),
      .release(name: "Release", xcconfig: "../Config/Release.xcconfig"),
    ]
  ),
  targets: [
    .target(
      name: "LittleMoments",
      destinations: .iOS,
      product: .app,
      bundleId: "net.bomash.illya.Little-Moments",
      infoPlist: .file(path: "../Little-Moments-Info.plist"),
      sources: ["../LittleMoments/**/*.swift"],
      resources: [
        "../LittleMoments/**/Resources/**/*",
        "../LittleMoments/**/*.storyboard",
        "../LittleMoments/**/*.xcassets",
      ],
      entitlements: .file(path: "../Little Moments.entitlements"),
      dependencies: []
    ),
    .target(
      name: "LittleMomentsTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "net.bomash.illya.Little-MomentsTests",
      infoPlist: .default,
      sources: ["../Tests/**/*.swift"],
      resources: [],
      dependencies: [.target(name: "LittleMoments")]
    ),
  ]
)
