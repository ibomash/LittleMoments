import ProjectDescription

let marketingVersion = "0.2.0"
let buildVersion = "51"

let baseSettings: [String: SettingValue] = [
  "MARKETING_VERSION": .string(marketingVersion),
  "CURRENT_PROJECT_VERSION": .string(buildVersion),
]

let project = Project(
  name: "LittleMoments",
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
      dependencies: [
        .target(name: "LittleMomentsWidgetExtension")
      ],
      settings: .settings(
        base: baseSettings,
        configurations: [
          .debug(
            name: "Debug",
            settings: [
              "SUPPORTED_PLATFORMS": "iphoneos iphonesimulator",
              "SUPPORTS_MACCATALYST": "NO",
              "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
            ]),
          .release(
            name: "Release",
            settings: [
              "SUPPORTED_PLATFORMS": "iphoneos iphonesimulator",
              "SUPPORTS_MACCATALYST": "NO",
            ]),
        ]
      ),
      additionalFiles: []
    ),
    // Widget Extension Target for Live Activities
    .target(
      name: "LittleMomentsWidgetExtension",
      destinations: .iOS,
      product: .appExtension,
      productName: "LittleMomentsWidgetExtension",
      bundleId: "net.bomash.illya.LittleMoments.WidgetExtension",
      infoPlist: .extendingDefault(with: [
        "CFBundleDisplayName": "LittleMoments Widgets",
        "NSExtension": [
          "NSExtensionPointIdentifier": "com.apple.widgetkit-extension"
        ],
      ]),
      sources: [
        "LittleMoments/Features/LiveActivity/Views/**",
        "LittleMoments/Features/LiveActivity/Models/**",
      ],
      resources: ["LittleMoments/Resources/**"],
      dependencies: [
        .sdk(name: "SwiftUI", type: .framework),
        .sdk(name: "WidgetKit", type: .framework),
        .sdk(name: "ActivityKit", type: .framework),
      ],
      settings: .settings(
        base: baseSettings
      )
    ),
    .target(
      name: "LittleMomentsTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "net.bomash.illya.LittleMomentsTests",
      infoPlist: .default,
      sources: ["LittleMoments/Tests/UnitTests/**"],
      dependencies: [
        .target(name: "LittleMoments")
      ]
    ),
    .target(
      name: "LittleMomentsUITests",
      destinations: .iOS,
      product: .uiTests,
      bundleId: "net.bomash.illya.LittleMomentsUITests",
      infoPlist: .default,
      sources: ["LittleMoments/Tests/UITests/**"],
      dependencies: [
        .target(name: "LittleMoments")
      ]
    ),
  ],
  schemes: [
    .scheme(
      name: "LittleMoments",
      shared: true,
      buildAction: .buildAction(targets: ["LittleMoments"]),
      testAction: .targets(
        ["LittleMomentsTests", "LittleMomentsUITests"],
        configuration: .debug,
        options: .options(coverage: true, codeCoverageTargets: ["LittleMoments"])
      ),
      runAction: .runAction(configuration: .debug),
      archiveAction: .archiveAction(configuration: .release),
      profileAction: .profileAction(configuration: .release),
      analyzeAction: .analyzeAction(configuration: .debug)
    ),
    .scheme(
      name: "LittleMomentsWidgetExtension",
      shared: true,
      buildAction: .buildAction(targets: ["LittleMomentsWidgetExtension"]),
      runAction: .runAction(configuration: .debug),
      archiveAction: .archiveAction(configuration: .release),
      profileAction: .profileAction(configuration: .release),
      analyzeAction: .analyzeAction(configuration: .debug)
    ),
  ]
)
