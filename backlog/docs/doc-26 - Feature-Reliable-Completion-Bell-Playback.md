---

# Feature: Reliable Completion Bell Playback

## Summary

Little Moments should strongly prefer an extra completion bell over a meditation ending silently. Robust queue playback remains the primary completion mechanism in every application state. When the timer scene is active, a short watchdog confirms that the queued bell has actually advanced; if it cannot confirm progress, the app also starts the simpler foreground bell player.

The local notification remains an independent system fallback for inactive, backgrounded, or locked-screen sessions.

## Problem

The robust playback path keeps an `AVQueuePlayer` active with looping silence and replaces that silence with the bell at the selected target. In the default hybrid mode, enabling that path also suppresses the ordinary foreground `AVAudioPlayer` bell.

Calling `AVQueuePlayer.play()` proves only that playback was requested. It does not prove that the new bell item became ready, left its waiting state, advanced, or became audible. The current implementation records progress diagnostics one second later but does not recover when the queue transition stalls. Consequently, one ambiguous queue transition can leave a foreground meditation silent even though a simpler playback path is available.

## Product Principle

For an end-of-meditation cue, a duplicate bell is less harmful than no bell. Deduplication should therefore be based on confirmed playback progress, not on an attempted call to `play()`.

This is deliberately a fail-open policy:

- Confirmed primary playback suppresses the foreground fallback.
- Missing or ambiguous confirmation permits the foreground fallback.
- Near-simultaneous duplicate playback is acceptable.

## Target Behavior

### Timer scene active

1. The robust coordinator transitions its active queue from silence to the completion bell at the exact target.
2. A target-scoped watchdog waits for a short grace interval.
3. If the bell item has made meaningful progress, no fallback is needed.
4. If progress is absent or cannot be confirmed, the foreground bell player starts.
5. The one-second UI timer also asks the coordinator to ensure the due bell is audible, protecting against a delayed or missed completion task.

### App inactive, backgrounded, or locked

The robust queue remains the primary audio path. The scheduled local notification remains the independent system fallback. The foreground watchdog does not rely on application timers while the app is inactive.

### Cancellation, target changes, and manual completion

Every planned target has a generation identifier. Clearing or changing a target, cancelling a session, or manually completing it invalidates the old generation so delayed watchdog work cannot play a stale bell.

## Why This Design

### One queue-only mechanism everywhere

This is simple but makes the silence-to-bell queue transition a single point of failure. It is the current effective foreground policy and does not satisfy the reliability preference.

### Mutually exclusive foreground and background mechanisms

Choosing `AVAudioPlayer` while active and `AVQueuePlayer` while inactive avoids duplicates during stable states, but creates a handoff boundary around scene transitions. A session can change state at the deadline, leaving both mechanisms believing the other is responsible.

### Always play both mechanisms in the foreground

This is the smallest fail-open change, but the UI timer can lag the exact target by nearly a second, producing a clearly separated second bell on every successful session.

### Primary playback plus evidence-based watchdog

This retains one scheduling authority and one primary playback mechanism while using the foreground player only when evidence is missing. It narrows duplicates to ambiguous cases without converting an attempted playback call into a false success signal.

## Success Criteria

- A normally advancing robust bell produces one audible foreground completion cue.
- A stalled or indeterminate robust bell causes a foreground fallback while the timer scene is active.
- A late watchdog from an old target cannot ring after a target change, cancellation, or reset.
- Background and locked-screen behavior continues to use robust playback plus the notification fallback.
- Diagnostics distinguish playback attempted, playback confirmed, fallback requested, and fallback started.

## Related Work

- `doc-25`: original robust completion bell playback design and spike.
- `TASK-8`: lower-overhead robust bell playback investigation.
id: doc-26
title: 'Feature: Reliable Completion Bell Playback'
type: feature
created_date: '2026-08-10 19:18'
---
