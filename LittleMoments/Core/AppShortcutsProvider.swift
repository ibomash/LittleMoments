import AppIntents

// App Shortcuts with synonym phrases for discovery and Siri
struct LittleMomentsShortcuts: AppShortcutsProvider {
  static var shortcutTileColor: ShortcutTileColor { .teal }

  @AppShortcutsBuilder
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: MeditationSessionIntent(),
      phrases: [
        "Start meditation in \(.applicationName)",
        "Begin meditation in \(.applicationName)",
        "Meditate in \(.applicationName)",
        "Start an untimed meditation in \(.applicationName)",
      ],
      shortTitle: "Start Meditation",
      systemImageName: "play.circle.fill"
    )
  }
}
