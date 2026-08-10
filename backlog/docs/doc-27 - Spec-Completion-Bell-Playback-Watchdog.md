---

# Spec: Completion Bell Playback Watchdog

## Objective

Add a target-scoped, foreground-only recovery path to robust completion bell playback. `BellPlaybackCoordinator` remains the sole policy owner and robust queue playback remains primary in all states. The recovery path uses `SoundManager` only when queue progress is unconfirmed after a short grace period.

## Existing Flow

- `TimerViewModel` owns the session start date and selected target.
- `BellPlaybackCoordinator.setTarget` activates the audio session, starts looping silence, and schedules an exact-deadline task.
- At the deadline, the coordinator replaces the queue contents with a bell item and calls `play()`.
- `OneTimeScheduledBellAlert` independently runs from a one-second `Timer`, but suppresses its foreground bell whenever robust audio mode is enabled.
- A one-second coordinator diagnostic observes playback state but takes no recovery action.

## Proposed API

Extend `BellPlaybackCoordinating` with a due-bell watchdog entry point:

```swift
func ensureCompletionBellAudible(elapsedSeconds: TimeInterval)
```

`TimerViewModel` calls this when `OneTimeScheduledBellAlert` first detects that its target is due. The coordinator validates the active target and generation before acting.

Production scene activity should be injected behind a closure or small protocol so unit tests do not depend on `UIApplication` global state. Foreground fallback playback should likewise be injected as a closure, defaulting to `SoundManager.playSound()`.

## Coordinator State

Maintain target-scoped state on `MainActor`:

- Active target seconds.
- Target generation UUID.
- Bell item associated with that generation, if primary playback was attempted.
- Whether primary playback progress has been confirmed.
- Whether foreground fallback has already been requested for that generation.
- The completion task and watchdog task.

Changing or clearing a target creates a new generation and cancels both tasks. Session finish/cancel/reset clears all target state.

## Playback Algorithm

### Exact-deadline task

1. Validate the generation and target.
2. Replace the silent queue contents with the bell item.
3. Call `play()` and record that primary playback was attempted.
4. Schedule a watchdog for 500 milliseconds.

### Progress confirmation

At the watchdog deadline, confirm primary playback only when all of the following are true:

- The generation is still current.
- The coordinator still owns the same queue player and bell item.
- The bell item's current playback time is finite and greater than a small threshold (for example, 50 milliseconds).

Player status values are retained in diagnostics, but elapsed playback is the success signal. A status of `playing` without advancing media time is not sufficient.

### Foreground fallback

If progress is unconfirmed:

1. Verify that the application has an active scene.
2. Verify fallback has not already started for this generation.
3. Mark the fallback as started before invoking the player.
4. Reset the foreground player's current time and call `play()`.

Failure to inspect primary progress is treated the same as missing progress. This intentionally favors duplicate bells.

### UI timer watchdog

When the one-second scheduled alert becomes due, it calls `ensureCompletionBellAudible` instead of directly playing or suppressing a foreground sound.

- If primary playback is confirmed, it does nothing.
- If the exact-deadline task has not attempted playback, it initiates the primary transition and watchdog for the current generation.
- If primary playback was attempted long enough ago and remains unconfirmed, it starts the foreground fallback when active.

This method must be idempotent for a target generation.

## SoundManager Hardening

Before foreground fallback playback:

- Stop any existing playback of the bell.
- Set `currentTime` to zero.
- Call `prepareToPlay()` when useful.
- Call `play()` and return whether the request was accepted.

Returning a Boolean allows the coordinator to record whether fallback playback was accepted without treating it as proof of audibility.

## Diagnostics

Add structured events containing the target generation where practical:

- Primary bell attempted.
- Primary progress confirmed.
- Primary progress unconfirmed, including player/item status and waiting reason.
- Foreground fallback skipped because no scene is active.
- Foreground fallback started or rejected.
- Watchdog ignored because its generation is stale.

Diagnostics must not contain personal data.

## Test Plan

### Unit tests

- A queue item that advances beyond the threshold does not invoke fallback.
- A stalled queue item invokes fallback when the scene is active.
- Unknown/indeterminate progress invokes fallback when active.
- An inactive scene does not invoke the foreground fallback.
- Repeated watchdog calls invoke fallback at most once per generation.
- Replacing or clearing the target invalidates the previous watchdog.
- Cancelling/resetting a session invalidates pending fallback work.
- A due UI timer callback reaches the coordinator rather than directly calling `SoundManager`.

Use injected progress inspection and fallback closures for deterministic tests; unit tests should not wait on real `AVPlayer` timing.

### Integration validation

- Foreground simulator: short timer with normal queue progress produces one bell.
- Foreground device: force or simulate unconfirmed progress and verify fallback.
- Locked device: confirm the existing robust bell and notification behavior remains intact.
- Change and clear a duration near its deadline; confirm no stale bell.
- Tap Cancel and Complete near the deadline; confirm invalidated watchdog work does not ring later.

## Implementation Sequence

1. Refactor `SoundManager.playSound()` to restart playback deterministically and report request acceptance.
2. Add coordinator dependencies for scene activity, fallback playback, grace interval, and progress inspection.
3. Track active target/generation and primary bell attempt state.
4. Convert the existing progress diagnostic into the recovery watchdog.
5. Route `OneTimeScheduledBellAlert` through `TimerViewModel` to the coordinator rather than referencing the singleton directly.
6. Add deterministic coordinator and view-model tests.
7. Run file-scoped formatting/linting and relevant tests, followed by `bin/fastlane quality_check`.

## Rollout and Risk

The change does not add a user setting or alter notification authorization. The principal behavior risk is an occasional duplicate foreground bell when primary playback begins too slowly to cross the progress threshold. That outcome is accepted by product policy and should be measured through diagnostics. The fallback grace interval can be tuned later without changing the architecture.

## Completion Criteria

- Implementation matches the target-scoped algorithm above.
- Automated tests cover successful, stalled, inactive, repeated, and stale-generation paths.
- Existing locked-screen playback tests and quality gates pass.
- `doc-25` remains historical context; this spec defines the current recovery policy.

## Implementation Result

Implemented on `codex/foreground-bell-watchdog`:

- Robust queue playback remains the primary path in every playback mode that uses audio.
- The coordinator checks for at least 50 milliseconds of bell-item progress after a 500 millisecond grace period.
- An active foreground scene receives one `SoundManager` fallback per target generation when progress is missing, non-finite, or unobservable.
- The UI timer routes its first due event through `ensureCompletionBellAudible`, allowing it to recover an exact-deadline task that has not yet transitioned the queue.
- Clearing/changing a target and resetting/cancelling a session invalidate stale generations and watchdog tasks.
- Foreground playback restarts from time zero, and robust teardown avoids deactivating the shared audio session underneath an accepted fallback.
- Structured diagnostics report progress, fallback starts, and fallback skip reasons.

Validation completed with `bin/fastlane quality_check`: repository-wide formatting and strict lint passed, 122 unit tests passed, 11 UI tests passed, and the `LittleMoments`, `LittleMoments-UI`, and `LittleMomentsWidgetExtension` schemes built successfully.
id: doc-27
title: 'Spec: Completion Bell Playback Watchdog'
type: spec
created_date: '2026-08-10 19:18'
---
