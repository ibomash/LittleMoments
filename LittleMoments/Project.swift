import ProjectDescription

let project = Project(
  name: "LittleMoments",
  targets: [
    .target(
      name: "LittleMoments",
      destinations: .iOS,
      product: .app,
      bundleId: "io.tuist.LittleMoments",
      infoPlist: .extendingDefault(
        with: [
          "UILaunchScreen": [
            "UIColorName": "",
            "UIImageName": "",
          ]
        ]
      ),
      sources: ["LittleMoments/Sources/**"],
      resources: ["LittleMoments/Resources/**"],
      dependencies: []
    ),
    .target(
      name: "LittleMomentsTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "io.tuist.LittleMomentsTests",
      infoPlist: .default,
      sources: ["LittleMoments/Tests/**"],
      resources: [],
      dependencies: [.target(name: "LittleMoments")]
    ),
  ]
)
