# .aiwork Folder Protocol

`.aiwork/` is a repository-local folder for AI-related work artifacts, organized by feature or task.

## Structure

Each task gets its own folder. Artifacts inside are created sequentially as the work progresses.

```
.aiwork/
  2026-01-27_auth-refactor/
    2026-01-27_09-30_triage.md
    2026-01-27_10-15_research.md
    2026-01-27_11-00_spec.md
    2026-01-27_14-00_plan.md
    2026-01-28_09-00_plan.md       # second plan for next chunk
    2026-01-28_16-00_review.md
    2026-01-28_16-30_notes.md
    docs/                           # downloaded reference docs
      nextauth-v5.md
```

### Folder Naming

`{YYYY-MM-DD}_{slug}/`

- Slug: lowercase kebab-case, max 40 chars
- Example: `2026-01-27_auth-refactor/`

### Artifact Naming

`{YYYY-MM-DD}_{hh-mm}_{type}.md`

- Datetime of creation, 24h format
- Type is the artifact kind (see below)

### Simple Tasks

When only a few artifacts are needed, skip phases that add no value.

```
.aiwork/
  2026-01-27_add-logout-button/
    spec.md
    plan.md
```

Datetime prefix on files is optional when the task is short-lived. A folder with just `review.md` is also fine.

## Artifact Types

All phases are optional. Use only what the task needs. Recommended sections listed below are guidelines, not requirements.

### triage
Requirement analysis — what is the problem, what do we know.
Sections: Summary, Analysis, Dependencies, Completeness %, Blocker Questions

### research
Knowledge gathering — exploring codebase, reading docs, understanding constraints.
Sections: Findings, Key Decisions, Open Questions

### spec
Implementation specification — what exactly are we building.
Sections: Summary, Decisions table, Scope (in/out), Implementation, Acceptance Criteria

### plan
Implementation steps — how to build it, in actionable chunks. Multiple plans allowed for phased work.
Sections: Goal, Steps (numbered), Unresolved Questions

### review
Code review report.
Sections: Summary, Critical/Important Issues, Recommendation (approve|changes-requested)

### notes
Process information, findings, decisions, or other useful context gained during implementation.
Freeform structure.

### docs/
Subfolder for downloaded external documentation relevant to the task.

## Frontmatter

```yaml
---
status: draft|active|complete|superseded
ticket: #123456                    # if applicable
references:                        # external references
  - https://docs.example.com/auth
---
```

### Status Definitions

- **draft** - Work in progress
- **active** - Approved, currently being implemented
- **complete** - All items resolved
- **superseded** - Replaced by a newer artifact (add `superseded_by: filename.md`)

## Version Control

Whether to commit `.aiwork/` is up to you. It can be version controlled for traceability or gitignored as ephemeral working artifacts.
