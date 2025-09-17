---
id: task-1
title: Migrate specs docs into backlog
status: Now
assignee: []
created_date: '2025-09-17 01:05'
updated_date: '2025-09-17 01:07'
labels:
  - documentation
dependencies: []
priority: medium
---

## Description

Migrate the documents currently stored under specs/ into backlog/ managed docs so planning lives in one place.
Requirements:
- Use backlog doc commands to re-create each document under backlog/.
- Preserve front-matter dates, titles, and cross-links from the original specs.
- Update any app or doc references that still point to specs/.
- Remove migrated files from specs/ once everything is confirmed in backlog/.

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each specs/ markdown file is recreated via backlog doc as a backlog/ doc with equivalent content and metadata.
- [ ] #2 Cross-references in the repo point to the new backlog/ locations.
- [ ] #3 specs/ contains no stray files after migration (aside from intentional placeholders).
- [ ] #4 Backlog docs build/preview succeeds after the migration.
<!-- AC:END -->
