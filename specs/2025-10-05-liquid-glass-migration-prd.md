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
- Extend the Liquid Glass refresh to the widget extension so glanceable surfaces stay consistent with the main app.

## Non-Goals

- Redesigning core meditation flows, timers, or notification logic.
- Changing HealthKit, Live Activity, or notification behaviors.
- Shipping a final redesigned app icon (scope limited to defining the work).

## Current State Assessment

- **Buttons and CTAs** — `ImageButton` (`LittleMoments/Features/Shared/ImageButton.swift`) hard-codes `Color.blue` backgrounds and rounded corners. The same styling shows up in `TimerStartView` (`LittleMoments/Features/Timer/Views/TimerStartView.swift`) and `TimerControlButtons` inside `TimerRunningView` (`LittleMoments/Features/Timer/Views/TimerRunningView.swift`), blocking native Liquid Glass effects.
- **Selection grid** — `BellControlsGrid` in `TimerRunningView` toggles selection with manual background swaps between `Color.blue` and `Color(UIColor.systemBackground)`, instead of using system materials or `glassEffect` with semantic tints.
- **Navigation + sheets** — The root timer flow uses `NavigationStack` but hides navigation UI, while Settings relies on deprecated `NavigationView` with `navigationBarItems`, limiting adoption of refreshed toolbars and scroll edge behavior (`LittleMoments/Features/Settings/Views/SettingsView.swift`).
- **Visual hierarchy** — Geometry-driven layouts (e.g., `TimerRunningView` `GeometryReader`) don’t differentiate foreground controls from background content, making it difficult to float Liquid Glass navigation and controls as a separate layer.
- **Assets & widgets** — Widgets apply semi-transparent color fills; we’ll migrate the widget extension to Liquid Glass alongside the core app work.

## User Experience Requirements

1. **Timer home** — Start CTA, settings gear, and any onboarding surfaces adopt system button styles (`.buttonStyle(.glassProminent)` or similar), with interactions that morph responsively.
2. **Active session** — Timer visualization stays opaque for readability while surrounding controls pick up system materials. Scrollable areas must retain legibility under the Liquid Glass layer, including landscape layout.
3. **Settings** — Modern navigation chrome with `.toolbar` items, Form-appropriate padding, and consistent background transparency with Reduce Motion/Transparency fallbacks.
4. **Iconography** — Document a plan for layered app icon assets compatible with Liquid Glass variants (light, dark, clear, tint).
5. **Accessibility** — Respect Reduce Motion, Reduce Transparency, and larger dynamic type without clipping or awkward morphing.

## Functional Requirements

- **F1**: Replace `ImageButton` with a reusable button style that forwards to `.buttonStyle(.glassProminent)` (primary) or `.buttonStyle(.glass)` (secondary) while supporting semantic `tint` overrides.
- **F2**: Update `TimerStartView` CTA layout to use the new button style and remove manual `.background(Color.blue)` calls.
- **F3**: Introduce a `GlassEffectContainer` wrapping the timer control stack so selected duration buttons blend and morph smoothly; selection state uses `.glassEffect(.regular.tint(.accentColor))` instead of manual backgrounds.
- **F4**: Migrate `SettingsView` to `NavigationStack`, replace `.navigationBarItems` with `.toolbar`, and adopt `FormStyle.grouped` with `scrollContentBackground(.hidden)` only if needed to reveal system material.
- **F5**: Present `TimerRunningView` with `.fullScreenCover` to deliver a dedicated full-screen context that avoids swipe-to-dismiss, and surface Settings with `.sheet` using `.presentationDetents([.large])` so it fills the display while retaining standard modal chrome. Remove any custom background overlays in both flows so system Liquid Glass materials control the presentation.
- **F6**: Define app-wide color and typography tokens using system colors (`Color.accentColor`, `Color.secondary`) to let Liquid Glass adapt to appearance changes.
- **F7**: Produce icon requirements (layer breakdown, asset workflow) and coordinate with design for execution.
- **F8**: Update widgets to adopt Liquid Glass-friendly materials and tints consistent with the refreshed app surfaces.

## Technical Approach

- Build against the latest Xcode + SDK release that ships Liquid Glass.
- Target iOS 26 and later exclusively; remove pre-iOS 26 fallbacks from the codebase.
- Create a shared `GlassButtonStyle` wrapper to localize adoption and centralize any availability gating.
- Encapsulate timer grid buttons in a dedicated view that leverages `GlassEffectContainer` plus `glassEffectID` for morphing transitions when selections change.
- Use `.scrollEdgeEffectStyle(.automatic)` on scrollable content hosting floating controls to let the system manage contrast.
- Replace manual color literals (`Color.blue`) with semantic tints exposed via environment (`.tint`, `.foregroundStyle`).
- Present `TimerRunningView` with `.fullScreenCover` to create a dedicated context without drag-to-dismiss, and configure the Settings `.sheet` with `.presentationDetents([.large])` so it reaches full height while retaining system modal chrome—both without reintroducing custom overlays.

## Accessibility & Performance

- Profile using Instruments to confirm `glassEffect` usage doesn’t trigger major GPU spikes; consolidate effects within `GlassEffectContainer` as recommended by Apple.

## Dependencies

- Latest Xcode & SDK supporting Liquid Glass
- Updated SwiftUI APIs (`glassEffect`, `GlassEffectContainer`, `GlassButtonStyle`, `GlassProminentButtonStyle`).
- Deployment baseline of iOS 26 and later (no pre-iOS 26 compatibility paths).
- Design support for icon layering and any refreshed imagery.

## Risks & Mitigations

- **Performance regressions** — Mitigate by grouping effects in containers and capping concurrent Liquid Glass layers.
- **Backward compatibility** — Communicate the iOS 26+ baseline early and gate new APIs with availability annotations for compilation on older SDKs.
- **Design alignment** — Schedule design review checkpoints before implementing custom `glassEffect` configurations.

## Acceptance Criteria

- All custom solid-color button backgrounds replaced with Liquid Glass-compatible button styles.
- Navigation and sheets display system Liquid Glass materials with no conflicting overlays.
- Timer visualization remains opaque while surrounding controls adopt Liquid Glass treatments.
- Accessibility toggles produce acceptable fallbacks with no clipping or illegible content.
- Icon migration plan documented and linked to a backlog task for execution.
- Widget extension surfaces adopt Liquid Glass materials consistent with the refreshed app.
- Deployment target is pinned to iOS 26+, with legacy fallback paths removed.
- QA checklist (devices, accessibility settings, performance sampling) completed and attached to the implementation PR.

## References

- Apple: “Adopting Liquid Glass” (Technology Overviews, 2025).
- Apple: “Applying Liquid Glass to custom views” (SwiftUI Documentation, 2025).
