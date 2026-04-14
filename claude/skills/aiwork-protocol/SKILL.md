---
name: aiwork-protocol
description: Structure AI work artifacts under .aiwork/{YYYY-MM-DD}_{slug}/ folders using the project's protocol (triage, research, spec, prd, plan, review, notes, docs/). Use when the user asks to plan, make a spec, triage, research a task, write a report, code review, summarize findings, save the work, document decisions, record this, write that down, persist findings, or references any path under .aiwork/. Also use when starting a non-trivial task that needs a plan or spec before implementation, or when finishing one and capturing notes.
---

# .aiwork Folder Protocol

Repository-local folder for AI work artifacts, organized by feature or task. Artifacts structure thinking in-session and provide context for future sessions when referenced manually.

## Folder layout

```
.aiwork/
  2026-01-27_auth-refactor/
    triage.md
    spec.md
```

- **Folder:** `{YYYY-MM-DD}_{slug}/`, slug lowercase kebab-case, max 40 chars.
- **File:** `{type}.md`. Numbering for multiples of same type:
  - `plan.md` → `plan_2.md` → `plan_3.md` — when one plan was expected, more followed.
  - `plan_1.md` → `plan_2.md` → `plan_3.md` — when multiple are expected from the start.
  - Don't mix schemes in one folder.
- **Multi-day:** optionally prefix filenames with `{YYYY-MM-DD}_`.

Usually 1-2 artifacts per task. Pick types that fit.

## Grouping and restructuring

One task = one folder. Drift signals:

- Two folders with overlapping scope or near-identical slugs
- Cross-folder `references:` / "Source plan: ../..." pointers
- Folder that exists only because a ticket number arrived mid-task

On drift, propose consolidation: move artifacts into the canonical folder with a `superseded_by:` pointer, or merge under one date. Ask before moving files.

## Artifact types (all optional)

- **triage** — problem framing, what's known
- **research** — codebase exploration, doc reading
- **prd** — product requirements, success criteria
- **spec** — technical/architecture decisions
- **plan** — actionable implementation steps
- **review** — code review report
- **notes** — findings, decisions from implementation
- **docs/** — subfolder for downloaded external docs

Custom types (`cascade-map.md`, `checklist.md`) are fine when they fit better.

## When to create a new plan

New plan file when the approach changes or new constraints emerge between iterations. Otherwise continue the previous plan — don't start one just because the session is new.

## Frontmatter

Folder date + filename already encode creation time and type, so don't duplicate. Add structured data that's useful for the artifact.

```yaml
---
ticket: #123456
references:
  - "Parent: #38234"
  - https://docs.example.com/auth
story_points: 8
superseded_by: plan_2.md
---
```

Common fields: `ticket`, `references`, `superseded_by`. Avoid fields that need manual upkeep across sessions.

## Version control

Whether to commit `.aiwork/` is up to the project — either traceability or ephemeral working artifacts is fine.
