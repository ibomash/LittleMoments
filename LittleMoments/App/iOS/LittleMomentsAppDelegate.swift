import UIKit

final class LittleMomentsAppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
    configuration.delegateClass = LittleMomentsSceneDelegate.self
    return configuration
  }

  func application(
    _ application: UIApplication,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    Task { @MainActor in
      completionHandler(LittleMomentsApp.handleHomeScreenQuickAction(shortcutItem))
    }
  }
}

final class LittleMomentsSceneDelegate: NSObject, UIWindowSceneDelegate {
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let shortcutItem = connectionOptions.shortcutItem else { return }
    Task { @MainActor in
      _ = LittleMomentsApp.handleHomeScreenQuickAction(shortcutItem)
    }
  }

  func windowScene(
    _ windowScene: UIWindowScene,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    Task { @MainActor in
      completionHandler(LittleMomentsApp.handleHomeScreenQuickAction(shortcutItem))
    }
  }
}
