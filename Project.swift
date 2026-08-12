import ProjectDescription

// swiftlint:disable trailing_comma
// Explanation: Tuist manifests intentionally use trailing commas for
// readability and cleaner diffs. We disable only this rule for this file.

let marketingVersion = "0.2.0"
let buildVersion = "51"

let baseSettings: [String: SettingValue] = [
  "MARKETING_VERSION": .string(marketingVersion),
  "CURRENT_PROJECT_VERSION": .string(buildVersion),
  "DEVELOPMENT_TEAM": .string("Z5NU48NAF9"),
  // Adopt Swift 6 across all targets
  "SWIFT_VERSION": .string("6.0"),
]

let project = Project(
  name: "LittleMoments",
  targets: [
    .target(
      name: "LittleMoments",
      destinations: .iOS,
      product: .app,
      bundleId: "net.bomash.illya.LittleMoments",
      deploymentTargets: .iOS("26.0"),
      infoPlist: .file(path: "Little-Moments-Info.plist"),
      sources: [
        "LittleMoments/Core/**",
        .glob(
          "LittleMoments/Features/**",
          excluding: ["LittleMoments/Features/macOS/**"]
        ),
        "LittleMoments/App/iOS/**",
      ],
      resources: ["LittleMoments/Resources/**"],
      entitlements: .file(path: "Little Moments.entitlements"),
      dependencies: [
        .target(name: "LittleMomentsWidgetExtension"),
        .sdk(name: "SwiftUI", type: .framework),
        .sdk(name: "WidgetKit", type: .framework),
        .sdk(name: "ActivityKit", type: .framework),
        .sdk(name: "UIKit", type: .framework),
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
              "CODE_SIGN_ENTITLEMENTS": "Little Moments.entitlements",
              "CODE_SIGN_STYLE": "Automatic",
            ]
          ),
          .release(
            name: "Release",
            settings: [
              "SUPPORTED_PLATFORMS": "iphoneos iphonesimulator",
              "SUPPORTS_MACCATALYST": "NO",
              "CODE_SIGN_ENTITLEMENTS": "Little Moments.entitlements",
              "CODE_SIGN_STYLE": "Automatic",
            ]
          ),
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
      deploymentTargets: .iOS("26.0"),
      infoPlist: .file(path: "LittleMoments/WidgetExtension/WidgetExtension-Info.plist"),
      sources: [
        "LittleMoments/WidgetExtension/**",
        "LittleMoments/Core/Styling/LiquidGlassStyles.swift",
      ],
      resources: ["LittleMoments/Resources/**"],
      entitlements: .file(
        path: "LittleMoments/WidgetExtension/LittleMomentsWidgetExtension.entitlements"),
      dependencies: [
        .sdk(name: "SwiftUI", type: .framework),
        .sdk(name: "WidgetKit", type: .framework),
        .sdk(name: "ActivityKit", type: .framework),
      ],
      settings: .settings(
        base: baseSettings,
        configurations: [
          .debug(
            name: "Debug",
            settings: [
              "CODE_SIGN_ENTITLEMENTS":
                "LittleMoments/WidgetExtension/LittleMomentsWidgetExtension.entitlements",
              "CODE_SIGN_STYLE": "Automatic",
              "PROVISIONING_PROFILE_SPECIFIER": "",
              "CODE_SIGN_IDENTITY": "Apple Development",
            ]
          ),
          .release(
            name: "Release",
            settings: [
              "CODE_SIGN_ENTITLEMENTS":
                "LittleMoments/WidgetExtension/LittleMomentsWidgetExtension.entitlements",
              "CODE_SIGN_STYLE": "Automatic",
              "PROVISIONING_PROFILE_SPECIFIER": "",
              "CODE_SIGN_IDENTITY": "Apple Development",
            ]
          ),
        ]
      )
    ),
    .target(
      name: "LittleMomentsTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "net.bomash.illya.LittleMomentsTests",
      deploymentTargets: .iOS("26.0"),
      infoPlist: .default,
      sources: ["LittleMoments/Tests/UnitTests/**"],
      dependencies: [
        .target(name: "LittleMoments")
      ],
      settings: .settings(
        base: baseSettings.merging(["SWIFT_STRICT_CONCURRENCY": .string("minimal")]) { $1 })
    ),
    .target(
      name: "LittleMomentsUITests",
      destinations: .iOS,
      product: .uiTests,
      bundleId: "net.bomash.illya.LittleMomentsUITests",
      deploymentTargets: .iOS("26.0"),
      infoPlist: .default,
      sources: ["LittleMoments/Tests/UITests/**"],
      dependencies: [
        .target(name: "LittleMoments")
      ],
      settings: .settings(base: baseSettings)
    ),
    .target(
      name: "LittleMomentsMac",
      destinations: .macOS,
      product: .app,
      bundleId: "net.bomash.illya.LittleMoments",
      deploymentTargets: .macOS("26.0"),
      infoPlist: .extendingDefault(
        with: [
          "CFBundleDisplayName": "Little Moments",
          "CFBundleName": "Little Moments",
          "LSApplicationCategoryType": "public.app-category.healthcare-fitness",
        ]
      ),
      sources: [
        "LittleMoments/App/macOS/**",
        "LittleMoments/Features/macOS/**",
        "LittleMoments/Core/Audio/MeditationDuration.swift",
        "LittleMoments/Core/Audio/SoundManager.swift",
        "LittleMoments/Core/Session/MeditationSessionController.swift",
        "LittleMoments/Core/SessionHistory/SessionHistoryEntry.swift",
        "LittleMoments/Core/SessionHistory/SessionHistoryStore.swift",
      ],
      resources: [
        "LittleMoments/Resources/Assets.xcassets",
        "LittleMoments/Resources/Sounds/**",
      ],
      entitlements: .file(path: "LittleMoments/App/macOS/LittleMomentsMac.entitlements"),
      dependencies: [
        .sdk(name: "AppKit", type: .framework),
        .sdk(name: "AVFoundation", type: .framework),
        .sdk(name: "SwiftData", type: .framework),
        .sdk(name: "SwiftUI", type: .framework),
      ],
      settings: .settings(
        base: baseSettings,
        configurations: [
          .debug(
            name: "Debug",
            settings: [
              "CODE_SIGN_ENTITLEMENTS": "LittleMoments/App/macOS/LittleMomentsMac.entitlements",
              "CODE_SIGN_IDENTITY": "Apple Development",
              "CODE_SIGN_STYLE": "Automatic",
              "ENABLE_HARDENED_RUNTIME": "YES",
              "PROVISIONING_PROFILE_SPECIFIER": "",
              "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
            ]
          ),
          .release(
            name: "Release",
            settings: [
              "CODE_SIGN_ENTITLEMENTS": "LittleMoments/App/macOS/LittleMomentsMac.entitlements",
              "CODE_SIGN_IDENTITY": "Apple Development",
              "CODE_SIGN_STYLE": "Automatic",
              "ENABLE_HARDENED_RUNTIME": "YES",
              "PROVISIONING_PROFILE_SPECIFIER": "",
            ]
          ),
        ]
      )
    ),
    .target(
      name: "LittleMomentsMacTests",
      destinations: .macOS,
      product: .unitTests,
      bundleId: "net.bomash.illya.LittleMomentsMacTests",
      deploymentTargets: .macOS("26.0"),
      infoPlist: .default,
      sources: ["LittleMoments/Tests/MacTests/**"],
      dependencies: [
        .target(name: "LittleMomentsMac")
      ],
      settings: .settings(
        base: baseSettings.merging([
          "CODE_SIGN_IDENTITY": .string("Apple Development"),
          "CODE_SIGN_STYLE": .string("Automatic"),
          "PROVISIONING_PROFILE_SPECIFIER": .string(""),
          "SWIFT_STRICT_CONCURRENCY": .string("minimal"),
        ]) { $1 }
      )
    ),
  ],
  schemes: [
    .scheme(
      name: "LittleMoments",
      shared: true,
      buildAction: .buildAction(targets: ["LittleMoments"]),
      testAction: .targets(
        ["LittleMomentsTests"],
        configuration: .debug,
        options: .options(coverage: true, codeCoverageTargets: ["LittleMoments"])
      ),
      runAction: .runAction(configuration: .debug),
      archiveAction: .archiveAction(configuration: .release),
      profileAction: .profileAction(configuration: .release),
      analyzeAction: .analyzeAction(configuration: .debug)
    ),
    .scheme(
      name: "LittleMoments-UI",
      shared: true,
      buildAction: .buildAction(targets: ["LittleMoments"]),
      testAction: .targets(
        ["LittleMomentsUITests"],
        configuration: .debug,
        options: .options(coverage: false)
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
    .scheme(
      name: "LittleMomentsMac",
      shared: true,
      buildAction: .buildAction(targets: ["LittleMomentsMac"]),
      testAction: .targets(
        ["LittleMomentsMacTests"],
        configuration: .debug,
        options: .options(coverage: true, codeCoverageTargets: ["LittleMomentsMac"])
      ),
      runAction: .runAction(configuration: .debug),
      archiveAction: .archiveAction(configuration: .release),
      profileAction: .profileAction(configuration: .release),
      analyzeAction: .analyzeAction(configuration: .debug)
    ),
  ]
)
// swiftlint:enable trailing_comma
