# AGENTS.md — Backlog Workflow

## General Rules

* Planning lives entirely inside `backlog/` and is managed with Backlog.md using the `backlog` CLI—never hand-edit the files under `backlog/tasks/`, and keep CLI-generated docs intact by preserving their front matter.
* Before editing tasks, run `backlog board view` to confirm current state and avoid conflicting updates. Columns flow **Now → Next → Later → Done**; new work normally starts in `Later` unless a user explicitly requests a different column.
* Keep metadata accurate: set `status`, `labels`, `dependencies`, and timestamps through the CLI. Do not modify these fields manually.
* If the `backlog` CLI is missing from `$PATH`, check `/opt/homebrew/bin/backlog` (Apple Silicon macOS) or `/root/.bun/bin/backlog` (CI container). You may want to add it to your path or call it directly.
* For end-to-end workflow expectations, review the "Backlog.md workflow" section in `README.md` and the upstream Backlog.md docs.

## Creating Tasks

1. Use `backlog tasks create …` with a descriptive title. Unless the user specifies otherwise, set `--status Later` so new ideas land in the backlog before being promoted.
2. Always provide:
   * A short description that clarifies the user value and scope (use `--description`).
   * Acceptance criteria with repeated `--ac` (or `--acceptance-criteria`) flags so each criterion is captured separately; the CLI formats them into numbered checklists for you.
   * Any known dependencies via `--depends-on`/`--dep` flags (omit the flag entirely if there are no dependencies).
3. Double-check the generated markdown for ordering (ID/title/status front-matter first, description, then acceptance criteria). If something looks wrong, fix it by re-running the CLI with `backlog tasks edit`.
4. When planning larger initiatives, create an "epic" parent task and add dependent sub-tasks so work stays organized.

**Example — create a new task**

```sh
backlog tasks create "Add mindful reminders" \
  --status Later \
  --description "Let users schedule quick reminder nudges throughout the day." \
  --labels ui \
  --ac "Users can enable or disable reminders." \
  --ac "Reminders respect quiet hours."
```

> Labels available today: `documentation`, `ui`. Create additional labels through the CLI if needed and update this file to keep the list authoritative.

## Viewing Tasks

* Use `backlog task view <task-id> --plain` to inspect a task’s metadata and description in a non-interactive format.
* Task IDs are case sensitive—match the exact casing shown in `backlog board view` or `backlog tasks list` to avoid lookup errors.
* Combine with other CLI commands (e.g., run a board view first) when you need context before editing.

## Updating Tasks

* Use `backlog tasks edit <task-id>` to adjust status, labels, description, or acceptance criteria. Avoid manual search-and-replace.
* When moving work between columns (e.g., Later → Next → Now), update status through the CLI and verify the timestamps were refreshed.
* When a task is complete, mark it as `Done`, confirm the acceptance criteria are satisfied, and update any relevant docs via the CLI.
* For related documentation, create new specs with `backlog doc create` and rely on the CLI to manage metadata (do not rename or relocate docs by hand).

**Example — update an existing task**

```sh
backlog tasks edit TSK-123 \
  --status Next \
  --labels "ui,documentation" \
  --acceptance-criteria "Designs approved." \
  --acceptance-criteria "Copy finalized."
```

## Quality Checks

* After changes, run `backlog board view --status all` to review the board and ensure tasks appear in the right column.
* If multiple tasks are added, run `backlog tasks list` to confirm IDs and metadata remain unique and correctly ordered.
* Use `backlog board view` any time you need a quick snapshot of the Kanban board across Now/Next/Later/Done.

## Documentation & Decisions

* Author and update planning docs with the CLI:
  * `backlog doc create "Title" --type feature` starts a new document (optionally add `--path` to place it under a custom folder).
  * `backlog doc list --plain` gives a quick index; `backlog doc view doc-123` previews an individual file before editing.
  * Edit generated markdown with your editor but keep the front matter intact—if you need to move/retitle a doc, re-run `backlog doc create` with the desired options and migrate the content.
* Suggested tags (add them to each doc’s front matter) keep docs organized: `feature`, `spec`, `tech-debt`, `process`, `agents` (use `agents` whenever a doc is targeted at agent workflows or guidelines).
* Capture product or technical decisions with `backlog decision create "Title" --status Proposed`. Update the status to `Accepted`/`Superseded` by rerunning the command once consensus is reached.
* For every decision or major doc update, cross-link the relevant tasks so the board and documentation stay in sync.

Following these guidelines keeps the backlog consistent and prevents merge conflicts or malformed task files.
