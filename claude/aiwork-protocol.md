# .aiwork Folder Protocol

`.aiwork/` is a repository-local folder for AI-related work artifacts, organized by feature or task.

## Structure

Each task gets its own folder. Artifacts are created as the work progresses.

```
.aiwork/
  2026-01-27_auth-refactor/
    triage.md
    research.md
    spec.md
    plan.md
    review.md
```

### Folder Naming

`{YYYY-MM-DD}_{slug}/` - slug is lowercase kebab-case, max 40 chars.

### File Naming

`{type}.md` - just the artifact type. When multiple of the same type exist, add a numbered suffix: `plan.md`, `plan_2.md`, `plan_3.md`.

### Longer Tasks

For tasks spanning multiple days with many artifacts, optionally add date prefixes for chronological clarity:

```
.aiwork/
  2026-01-27_auth-refactor/
    triage.md
    research.md
    spec.md
    plan.md
    2026-01-28_plan_2.md
    2026-01-28_review.md
    docs/
      nextauth-v5.md
```

## Artifact Types

All types are optional. Use only what the task needs.

- **triage** - Requirement analysis, what is the problem, what do we know
- **research** - Knowledge gathering, codebase exploration, reading docs
- **prd** - Product requirements, user stories, success criteria
- **spec** - Technical specification, architecture and implementation decisions
- **plan** - Implementation steps, how to build it in actionable chunks (typical output of Plan mode)
- **review** - Code review report
- **notes** - Findings, decisions, or other useful context from implementation
- **docs/** - Subfolder for downloaded external documentation

## Frontmatter

```yaml
---
status: draft|active|complete|superseded
ticket: #123456
references:
  - https://docs.example.com/auth
---
```

Status values: **draft** (WIP), **active** (approved, implementing), **complete** (done), **superseded** (replaced - add `superseded_by: filename.md`).

## Version Control

Whether to commit `.aiwork/` is up to you. It can be version controlled for traceability or gitignored as ephemeral working artifacts.
