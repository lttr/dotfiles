# .aiwork Folder Protocol

`.aiwork/` is a repository-local folder for AI-related work artifacts, organized by feature or task. Artifacts serve two purposes: they structure thinking during a session, and they provide context for future sessions when referenced manually.

## Structure

Each task gets its own folder. Most tasks need just 1-2 artifacts - pick the type that fits.

```
.aiwork/
  2026-01-27_auth-refactor/
    triage.md
    spec.md
```

### Folder Naming

`{YYYY-MM-DD}_{slug}/` - slug is lowercase kebab-case, max 40 chars.

### File Naming

`{type}.md` - just the artifact type. When multiple of the same type exist, add a numbered suffix: `plan.md`, `plan_2.md`, `plan_3.md`.

For tasks spanning multiple days, optionally add date prefixes for chronological clarity:

```
.aiwork/
  2026-01-27_auth-refactor/
    triage.md
    spec.md
    plan.md
    2026-01-28_plan_2.md
    2026-01-28_review.md
```

## Artifact Types

All types are optional. Use only what the task needs. Custom types (e.g. `cascade-map.md`, `checklist.md`) are fine when they fit better than the standard ones.

- **triage** - Requirement analysis, what is the problem, what do we know
- **research** - Knowledge gathering, codebase exploration, reading docs
- **prd** - Product requirements, user stories, success criteria
- **spec** - Technical specification, architecture and implementation decisions
- **plan** - Implementation steps, how to build it in actionable chunks
- **review** - Code review report
- **notes** - Findings, decisions, or other useful context from implementation
- **docs/** - Subfolder for downloaded external documentation

### When to create multiple plans

Create a new plan file when the approach changes or new constraints emerge between iterations. Don't create one just because a new session started - if the previous plan still holds, continue from it.

## Frontmatter

The folder date and filename already encode creation time and artifact type, so don't duplicate those. Beyond that, add whatever structured data is useful for the artifact.

```yaml
---
ticket: #123456
references:
  - "Parent: #38234"
  - https://docs.example.com/auth
story_points: 8
assigned: Lukas Trumm
superseded_by: plan_2.md
---
```

Common fields:

- **`ticket`** - Links to the external work item. Include when applicable.
- **`references`** - Parent tickets, related PRs, external docs.
- **`superseded_by`** - Points to the replacement artifact when this one is no longer current.

Add any other fields that make sense. Avoid fields that need manual upkeep across sessions.

## Version Control

Whether to commit `.aiwork/` is up to you. It can be version controlled for traceability or gitignored as ephemeral working artifacts.
