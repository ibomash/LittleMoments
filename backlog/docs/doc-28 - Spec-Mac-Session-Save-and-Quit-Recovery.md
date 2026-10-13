---
id: doc-28
title: 'Spec: Mac Session Save and Quit Recovery'
type: other
created_date: '2026-10-13 02:24'
---
## Purpose
TASK-11 merge follow-up: prevent loss of a completed Mac session when history persistence fails.

## Required behavior
- Save history before clearing the active session or canceling its target bell.
- A save failure retains the active session and shows Retry Saving and Keep Session Running.
- Retrying saves the original start date and the end date of the successful completion attempt.
- Roll back a failed insertion in the Mac-owned context so a retry cannot persist duplicate entries.
- Complete and Quit approves termination only after history is saved successfully.
- Explicit cancellation discards the session and clears the error.

## Scope
Local Mac use retains development signing. Cross-device CloudKit sync is a separate proposed change. iOS session and persistence behavior are unchanged by this recovery fix.

## Validation
Four new Mac tests cover failure and retry, guarded quit, cancellation after failure, and persisted timestamps. All nine Mac tests pass. Scoped Fastlane format and lint pass.
