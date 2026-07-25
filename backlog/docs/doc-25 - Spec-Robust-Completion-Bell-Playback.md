---
id: doc-25
title: 'Spec: Robust Completion Bell Playback'
type: spec
created_date: '2026-06-23 15:56'
---

# Spec: Robust Completion Bell Playback

## Problem

The completion bell is currently best-effort:

- If the app is foregrounded and the timer view is alive, `OneTimeScheduledBellAlert.checkTrigger` calls `SoundManager.playSound()`.
- If the app is backgrounded, `TimerViewModel.scheduleTimerNotification` schedules a local notification with the bell sound.
- The notification path depends on notification authorization, notification delivery timing, Focus / notification settings, and whether the device will audibly play notification sounds.

The desired behavior is a more robust end-of-session bell, especially when the screen is locked or the app is not foregrounded, while preserving Little Moments' deliberately simple timer model: no pause, no rewind, no skip, and no maintenance-heavy state synchronization.

## Current Code Findings

- `SoundManager` is a static foreground-oriented wrapper around `AVAudioPlayer`.
- `SoundManager.initialize()` sets `AVAudioSession` to `.playback`, but does not activate the session with `setActive`.
- `Little-Moments-Info.plist` currently declares `UIBackgroundModes = ["remote-notification"]`; it does not declare `audio`.
- `TimerViewModel` treats a duration as an absolute target measured from the meditation `startDate`, not as a delay from the moment the user taps the chip.
- `setDurationTarget(seconds:)` reschedules the local notification using `targetTimeInSec - secondsElapsed`.
- `OneTimeScheduledBellAlert.hasTriggered` only prevents repeated foreground timer-triggered bells for the current alert instance. If the user changes from a completed target to a later target, a new alert can ring later.
- Start-with-duration is currently applied in `TimerRunningView.onAppear` after a short `DispatchQueue.main.asyncAfter` delay, which matters if playback planning needs a target at session start.
- Existing planning in `doc-24` already recommends that running-session duration changes stay relative to session start.

## Apple Platform Notes

Relevant Apple guidance:

- Apple says the default iOS audio session is silenced by the Ring/Silent switch and by device lock. The `.playback` category changes that behavior for media playback apps, and background audio requires the Audio, AirPlay, and Picture in Picture background mode. Source: https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/MediaPlaybackGuide/Contents/Resources/en.lproj/ConfiguringAudioSettings/ConfiguringAudioSettings.html
- Apple's audio category table says `.playback` is not silenced by Ring/Silent or screen lock, but also notes that continuing audio while locked requires the `UIBackgroundModes` `audio` key in addition to the category. Source: https://developer.apple.com/library/archive/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/AudioSessionCategoriesandModes/AudioSessionCategoriesandModes.html
- Apple recommends deferring audio session activation until playback begins, so the app does not unnecessarily interrupt other audio. Source: same Media Playback Programming Guide page above.
- Audio interruptions can stop playback; the app must save state and reactivate/resume only when appropriate. Source: https://developer.apple.com/library/archive/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/HandlingAudioInterruptions/HandlingAudioInterruptions.html
- App Review Guideline 2.5.4 says background services may only be used for their intended purposes, including audio playback and local notifications. Source: https://developer.apple.com/app-store/review/guidelines/

Interpretation: background audio could plausibly make the bell more robust, but it should be treated as real user-visible meditation audio playback, not as a hidden keep-alive trick. The silent portion needs review and device validation.

## Candidate Options

### Option A: Tighten Current Notification Path

Keep local notifications as the primary background bell path.

Pros:

- Smallest code change.
- No background-audio mode or App Review ambiguity.
- No lock-screen media controls.

Cons:

- Does not solve the core fragility: notifications can be denied, silenced, delayed, or suppressed.
- Time Sensitive helps Focus delivery but does not make the sound independent of notification sound behavior.

Recommendation: keep this as fallback, not the main robustness strategy.

### Option B: Continuous Meditation Audio Timeline

When a timed session exists, start a playback timeline:

1. Optional start bell.
2. Silent meditation audio for the remaining time.
3. Completion bell.

Pros:

- Matches the user's proposed mental model.
- Uses iOS media playback behavior rather than notification behavior.
- The timer remains a simple elapsed-time model; playback is a projection of timer state.

Cons / unknowns:

- Requires `UIBackgroundModes` `audio`.
- Silent audio may raise product/App Review questions unless presented honestly as meditation playback.
- May create lock-screen / Control Center media UI or remote commands.
- Needs explicit handling for interruptions, route changes, and user/system audio conflicts.
- Dynamic duration updates require careful replanning without creating a second source of truth.

Recommendation: best candidate, but only after a device spike proves the platform behavior.

### Option C: Hybrid Notification + Audio Coordinator

Use a dedicated playback coordinator for timed sessions, but keep the local notification as a fallback. Timer state remains authoritative; notification and audio playback are both derived from it.

Pros:

- Most robust if audio works.
- Provides graceful degradation if audio session setup fails or the app is interrupted.
- Avoids replacing all existing alert behavior in one risky move.

Cons:

- More moving parts than Option B alone.
- Needs strict boundaries so audio, notifications, Live Activities, and timer state do not each become partial owners of completion.

Recommendation: likely implementation direction after the spike.

## Proposed Architecture

Introduce a small `BellPlaybackCoordinator` or `MeditationPlaybackCoordinator`.

Principles:

- `TimerViewModel` remains the source of truth for `startDate`, elapsed time, and the selected target.
- The playback coordinator owns only audio-session state and the currently planned playback timeline.
- Duration changes call one shared method in `TimerViewModel`, which then updates three projections: local notification, Live Activity, and playback plan.
- The coordinator never exposes pause, rewind, skip, or remote transport controls as app behavior.
- If the coordinator receives an impossible target, such as a target already in the past, it stops planning audio rather than inventing new timer semantics.

Suggested API sketch:

```swift
@MainActor
protocol BellPlaybackCoordinating {
  func startSession(startDate: Date, ringBellAtStart: Bool)
  func setTarget(secondsFromSessionStart: Int?, elapsedSeconds: TimeInterval)
  func finishSession()
  func cancelSession()
}
```

Timer flow:

- On session start, create a session identity and call `startSession`.
- If a pending start duration exists, apply it synchronously before or during start setup rather than after a delayed closure.
- On preset/custom/deep-link duration changes, call one `setDurationTarget` path.
- On target clear, cancel the planned completion audio and remove the notification.
- On completion/cancel/disappear, stop audio planning and deactivate the audio session if no sound is playing.

## Playback Planning Semantics

The target should stay relative to session start, matching the current model.

Cases:

- Start untimed, no target: optional start bell only. No long-running silent background audio.
- Start with target: optional start bell, then silence for `targetSeconds - elapsed`, then completion bell.
- Add target while foregrounded: start or replan the silent timeline for the remaining time.
- Change target before bell: cancel the previous plan and plan the new remaining time.
- Change target after bell to a later target: plan a new silent timeline for the remaining time and ring again at the later target.
- Change target to a time already elapsed: do not schedule a new bell. The UI should either prevent it or clearly explain that the selected duration has already passed.
- Clear target: stop the planned completion audio and remove pending notification.
- Cancel/complete manually: stop planned audio and notification.

## Implementation Questions

Open technical questions:

- Which playback primitive is simplest and most reliable for "silence, then bell"?
  - `AVQueuePlayer` with generated/packaged silent assets plus the bell.
  - `AVAudioEngine` / `AVAudioPlayerNode` with scheduled silence and bell buffers.
  - `AVAudioPlayer` playing a short silent file in loops with a delegate-triggered bell.
- Can the app avoid visible lock-screen media controls if no `MPNowPlayingInfoCenter` metadata is published and remote commands are disabled?
- If controls appear anyway, can pause/skip commands be disabled enough to preserve the product model?
- Does a silent timeline continue reliably for 5, 30, 60, and 150 minutes on device while locked?
- What happens on Silent switch, Focus, Bluetooth routes, AirPods, phone calls, alarms, Siri, and media server resets?
- How much battery impact does long-running silent playback add?

Product questions:

- Should robust audio playback be optional in Settings, separate from "ring bell at start"?
- Should the app explain that reliable locked-screen bells require audio playback?
- Should the app continue to schedule the notification fallback even when audio playback is active?
- Should changing the duration after an already-fired bell be allowed to ring a later bell? Current behavior and user request imply yes.

App Review is not a blocker for the spike. Keep the implementation honest and user-visible, but defer review-positioning work until device behavior is proven.

## Verification Plan

### Spike

Build the spike on a separate branch with explicit test toggles:

- Add `audio` to `UIBackgroundModes`.
- Start with `AVQueuePlayer` using a packaged or generated silent asset plus the bell. This is the highest-signal first spike because it exercises normal media playback queueing without requiring a custom audio graph.
- Add a small playback coordinator around that implementation path.
- Trigger it only for timed sessions.
- Keep existing notifications as fallback, but gate the fallback behind a debug/test setting so device testing can run audio-only, notification-only, and hybrid modes.
- Add logging for session start, target changes, audio plan start/stop, fallback scheduling, interruption begin/end, route changes, and bell playback.

### Unit Tests

- `TimerViewModel` calls the coordinator when a target is set, changed, cleared, completed, or canceled.
- Remaining-time calculation uses `targetSeconds - secondsElapsed`.
- A target in the past does not schedule playback.
- Changing from completed target A to later target B plans B.
- Clearing target cancels both notification and playback plan.

### Device Tests

These must run on a physical device; the simulator is not enough.

- Screen locked, Silent switch on: timed bell rings.
- Screen locked, app backgrounded: timed bell rings.
- Notifications denied: audio bell still rings.
- Focus enabled: audio bell behavior is understood and documented.
- Bluetooth and AirPods routes: bell rings through expected route.
- Start bell setting off: no start bell, completion bell still rings.
- Duration change before bell: only the newest target rings.
- Duration extension after bell: later bell rings again.
- Cancel before bell: no completion bell.
- Manual complete before bell: no later scheduled bell.
- Phone call or alarm interruption: timer remains coherent; audio recovers or falls back predictably.
- Lock screen / Control Center: no pause, skip, or rewind controls that can alter timer semantics.
- Battery observation for 30- and 60-minute silent playback.

## Recommendation

Proceed with a device spike of Option C: a small playback coordinator plus notification fallback, starting with `AVQueuePlayer` as the implementation path. Do not fold this into `SoundManager` directly; `SoundManager` can become the bell sample loader/player, but the long-running session timeline needs a separate owner.

The key design rule is that playback must remain a derived projection of the timer target. The timer should never ask the audio player what time it is, and media playback controls should never become a second timer control surface.

## Appendix: Playback Primitive Glossary

### `AVQueuePlayer`

A high-level media player that plays a sequence of `AVPlayerItem`s. For this feature, the sequence would be silence followed by the bell, with replanning when the timer target changes. This is the best first spike because it uses ordinary media playback machinery, is relatively small to wire up, and should quickly answer the key device question: can a silent media timeline stay alive in the background and ring at the end?

### `AVAudioEngine` / `AVAudioPlayerNode`

A lower-level audio graph API. It is useful when an app needs precise sample scheduling, mixing, effects, generated audio, or complex routing. It is probably more power than Little Moments needs for the first pass, and it would make the coordinator harder to reason about before we know whether the product idea works on device.

### `AVAudioPlayer` Loop With Delegate

A simple file player that could loop a short silent asset and use delegate callbacks or timers to play the bell. This is easy to understand, but it risks recreating timer-like scheduling inside the audio layer. That is exactly the kind of second source of truth the design should avoid.

### Local Notifications

Not a media playback primitive. Notifications remain useful as a fallback because they are already integrated and cheap to schedule, but they cannot provide the robustness we want when notification sound delivery is disabled, suppressed, delayed, or inaudible.
