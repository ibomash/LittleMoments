---
id: doc-23
title: 'Spec: Session History Sync and Asynchronous Health Writes'
type: spec
created_date: '2026-02-23 18:55'
---

# Spec: Session History Sync and Asynchronous Health Writes

## Overview

### Problem Statement
Today session completion attempts to write to HealthKit immediately from the active UI flow. This creates coupling between session completion and Health write success, does not preserve a durable session history queue, and cannot recover if the completing device cannot write to Health.

### Intended Impact
Introduce a durable, synced session history log where every completed session is stored first, then written to Health asynchronously by any device that has write privileges. This makes session completion reliable and enables cross-device Health write recovery.

### Background Context
- `TimerViewModel` currently writes directly to HealthKit on completion.
- `JustNowSettings.writeToHealth` controls whether writes are attempted.
- HealthKit permissions are device-specific; a session completed on one device may need to be written by another device.

## Goals and Success Metrics

### Primary Goals
- Persist every completed session to a cross-device synced history log.
- Mark new entries as `pending_health_write` at creation time.
- Write pending entries to Health asynchronously when a device is eligible.
- Mark entries as `written_to_health` only after successful write or confirmed existing Health record.

### Success Metrics
- 100% of completed (non-canceled) sessions create a history record.
- 0 user-visible blocking during session completion due to HealthKit writes.
- No duplicate mindful sessions in Health for the same session log entry.
- Pending sessions eventually converge to `written_to_health` when at least one device has write privileges.

### Non-goals
- Building analytics/charts UI for history in this phase.
- Reading unrelated Health data types.
- Supporting manual per-session retry controls in UI in this phase.

## Scope

### In Scope
- New session history persistence model and sync.
- New asynchronous Health write pipeline.
- Deduplication check before saving to Health.
- Status tracking per session (`pending` vs `written`).
- Read-only `Settings -> Session History` screen for viewing synced records.

### Out of Scope
- New onboarding flow changes beyond existing Health toggle behavior.
- Changes to signing/bundle identifiers.

## Functional Requirements

1. On session completion (not cancel), create a history entry with:
   - Stable session identifier (UUID)
   - Start date, end date, duration
   - Source device identifier
   - `healthWriteStatus = pending_health_write`
2. Session completion must not block on Health write result.
3. Devices that are Health-write eligible must attempt to process all pending entries.
4. Devices not eligible must not attempt Health writes and must leave entries pending.
5. Before writing a pending session, check whether an equivalent record already exists in Health.
6. If existing Health record is found, mark the session as written without creating a duplicate.
7. If save succeeds, mark the session as written.
8. If save fails due to transient conditions, keep pending and retry later.
9. If save fails due to permission/availability constraints, stop active write loop on that device and leave pending.
10. Sync state changes (`pending` -> `written`) across devices.
11. Settings includes a `Session History` entry point.
12. `Session History` displays records newest first with completion time, duration, and Health write status.
13. `Session History` is read-only in this phase (no edit/delete/manual retry actions).

## Non-functional Requirements

- Reliability: session logging is durable across app relaunches.
- Idempotency: repeated processing attempts do not create duplicate Health entries.
- Performance: queue processing is batched and does not degrade UI responsiveness.
- Privacy: no PHI beyond required mindful session timestamps/duration; no secrets logged.

## Proposed Architecture

### New Components
- `SessionHistoryStore`
  - Owns persisted session records and status updates.
  - Provides query methods for pending records.
  - Implemented with SwiftData and synced via CloudKit private database.
- `HealthWriteCoordinator`
  - Asynchronous worker that processes pending records when device is eligible.
  - Triggered on app launch/foreground, after sync updates, and after local session completion.
- `HealthWriteEligibility`
  - Centralized check for whether this device can write now:
    - Health data available
    - `writeToHealth` enabled
    - Sharing authorization for mindful sessions granted

### Architecture Decision: Sync Technology

Decision: Use SwiftData with CloudKit private database sync for `SessionHistoryStore`.

Rationale:
- Simple: model-first persistence and fetch APIs, minimal sync plumbing.
- Reliable: local-first storage with Apple-managed sync, retries, and conflict handling.
- Actively supported by Apple: first-party path for modern SwiftUI apps.
- Privacy aligned: per-user data lives in each user's private iCloud database.
- No backend required: avoids building and operating custom sync infrastructure.

Alternatives considered:
- Direct CloudKit APIs: most control, but higher implementation complexity and maintenance cost.
- Core Data with `NSPersistentCloudKitContainer`: proven, but more boilerplate than SwiftData for new work.

Consequences:
- Cross-device sync requires iCloud availability and user sign-in.
- Without iCloud sync, entries remain local and still support same-device async Health writes.

### Data Model

`SessionHistoryEntry`
- `id: UUID` (stable cross-device identifier)
- `startDate: Date`
- `endDate: Date`
- `durationSeconds: Int`
- `createdAt: Date`
- `sourceDeviceId: String`
- `healthWriteStatus: enum { pending_health_write, written_to_health }`
- `healthWrittenAt: Date?`
- `lastWriteAttemptAt: Date?`
- `lastWriteErrorCode: String?` (debug/telemetry only)

### Health Deduplication Strategy

- Include a stable sync identifier in Health sample metadata (based on session `id`).
- Before save, query Health for existing mindful session matching this sync identifier.
- If metadata query is unavailable/fails, fall back to conservative time-window check (start/end within tolerance).
- Treat "already exists" as success and mark `written_to_health`.

## User Flow

### Session Completion
1. User completes session.
2. App records `SessionHistoryEntry` as `pending_health_write`.
3. UI flow ends immediately (no waiting for Health write).
4. Background async writer may start if device is eligible.

### Eligible Device Processing
1. Fetch pending entries ordered oldest first.
2. For each entry: dedupe check -> write if needed -> mark written on success.
3. Persist status updates and sync to cloud.

### Ineligible Device Processing
1. Entry still syncs to shared history store.
2. No write attempts are made.
3. Another eligible device processes the same pending entry later.

### Viewing Session History
1. User opens Settings.
2. User taps `Session History`.
3. App shows synced entries with `Pending` or `Written` status.

## Concurrency and Conflict Handling

- Multiple eligible devices may process the same pending entry.
- Idempotency is guaranteed by Health dedupe key and pre-write existence check.
- Conflict resolution rule in history store: `written_to_health` is terminal and wins over `pending_health_write`.
- Updates must be atomic per entry to avoid partial writes.

## Failure Handling and Retry Policy

- Transient HealthKit errors: keep pending, retry with exponential backoff on future triggers.
- Authorization revoked/Health unavailable: pause processing on current device until eligibility changes.
- Partial batch failure: continue processing remaining entries; failed ones stay pending.

## Implementation Plan

### Phase 1 - Data Foundation
- Add `SessionHistoryEntry` model and persistence/sync store.
- Add unit tests for CRUD, pending queries, and status transitions.

### Phase 2 - Async Health Writer
- Add `HealthWriteCoordinator` and eligibility checks.
- Add Health dedupe query + write path.
- Add retry/backoff behavior.

### Phase 3 - Integrate Session Lifecycle
- Replace direct `TimerViewModel.writeToHealthStore()` completion dependency with:
  - `recordCompletedSession()`
  - fire-and-forget coordinator trigger
- Keep cancel path unchanged (no history entry, no Health write).

### Phase 4 - Validation
- Multi-device manual validation (one device authorized, one unauthorized).
- Verify eventual convergence of pending -> written after sync.

## Testing Strategy

### Unit Tests
- Session completion creates pending entry.
- Canceled sessions create no entry.
- Eligibility false prevents writer execution.
- Existing Health sample causes status change to written without duplicate save.
- Save success/failure transitions are correct.

### Integration Tests
- Queue processing across app relaunch.
- Batch processing with mixed success/failure.
- Conflict scenario with two simulated writers racing on same entry.

### Device Checks
- Real-device HealthKit authorization matrix:
  - Authorized + toggle on
  - Denied + toggle on
  - Toggle off
- Two-device sync path where only second device can write.

### UI Checks
- `Settings` displays `Session History` entry.
- `Session History` opens and renders synced data in newest-first order.
- Status labels reflect `pending_health_write` vs `written_to_health` correctly.

## Telemetry and Observability

- Log counters: pending queue size, writes attempted, writes succeeded, duplicates detected, retries scheduled.
- Keep logs free of sensitive user content.

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Duplicate writes from concurrent devices | Stable sync identifier + existence check before save |
| Pending queue grows if user never opens eligible device | Process queue on every eligible launch/foreground and after sync updates |
| Permission churn causes repeated failures | Eligibility gate and categorized retry policy |
| Sync conflicts overwrite status | Terminal-state conflict rule (`written` wins) |

## Rollout Notes

- Ship behind an internal feature flag if needed for staged validation.
- Migrate current completion path to history-first write path in same release.

## Open Questions

- What retention policy should apply to old written entries?
- Do we need explicit user-facing indicators for pending Health writes?
