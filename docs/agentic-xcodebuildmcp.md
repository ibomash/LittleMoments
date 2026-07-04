# Agentic XcodeBuildMCP Guide

This repo is still CLI-first. Use `bin/fastlane` lanes for official quality gates, formatting, linting, and tests. Use XcodeBuildMCP when an agent needs structured Xcode context, simulator interaction, app launch logs, screenshots, accessibility snapshots, or debugger access.

## Local Setup

- Generate the Xcode project first: `bin/fastlane generate`.
- Codex project config lives in `.codex/config.toml`.
- XcodeBuildMCP repo defaults live in `.xcodebuildmcp/config.yaml`.
- OpenCode config lives in `opencode.jsonc`; VS Code MCP config lives in `.vscode/mcp.json`.
- Default app scheme: `LittleMoments`.
- UI test scheme: `LittleMoments-UI`.
- Widget scheme: `LittleMomentsWidgetExtension`.
- Default simulator: `iPhone 17 Pro`.
- Default bundle id: `net.bomash.illya.LittleMoments`.

## Agent Workflow

Before any XcodeBuildMCP build, run, or test call:

1. Call `session_show_defaults`.
2. If defaults are missing or stale, use the repo values from `.xcodebuildmcp/config.yaml`.
3. Prefer the `LittleMoments` scheme for app smoke tests and unit-focused work.
4. Prefer the `LittleMoments-UI` scheme for UI test runs.

## What To Use XcodeBuildMCP For

- Discover schemes, build settings, bundle ids, and generated project state after `bin/fastlane generate`.
- Build, install, and launch the app on the default simulator for a smoke test.
- Capture runtime logs after launch and inspect app-specific failures.
- Take screenshots and UI snapshots before and after visual changes.
- Drive short UI flows with accessibility element references instead of guessed coordinates.
- Attach LLDB when a simulator crash, hang, or state bug needs live inspection.
- Query coverage from `.xcresult` bundles after tests.
- Use the Xcode IDE bridge for SwiftUI previews, Issue Navigator queries, and documentation search when Xcode 26.3+ is open and has approved bridge prompts.

## Common Task Routing

- Use Fastlane for official quality gates and anything that should match CI: formatting, linting, full test runs, and full build checks.
- Use the simulator MCP tools for runtime app work: build-run smoke tests, launch arguments, screenshots, accessibility snapshots, short UI flows, app logs, LLDB attach, and coverage reports from `.xcresult` bundles.
- Use the Xcode IDE bridge when the question is specifically about the open Xcode workspace: current editor state, project navigator paths, Issue Navigator contents, recent Xcode build logs, SwiftUI preview rendering, Apple documentation search from Xcode, or enumerating tests from the active scheme/test plan.
- Use normal shell tools such as `rg`, `sed`, and `git diff` for repository-wide text inspection. They are faster and less stateful than the IDE bridge when Xcode context is not needed.
- Use Codex file editing (`apply_patch`) for source changes by default. The bridge exposes write/edit/remove tools, but prefer them only when the user explicitly wants Xcode project-navigator editing or when the Xcode project structure must be updated through the IDE bridge.
- Use `GetTestList` to discover exact `targetName` and `identifier` values before calling `RunSomeTests`. Treat bridge test runs as interactive IDE checks; keep Fastlane as the authoritative test path for commits.
- Use `RenderPreview` for SwiftUI preview snapshots when Xcode is open and the preview target is already in a good state. Use simulator screenshots for actual runtime flows.

## Xcode IDE Bridge Notes

- First bridge use may trigger an Xcode permission prompt. If `xcode_ide_list_tools` times out or reports zero tools, ask the user to approve the prompt in Xcode and retry.
- Start with `xcode_ide_list_tools(refresh: true)` to confirm bridge availability and discover exact remote tool names.
- Call `XcodeListWindows` before workspace-specific bridge tools. Use the `tabIdentifier` whose `workspacePath` matches this checkout; this repo may be open from more than one path.
- Bridge file paths are Xcode project-navigator paths, not filesystem paths. Use `XcodeGlob` or `XcodeLS` to find the project path before `XcodeRead`, `XcodeGrep`, or edit-oriented bridge tools.
- `GetBuildLog` only reports a recent Xcode IDE build. If no IDE build has run, a "Could not find a recent build log" response is normal and does not mean the bridge is broken.
- Some bridge calls return an empty MCP `content` array while writing the useful structured response to a `rawResponseJsonPath`. Read that artifact when the wrapper response is sparse.
- Documentation search through the IDE bridge is convenient when already in Xcode, but `apple_docs_sosumi` remains the default Apple docs source for agent answers that need citations or stable Markdown output.

## What To Keep In Fastlane

- `bin/fastlane format_code` and scoped `path:` variants.
- `bin/fastlane lint` and scoped `path:` variants.
- `bin/fastlane test`, `test_targets`, and `test_plan`.
- `bin/fastlane quality_check`.
- Any Tuist invocation; agents should call Fastlane lanes rather than calling `tuist` directly.

## Visual QA Loop

For UI, styling, Liquid Glass, timer screen, settings, and live-activity-adjacent changes:

1. Generate the project with Fastlane if needed.
2. Build and run through XcodeBuildMCP on `iPhone 17 Pro`.
3. Capture a screenshot.
4. Capture a UI snapshot and verify accessibility labels and tappable controls.
5. Exercise the changed flow with taps, swipes, typing, and waits.
6. Run the narrowest relevant Fastlane tests.

## Guardrails

- Do not change signing settings, provisioning profiles, bundle ids, or teams.
- Do not erase all simulators unless the user explicitly asks.
- Do not use HealthKit write paths in simulator smoke tests.
- Prefer device checks for Live Activities, notifications, and HealthKit write behavior.
- Never log PHI or secrets from runtime logs.
