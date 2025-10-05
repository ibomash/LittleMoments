---
title: "Liquid Glass Migration PRD"
authors: ["Codex Agent"]
date: 2025-10-05
status: draft
tags: [ui, visual-refresh, liquid-glass]
---

# Liquid Glass Migration PRD

## Summary

Modernize Little Moments for Apple’s Liquid Glass design language by replacing custom backgrounds with system materials, realigning navigation and control layouts, and validating accessibility and performance so the app feels native on the latest Apple platforms.

## Problem Statement

The current UI leans on custom colors and backgrounds (`ImageButton`, `TimerStartView`, `TimerControlButtons`) that sit on top of system bars and sheets. This approach prevents the app from inheriting Liquid Glass behaviors (fluency, adaptive blurs, scroll edge legibility) and risks visual conflicts once we ship against the latest SDK. Settings still relies on `NavigationView`, which doesn’t expose the updated navigation appearance controls. Without a migration plan we risk looking dated, missing accessibility fallbacks, and losing parity with system UI.

## Goals

- Adopt Liquid Glass-responsive controls and navigation with minimal bespoke styling.
- Ensure primary meditation flows (start, run, complete session) remain intuitive while feeling refreshed.
- Document accessibility, performance, and design QA expectations for the migration.
- Provide engineering tasks that can be executed incrementally with clear validation steps.

## Non-Goals

- Redesigning core meditation flows, timers, or notification logic.
- Changing HealthKit, Live Activity, or notification behaviors.
- Shipping a final redesigned app icon (scope limited to defining the work).

## Current State Assessment

- **Buttons and CTAs** — `ImageButton` (`LittleMoments/Features/Shared/ImageButton.swift`) hard-codes `Color.blue` backgrounds and rounded corners. The same styling shows up in `TimerStartView` (`LittleMoments/Features/Timer/Views/TimerStartView.swift`) and `TimerControlButtons` inside `TimerRunningView` (`LittleMoments/Features/Timer/Views/TimerRunningView.swift`), blocking native Liquid Glass effects.
- **Selection grid** — `BellControlsGrid` in `TimerRunningView` toggles selection with manual background swaps between `Color.blue` and `Color(UIColor.systemBackground)`, instead of using system materials or `glassEffect` with semantic tints.
- **Navigation + sheets** — The root timer flow uses `NavigationStack` but hides navigation UI, while Settings relies on deprecated `NavigationView` with `navigationBarItems`, limiting adoption of refreshed toolbars and scroll edge behavior (`LittleMoments/Features/Settings/Views/SettingsView.swift`).
- **Visual hierarchy** — Geometry-driven layouts (e.g., `TimerRunningView` `GeometryReader`) don’t differentiate foreground controls from background content, making it difficult to float Liquid Glass navigation and controls as a separate layer.
- **Assets & widgets** — Widgets apply semi-transparent color fills; they’re outside this PRD’s primary scope but should be audited once core app migration is underway.

## User Experience Requirements

1. **Timer home** — Start CTA, settings gear, and any onboarding surfaces adopt system button styles (`.buttonStyle(.glassProminent)` or similar), with interactions that morph responsively.
2. **Active session** — Timer visualization and grid controls maintain clarity while switching to system materials. Scrollable areas must retain legibility under the Liquid Glass layer, including landscape layout.
3. **Settings** — Modern navigation chrome with `.toolbar` items, Form-appropriate padding, and consistent background transparency with Reduce Motion/Transparency fallbacks.
4. **Iconography** — Document a plan for layered app icon assets compatible with Liquid Glass variants (light, dark, clear, tint).
5. **Accessibility** — Respect Reduce Motion, Reduce Transparency, and larger dynamic type without clipping or awkward morphing.

## Functional Requirements

- **F1**: Replace `ImageButton` with a reusable button style that forwards to `.buttonStyle(.glassProminent)` (primary) or `.buttonStyle(.glass)` (secondary) while supporting semantic `tint` overrides.
- **F2**: Update `TimerStartView` CTA layout to use the new button style and remove manual `.background(Color.blue)` calls.
- **F3**: Introduce a `GlassEffectContainer` wrapping the timer control stack so selected duration buttons blend and morph smoothly; selection state uses `.glassEffect(.regular.tint(.accentColor))` instead of manual backgrounds.
- **F4**: Migrate `SettingsView` to `NavigationStack`, replace `.navigationBarItems` with `.toolbar`, and adopt `FormStyle.grouped` with `scrollContentBackground(.hidden)` only if needed to reveal system material.
- **F5**: Audit sheets (`TimerRunningView`, Settings) to ensure they respect inset half-sheet behavior and remove any custom background overlays.
- **F6**: Define app-wide color and typography tokens using system colors (`Color.accentColor`, `Color.secondary`) to let Liquid Glass adapt to appearance changes.
- **F7**: Produce icon requirements (layer breakdown, asset workflow) and coordinate with design for execution.

## Technical Approach

- Build against the latest Xcode + SDK release that ships Liquid Glass.
- Create a shared `GlassButtonStyle` wrapper to localize adoption and ease fallbacks for earlier OS versions.
- Encapsulate timer grid buttons in a dedicated view that leverages `GlassEffectContainer` plus `glassEffectID` for morphing transitions when selections change.
- Use `.scrollEdgeEffectStyle(.automatic)` on scrollable content hosting floating controls to let the system manage contrast.
- Replace manual color literals (`Color.blue`) with semantic tints exposed via environment (`.tint`, `.foregroundStyle`).
- Ensure sheets use `.presentationDetents` only if product requires; otherwise trust defaults to inherit Liquid Glass material.

## Accessibility & Performance

- Test Reduce Motion, Reduce Transparency, and Bold Text to ensure Liquid Glass fallbacks remain legible.
- Run `fastlane test_targets targets:"LittleMomentsUITests"` focusing on navigation flows to catch regressions.
- Profile using Instruments to confirm `glassEffect` usage doesn’t trigger major GPU spikes; consolidate effects within `GlassEffectContainer` as recommended by Apple.

## Dependencies

- Latest Xcode & SDK supporting Liquid Glass (confirm pinned version once Apple finalizes release).
- Updated SwiftUI APIs (`glassEffect`, `GlassEffectContainer`, `GlassButtonStyle`, `GlassProminentButtonStyle`).
- Design support for icon layering and any refreshed imagery.

## Risks & Mitigations

- **Performance regressions** — Mitigate by grouping effects in containers and capping concurrent Liquid Glass layers.
- **Backward compatibility** — Provide graceful fallbacks when building for older iOS versions (wrap new APIs in availability checks).
- **Design alignment** — Schedule design review checkpoints before implementing custom `glassEffect` configurations.

## Milestones

1. **Foundation (Week 1)** — Update button styles and navigation structures (F1–F4); validate baseline UI on iPhone 16 simulator.
2. **Control polish (Week 2)** — Apply `GlassEffectContainer` to timer grid and tune morphing interactions (F3, F5, F6); run accessibility sweeps.
3. **Asset planning (Week 3)** — Document icon requirements and finalize QA sign-off criteria (F7).

## Acceptance Criteria

- All custom solid-color button backgrounds replaced with Liquid Glass-compatible button styles.
- Navigation and sheets display system Liquid Glass materials with no conflicting overlays.
- Accessibility toggles produce acceptable fallbacks with no clipping or illegible content.
- Icon migration plan documented and linked to a backlog task for execution.
- QA checklist (devices, accessibility settings, performance sampling) completed and attached to the implementation PR.

## Open Questions

- Do we ship fallback themes for users running pre-Liquid Glass OS versions, or maintain a single target?
- Should the meditation timer visualization itself adopt Liquid Glass tinting, or remain opaque for clarity?
- Are widgets expected to inherit Liquid Glass visuals in this release, or follow later once the core app ships?

## References

- Apple: “Adopting Liquid Glass” (Technology Overviews, 2025).
- Apple: “Applying Liquid Glass to custom views” (SwiftUI Documentation, 2025).
