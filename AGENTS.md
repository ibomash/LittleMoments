# AGENTS.md

## Build & Test — Quickstart

> Always use Fastlane lanes (never call `tuist`/`bundle exec` directly).

```sh
# Generate project (required first step)
fastlane generate
# Format + lint (all files)
fastlane format_code && fastlane lint
# Run tests (all)
fastlane test
# Full quality gate (format → lint → tests → build)
fastlane quality_check
````

### Fast, file-scoped loops (use for small diffs)

```sh
# Format only changed paths (glob or file path)
fastlane format path:"LittleMoments/Features/Timer/*.swift"

# Lint only changed paths
fastlane lint path:"LittleMoments/Features/Timer/*.swift"

# Run a subset of tests (preferred)
fastlane test_targets targets:"LittleMomentsTests,LittleMomentsUITests"
# or, if using test plans:
fastlane test_plan plan:"Default"
```

> If a lane doesn’t exist yet, prefer adding it rather than calling tools directly.

## Repo Map (where things live)

* `LittleMoments/App/iOS/` — App entry
* `LittleMoments/Core/` — State, audio, health
* `LittleMoments/Features/` — Timer, settings, live activity, shared UI
* `LittleMoments/Resources/` — Assets/sounds
* `LittleMoments/WidgetExtension/` — Live Activity widget
* `LittleMoments/Tests/` — Unit/UI tests
* `backlog/docs/` — Product requirements (PRDs managed by Backlog.md)

## Conventions

* **Formatter:** `swift-format` (via lanes).
* **Linter:** `SwiftLint` strict; fix new violations before commit.
* **Language/tooling versions:**

  * Xcode: **(pin here, e.g., 16.x)**
  * Swift: **(e.g., 6.0)**
  * iOS minimum: **(e.g., 17.0)**
  * SwiftFormat: **(version)**
  * SwiftLint: **(version)**
* **Commit style:** Conventional commits (`type(scope): description`). Keep title ≤72 chars.

## Testing

* Default simulator: **iPhone 16** (set in lanes).
* Targets: `LittleMomentsTests` (unit), `LittleMomentsUITests` (UI).
* Coverage: enabled for app target.
* **Add/update tests for any behavior change in the same PR** (enforced by checklist).
* **Device-only checks:** Live Activities, notifications, HealthKit write path.

## Security & Data

* **Do not** commit secrets, tokens, or personal data.
* **Do not** change signing settings, provisioning profiles, or bundle IDs.
* **HealthKit:** write mindful minutes; never log PHI; respect user settings; disable writes when off.
* Input validation: sanitize user input; avoid force-unwraps on external data.

## Architecture (skim, then see docs)

* `AppState` (singleton) — global UI state (timer, settings visibility).
* `TimerViewModel` — session timing, background tasks, HealthKit pathway.
* `LiveActivityManager` — Lock Screen/Dynamic Island lifecycle and deep links.
* `JustNowSettings` — user prefs (HealthKit, Live Activities, display).
* `SoundManager` — bell audio + session audio policy.
* `HealthKitManager` — writes mindful sessions.

> Details and diagrams: `docs/architecture.md`.

## PR Checklist (Definition of Done)

* [ ] `fastlane format_code` and `fastlane lint` clean (or `format/lint path:` for narrow diffs).
* [ ] Tests pass (`fastlane test` or narrowed `test_targets`/`test_plan`), and **new/updated tests** cover changes.
* [ ] If feature logic changed, **planning docs updated** under `backlog/docs/` (via `backlog doc create/update`) or explicitly confirmed unchanged in PR.
* [ ] No secrets committed; signing/bundle IDs untouched.

## Specs

* New PRDs: run `backlog doc create "Feature: Name"` and mirror the structure used in existing specs under `backlog/docs/`.
* Keep spec and code in sync; mention spec update status in PR body.

## Troubleshooting (agent playbook)

* Stale builds: delete DerivedData or use a clean-build lane.
* Simulator wedged: `xcrun simctl shutdown all && xcrun simctl erase all`.
* Live Activities not showing in sim: prefer device run.
* UI test flake: add explicit waits for async UI; avoid sleep.
* Tuist not picked up: re-run `fastlane generate`.
* HealthKit path: guard device checks; never write in sim.

## Tooling notes

* Use `apple_docs_sosumi` for Apple docs (Markdown mirror of developer.apple.com).
* Agents should prefer the lanes above to external commands.

## Backlog.md

* Planning lives in `backlog/` managed by Backlog.md; columns are Now → Next → Later → Done (default `Next`).
* If it's not on the $PATH, on macOS, the backlog executable lives in `/opt/homebrew/bin/backlog`.
* Use `backlog tasks create …` to add work and `backlog board view` to inspect the Kanban board.
* Update status/AC via `backlog tasks edit …` (never hand-edit task markdown).
* Labels to use: documentation, ui. Create others if needed and update `AGENTS.md`.
* When planning bigger chunks of work, use an "epic" parent task with sub-tasks.
* For full workflow details, follow the "Backlog.md workflow" section in `README.md` and the upstream Backlog.md docs.
* When you complete a task, mark it as Done and update any relevant docs.
