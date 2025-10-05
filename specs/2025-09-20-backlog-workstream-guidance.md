---
title: "Backlog Workstream Guidance"
authors: ["Codex Agent"]
date: 2025-09-20
status: draft
tags: [process, agents]
---

# Backlog Workstream Guidance Proposal

## Summary

Clarify how we use Backlog.md for design exploration, coding tasks, and documentation updates by introducing a single playbook with per-workstream checklists, CLI command references, and guidance on when to promote tasks between Later, Next, and Now. Pair the playbook with a lightweight update to `backlog/AGENTS.md` so the day-to-day workflow remains discoverable.

## Problem Statement

Backlog.md already houses our tasks and docs, but contributors still ask where to put PRDs versus technical design docs, which CLI commands belong in each flow, and when a task should move across the board. The current `backlog/AGENTS.md` covers general rules yet stops short of outlining concrete workflows per work type. That gap leads to inconsistent labeling, docs landing in ad hoc folders, and tasks jumping straight to Now without prior design alignment.

## Goals

- Provide explicit workflows for design, coding, and documentation-only tasks, including required labels.
- Document where derivative artifacts live (PRDs, design docs, ARDs) so specs stay organized.
- Standardize the CLI touch-points for each scenario and make them easy to copy.
- Capture expectations for moving work between Later → Next → Now whenever specs or code involvement changes.

## Non-Goals

- Changing the underlying Kanban columns or adding new task states.
- Replacing the backlog CLI or defining new command flags.
- Migrating existing docs; we only document where new ones should go unless implementation reveals gaps.

## Current State

- `backlog/AGENTS.md` focuses on high-level etiquette ("never hand-edit tasks", example create/edit commands) but does not separate workflows per task type.
- Specs and process docs live across `backlog/docs/`, `specs/`, and occasionally `docs/architecture.md` without a single routing guide.
- Contributors move tasks opportunistically; design work sometimes starts in Now without a discovery phase, while documentation fixes rarely leave Later even when blocking.

## Proposed Approach

### 1. Publish a Backlog Workstream Playbook (new doc)

Create a new process doc (`backlog doc create "Process: Backlog Workstream Guidance" --type process --path specs`) that becomes the canonical reference. Key sections:
- **Workstream breakdowns** covering Design Discovery, Implementation, and Documentation Maintenance. Each subsection will list required labels (e.g., `labels: design`, `labels: documentation`) and the minimum Definition of Ready before moving to Now.
- **Artifact routing** detailing where to place outputs:
  - PRDs → `backlog/docs/` with `--type feature` and tag `prd`.
  - Technical design docs / ARDs → `specs/` via `backlog doc create … --path specs` and tag `architecture`.
  - Process updates → `backlog/docs/` with `--type process` and tag `agents`.
- **Status progression guidance** spelling out when to advance a task: e.g., design work moves Later → Next once stakeholders agree on scope, Next → Now when the design doc is drafted and reviewed. Coding tasks require linked specs before landing in Now.

### 2. Add a Quick Reference to `backlog/AGENTS.md`

Extend the existing agent playbook with a concise table that links to the new doc. The table will summarize:
- When to create new tasks vs. extend existing ones.
- Required labels by workstream.
- Primary CLI commands (`backlog tasks edit`, `backlog doc create`, `backlog doc edit`).
- Destination folder for resulting docs (PRD/design/ARD).

### 3. Introduce a CLI-focused Checklist Section

Within the new playbook, include a self-contained "CLI quick reference" that maps each scenario to the exact commands. Example rows:
- **Design discovery** — `backlog tasks edit TSK-### --status Next --labels design`, `backlog doc create "Design: <name>" --type feature --path specs/design`.
- **Coding** — `backlog tasks edit TSK-### --status Now --labels engineering`, `backlog doc link TSK-### doc-###` (if supported); otherwise document manual cross-referencing.
- **Doc maintenance** — `backlog tasks edit TSK-### --status Now --labels documentation`, `backlog doc edit doc-###`.

### 4. Clarify Promotion Rules

Codify promotion rules directly in the playbook and echo them in `AGENTS.md`:
- **Later → Next**: reserved for discovery/planning. Requires task description + acceptance criteria + identified doc targets.
- **Next → Now (Design)**: only after the design doc draft exists and reviewers are identified.
- **Next → Now (Coding)**: requires linked design/PRD doc and implementation checklist.
- **Now → Done**: acceptance criteria validated, docs updated, cross-links added.

## CLI Quick Reference (Draft Content)

| Scenario | Required Labels | Key Commands | Output Location |
| --- | --- | --- | --- |
| Design discovery | `design` | `backlog tasks edit <id> --status Next --labels design`  → `backlog doc create "Design: <Title>" --type feature --path specs/design` | `specs/design/<slug>.md`
| Implementation | `engineering` | `backlog tasks edit <id> --status Now --labels engineering` → `backlog doc link <id> <doc-id>` (add if CLI supports links) | No new doc; reference existing design/PRD |
| Documentation maintenance | `documentation` | `backlog tasks edit <id> --status Now --labels documentation` → `backlog doc edit <doc-id>` | Existing doc updated |
| PRD authoring | `product, design` | `backlog doc create "PRD: <Feature>" --type feature --path backlog/docs/prd` | `backlog/docs/prd/<slug>.md` |
| Architecture review | `engineering, architecture` | `backlog doc create "ARD: <Area>" --type process --path specs/architecture` | `specs/architecture/<slug>.md` |

*(Commands will be verified during implementation; adjust if `backlog doc link` is unavailable.)*

## Implementation Plan

1. **Draft the Playbook** — Use the backlog CLI to generate the new process doc under `specs/`, populate the sections above, and add tags (`process`, `agents`).
2. **Refresh `backlog/AGENTS.md`** — Insert the quick-reference table plus a link to the playbook; keep existing guidance intact.
3. **Backlog Task Updates** — Ensure Task 5 carries `process` and `documentation` labels; move it to `Next` while drafting and to `Now` only when edits begin.
4. **Validation** — Run `backlog board view` to confirm status changes, and request feedback from frequent contributors before marking Task 5 as Done.

## Risks & Mitigations

- **Command Drift** — The CLI may differ across environments. Mitigation: verify commands locally when implementing and capture version notes in the playbook.
- **Duplicate Guidance** — Adding material to both the playbook and `AGENTS.md` could diverge over time. Mitigation: keep `AGENTS.md` concise and point readers to the canonical doc.
- **Label Overload** — Requiring new labels could clutter the board. Mitigation: reuse existing labels where possible; if new labels emerge, document them in the playbook.

## Acceptance Criteria Coverage

- **AC #1** — Workstream breakdown and promotion rules cover design vs. coding workflows and label usage.
- **AC #2** — Artifact routing section defines PRD/design/ARD destinations.
- **AC #3** — CLI quick reference lists commands for each scenario.

## Open Questions

- Do we want a dedicated `architecture` label or reuse `tech-debt` for ARDs?
- Should we enforce task-to-doc linking via automation, or is manual cross-referencing sufficient?
- Is there an existing `backlog doc link` command, or do we document the manual alternative?

