---
id: doc-24
title: 'Feature: Custom Meditation Duration'
type: specification
created_date: '2026-06-09 14:25'
updated_date: '2026-06-09 14:57'
tags:
  - feature
  - spec
---
# Feature: Custom Meditation Duration

## Overview

### Problem Statement
The app currently makes timed sessions available through a small set of preset timer chips. Users who want a precise meditation length—such as 7 minutes, 22 minutes, 75 minutes, or a 2-hour sit—must either choose the nearest preset or rely on external tooling. This creates friction for deliberate practice and for Shortcuts that already support a custom duration parameter.

### Intended Impact
Add an optional custom-duration screen that keeps the default “tap Start and begin” flow fast while giving users a calm, precise way to set a meditation duration. The slider should cover 1 minute through 2 hours for quick selection, while typed entry and Shortcuts should allow longer positive whole-minute durations when users intentionally need them. The design should feel native to the existing Liquid Glass visual language, work during an active session, and use the same duration model across in-app controls, long-press start, deep links, widgets/controls, and Shortcuts/App Intents.

### Background Context
The current app already has the core pieces needed for this feature:

- `TimerStartView` has a primary start button that donates `MeditationSessionIntent` and presents `TimerRunningView`.
- `AppState.pendingStartDurationSeconds` already carries an optional duration into `TimerRunningView`.
- `TimerRunningView` applies the pending duration after it starts, then clears it.
- `BellControlsGrid` currently renders scheduled duration options in a 4-column chip grid.
- `MeditationSessionIntent` has an optional `durationMinutes` parameter, but it should be tightened to share the same bounds and validation as the new UI.

## Goals and Success Metrics

### Primary Goals
1. Preserve the fastest path: tapping Start still begins an untimed session immediately.
2. Add a discoverable long-press path from Start to a custom duration screen.
3. Add a running-session control in the final timer-chip slot so users can set or adjust the end target while meditating.
4. Normalize duration handling so slider input clamps to 1–120 minutes, while typed input, deep links, and Shortcuts validate positive whole-minute values without imposing a 2-hour maximum.
5. Provide clear tactile, visual, and accessibility feedback when a custom duration is opened, applied, adjusted, or cleared.

### Success Metrics
- Users can set any whole-minute duration from 1 to 120 minutes with the slider, or type longer positive whole-minute durations without leaving the meditation flow.
- A custom duration can be entered with either a slider or text input and both stay synchronized.
- Shortcuts with a custom duration produce the same timer state as the in-app custom screen.
- UI tests can identify and exercise the Start long-press entry point, running-session custom chip, typed duration field, slider, sheet apply action, and active-chip clear behavior.

### Non-goals
- Second-level custom precision for production UI. Simulator-only test presets may continue to use second-level durations.
- Multiple saved custom presets.
- Full scheduling templates or interval-bell configuration.
- Replacing the existing preset timer chips.

## Experience Design

### Screen Form Factor
Use a sheet rather than a full-screen replacement so the feature feels optional and reversible:

- **From Start screen:** present a bottom sheet with medium and large detents. The medium detent should be the default on iPhone portrait so users can set a duration and start without losing context.
- **From Timer Running screen:** present the same sheet over the running timer. The timer remains active unless the user explicitly applies a new target, clears the target, cancels the sheet, completes the session, or cancels the session.
- **iPad / landscape:** allow the sheet to size comfortably as a centered form or large detent while preserving a visible running timer in the background when possible.

### Layout and Spacing
Use a single, focused vertical layout with generous spacing:

1. **Header block**
   - Title: “Custom duration”.
   - Subtitle: “Choose when the bell should end this session.”
   - Optional context line on the running screen: “Your timer is still running.”
   - Use 24 pt horizontal padding and 24–32 pt vertical spacing between major groups, aligning with the existing start/running screens.

2. **Large duration readout**
   - Centered prominent text, e.g. “25 min” or “1 hr 30 min”.
   - Use a large rounded rectangle / Liquid Glass card with the accent tint at low opacity.
   - Update live as slider or text input changes.

3. **Slider section**
   - Slider range: 1...120 minutes.
   - Step: 1 minute.
   - Min/max labels: “1 min” and “2 hr”.
   - Include subtle tick labels at helpful milestones if space allows: 15, 30, 60, 90, 120. Avoid dense tick marks that clutter the calm design.
   - Provide haptic selection feedback at meaningful boundaries such as 5-minute increments, 30 minutes, 60 minutes, and 120 minutes.

4. **Text input section**
   - Label: “Minutes”.
   - Numeric text field using `.numberPad`, constrained to whole minutes.
   - Optional stepper with minus/plus controls for one-minute nudges if it does not crowd the sheet.
   - Text entry should accept any positive whole-minute value. Invalid or partial input should not immediately punish the user; validate on commit/apply and show inline guidance.
   - Inline helper/error examples:
     - Normal: “Enter minutes, or use the slider for 1 min–2 hr.”
     - Empty while editing: “Add a duration before applying.”
     - Zero/negative: “Enter at least 1 minute.”

5. **Sheet actions**
   - When opened from the launch/home Start button:
     - Primary: “Start 25 min session”. Applies duration, donates the intent, dismisses the custom-duration sheet, and starts the timer.
     - Secondary: “Cancel”. Dismisses the sheet without starting.
     - Optional tertiary text button: “Start without timer” only if usability testing suggests users need it here; default tap Start already covers this.
   - When opened from the Timer Running screen:
     - Primary: “Set bell for 25 min”. Applies a new end target relative to session start, schedules/updates notification, updates Live Activity, and dismisses the custom-duration sheet.
     - Secondary: “Cancel”. Dismisses the sheet without changes.
     - Clearing an active timer target should happen by tapping the active preset/custom chip again in the timer grid, matching the existing preset-toggle behavior, rather than through a separate sheet action.

### Visual Style
- Reuse existing Liquid Glass button, chip, and surface treatments so the sheet feels native to the app.
- Prefer one accented primary action per screen.
- Keep destructive semantics only for session cancellation, not for clearing a timer target.
- Use semantic colors for feedback:
  - Accent for active/custom timer.
  - Secondary for neutral helper text.
  - System red only for validation errors.
- Respect Reduce Transparency with solid system backgrounds, matching current Liquid Glass wrappers.

### Accessibility
- VoiceOver order: title, explanation, current duration, slider, text input, helper/error text, primary action, secondary actions.
- Slider accessibility value should speak formatted duration, e.g. “25 minutes” or “1 hour 30 minutes”.
- Text field should have an accessibility hint: “Enter a duration in minutes; values over 2 hours are allowed when typed.”
- Dynamic Type: large readout can wrap to two lines; controls should remain reachable without overlapping.
- Button labels should include the selected duration, not only “Apply”.
- Add accessibility identifiers for UI tests:
  - `custom_duration_sheet`
  - `custom_duration_slider`
  - `custom_duration_minutes_field`
  - `custom_duration_apply_button`
  - `custom_duration_cancel_button`
  - `custom_duration_running_chip`

## App Integration Design

### Start Screen Entry Point
The Start button keeps its existing tap behavior:

1. Tap Start → immediately start an untimed session.
2. Long-press Start → open the custom duration sheet.
3. Sheet primary action → set `AppState.pendingStartDurationSeconds`, donate `MeditationSessionIntent(durationMinutes:)`, and present `TimerRunningView`.

Recommended interaction details:

- Add a subtle hint around the Start control, such as a context menu preview title or accessibility hint: “Long-press to set a custom duration.”
- Use `onLongPressGesture` or a `contextMenu`-backed interaction only if it does not interfere with normal tap responsiveness. The implementation must ensure a long press does not also trigger the immediate Start action.
- Provide light haptic feedback when the custom sheet opens.

### Timer Running Entry Point
Reserve the final timer-chip slot for custom duration:

- Keep the 4-column grid shape, but treat the bottom-right slot as a dedicated “Custom” control.
- The existing preset list should become seven visible presets plus one custom chip: 5, 10, 15, 20, 30, 45, 60, Custom. This removes the current 1-minute preset because very short custom sessions remain available through typed entry and the slider, while the grid keeps more useful longer-session presets.
- Custom chip states:
  - No custom target: label “Custom” with `slider.horizontal.3` or `timer` symbol.
  - Active custom target: label the formatted duration, e.g. “75 min”, with selected chip styling.
  - Recently applied: brief checkmark/success feedback or haptic confirmation.
- Tapping Custom opens the custom duration sheet over the running timer.
- Applying from the sheet should update the same scheduled alert pathway as presets, including local notification rescheduling, timer progress target, and Live Activity updates.

### Duration Model
Create one shared value type or utility to avoid divergent validation:

- Name suggestion: `MeditationDuration` or `TimerDuration`.
- Bounds: `minimumMinutes = 1` globally. Slider-specific bounds are `sliderMinimumMinutes = 1` and `sliderMaximumMinutes = 120`; typed, deep-link, and Shortcut values may exceed 120 when they are positive whole minutes.
- Storage: whole minutes for user-facing UI; seconds for `TimerViewModel` and notifications.
- Formatting:
  - 1 minute → “1 min” / “1 minute” for accessibility.
  - 59 minutes → “59 min”.
  - 60 minutes → “1 hr”.
  - 90 minutes → “1 hr 30 min”.
  - 120 minutes → “2 hr”.
  - 150 minutes → “2 hr 30 min”.
- Parsing:
  - Accept digits only in v1.
  - Trim whitespace.
  - Clamp slider values to 1...120; validate typed values as positive whole minutes before applying, with no upper cap.

### TimerViewModel and Notification Flow
Introduce a single method for setting a timed end target, then call it from presets, custom sheet, pending start duration, and intents:

- Suggested API: `setDurationTarget(minutes:source:)` or `applyDuration(seconds:source:)`.
- Responsibilities:
  - Update `scheduledAlert` or replace it with a more general selected-duration state.
  - Schedule or reschedule `timerNotification` unless system integrations are disabled.
  - Update Live Activity with the target duration so the Lock Screen/Dynamic Island can show progress consistently.
  - Provide completion feedback only when the session ends, not when a duration is merely set.

Because the current model uses `OneTimeScheduledBellAlert`, implementation can either:

1. Extend `OneTimeScheduledBellAlert` to represent arbitrary minute values and custom labels, or
2. Introduce a neutral `TimerTarget` model and adapt presets/custom durations to it.

Option 2 is cleaner long-term because it separates “preset button option” from “currently selected target,” but Option 1 is a lower-risk migration if this feature should be small.

### Shortcut / Intent Integration
Unify the existing Shortcuts parameter with the new validation model:

- Keep a single discoverable `MeditationSessionIntent` with optional `durationMinutes`.
- Add a lower-bound parameter constraint if App Intents supports the desired validation/UX on the deployment target; otherwise manually validate in `perform()`. Do not add an upper-bound constraint of 120 minutes.
- Behavior:
  - Missing duration → start untimed session.
  - Positive whole-minute duration → set pending duration and start session, including values greater than 120 minutes.
  - Less than 1 → reject with a friendly intent error.
- Update App Shortcut phrases and descriptions to make custom duration discoverable, e.g. “Start a timed meditation in Little Moments.”
- Widget/control open intents that remain hidden from Shortcuts can optionally accept a duration in future, but the user-facing custom-duration Shortcut should remain `MeditationSessionIntent` to avoid duplicate actions.

### Deep Links and Widgets
If deep links or widgets pass duration through `AppState.pendingStartDurationSeconds`, route them through the same shared validator before setting pending state. The app should never start with a silent invalid target.

## User Flows

### Flow A: Default Start
1. User taps Start.
2. App donates an untimed meditation intent.
3. Running timer opens immediately.
4. No scheduled end target is selected.

### Flow B: Long-Press Custom Start
1. User long-presses Start.
2. Custom duration sheet opens with a sensible default, e.g. last custom duration if stored, otherwise 10 minutes.
3. User drags slider to 25 minutes or types 25.
4. User taps “Start 25 min session”.
5. Sheet dismisses, running timer opens, 25-minute target is applied, notification and Live Activity target are updated.

### Flow C: Adjust While Running
1. User starts an untimed or preset session.
2. User taps the bottom-right Custom chip.
3. Sheet opens over the running timer.
4. User sets 75 minutes.
5. User taps “Set bell for 1 hr 15 min”.
6. Custom chip becomes selected with the formatted value and the timer progress target updates.

### Flow D: Shortcut Custom Duration
1. User runs “Start Meditation Session” from Shortcuts with Duration = 45.
2. Intent validates 45 minutes.
3. App foregrounds and opens the running timer.
4. The same 45-minute target is applied as if chosen in the custom sheet.

## Edge Cases

- **Long-press then cancel:** no session starts and pending duration remains unchanged.
- **Typed empty value:** disable Apply and show helper text.
- **Typed 0 or negative:** show validation error; do not apply.
- **Shortcut invalid duration:** return an intent failure message rather than starting with an unexpected duration.
- **Apply while timer is already complete:** either restart target calculations from session start only if the session is still active, or disable custom changes once `timerViewModel.isDone` is true.
- **Preset selected after custom:** preset chip becomes selected and custom chip returns to neutral state.
- **Custom selected after preset:** preset selection clears and custom chip becomes selected.
- **Notifications disabled:** app still tracks visual target; notification scheduling fails gracefully with existing non-blocking behavior.
- **Reduce Motion / Reduce Transparency:** avoid relying solely on animation/glass blur for feedback.

## Implementation Plan

### Phase 1: Shared Duration Model
- Add a shared duration utility/model with bounds, seconds conversion, formatting, and parsing.
- Add unit tests for bounds, formatting, and typed input validation.

### Phase 2: Custom Duration Sheet
- Build a reusable SwiftUI sheet view that accepts mode: `.start` or `.running`.
- Wire slider and text input to the same draft duration state.
- Add validation, accessibility identifiers, and Dynamic Type-friendly layout.

### Phase 3: Start Screen Integration
- Add Start long-press behavior and accessibility hint.
- On apply, set pending duration, donate the typed-duration intent, and start the running timer.
- Add UI tests for long-press entry and apply/cancel behavior.

### Phase 4: Running Timer Integration
- Reserve the last chip slot for Custom.
- Refactor preset/custom application into one TimerViewModel duration-target method.
- Add selected/confirmed feedback for the custom chip.
- Add UI tests for opening the custom sheet while running and applying/clearing a target.

### Phase 5: Shortcuts and Deep-Link Validation
- Apply shared validation in `MeditationSessionIntent.perform()`.
- Update Shortcuts descriptions/phrases if needed.
- Ensure deep-link/widget/custom intent duration paths call the same duration normalization.
- Add unit tests for valid, missing, and invalid intent durations where possible.

## Testing Plan

### Unit Tests
- Duration formatter covers 1, 5, 59, 60, 75, 90, 120, and 150 minutes.
- Parser rejects empty, non-numeric, zero, and negative values while accepting values over 120.
- Intent validation accepts nil and any positive whole-minute duration, including values over 120, and rejects non-positive values.
- TimerViewModel custom target selection clears preset state and vice versa.

### UI Tests
- Default tap Start still starts immediately.
- Long-press Start opens `custom_duration_sheet`.
- Slider and text field remain synchronized.
- Applying a custom start duration opens the running timer with the custom target selected.
- Running-screen bottom-right chip opens the sheet.
- Tapping the active custom chip again clears the custom target and returns the timer to the untimed visual state.

### Device-Only Checks
- Local notification fires for a custom duration.
- Live Activity reflects custom progress and completion.
- Shortcuts/Siri invocation with a duration foregrounds the app and starts the correctly timed session.

## Open Questions

1. Should the app remember the last custom duration as the sheet default? Recommendation: yes, store only the last minute value locally, not session history metadata.
2. Which preset should be removed to reserve the last grid slot for Custom? Decision: remove the 1-minute preset and keep 5, 10, 15, 20, 30, 45, and 60 minutes plus Custom.
3. Should applying a custom duration while running schedule the bell relative to session start or from the current moment? Recommendation: relative to session start, matching current preset semantics. If the chosen duration has already elapsed, show an inline warning and require a future duration.
4. Should invalid Shortcut durations clamp or fail? Recommendation: fail for non-positive values with a clear message, because silent clamping could surprise automation users. Do not clamp valid positive durations down to 120 minutes.
