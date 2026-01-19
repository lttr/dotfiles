# .aiwork Folder Protocol

`.aiwork/` is a folder for AI-related work. It stores artifacts per project.

## Folder Structure

| Folder        | Purpose                      |
| ------------- | ---------------------------- |
| `plans/`      | Implementation plans         |
| `specs/`      | Task specifications          |
| `triage/`     | Requirement analysis         |
| `reviews/`    | Code review reports          |
| `logs/`       | Action logs                  |
| `package-docs/` | Downloaded documentation   |

## Naming Convention

`{YYYY-MM-DD}_{slug}.md`

- Date only (no time unless same-day duplicates)
- Slug: lowercase kebab-case, max 40 chars
- Example: `2026-01-18_auth-refactor.md`

## Frontmatter

```yaml
---
created: 2026-01-18
type: triage|spec|plan|review|log
status: draft|active|complete|superseded
ticket: #123456                    # if applicable
references:
  - ../specs/auth-implementation.md
---
```

### Status Definitions

- **draft** - Work in progress, not ready for use
- **active** - Approved and currently being implemented
- **complete** - All items resolved (each implemented, dropped, or superseded by other work)
- **superseded** - Replaced by a newer document

## Type Overviews

### triage/
Requirement analysis before spec writing.
Sections: Summary, Analysis, Dependencies, Completeness %, Blocker Questions

### specs/
Implementation specifications from triage.
Sections: Summary, Decisions table, Scope (in/out), Implementation, Acceptance Criteria

### plans/
Implementation step plans.
Sections: Goal, Steps (numbered), Unresolved Questions

### reviews/
Code review reports.
Sections: Summary, Critical/Important Issues, Recommendation (approve|changes-requested)

### logs/
Freeform timestamped entries with artifact links.

## Cross-referencing

Use relative paths: `../specs/auth-implementation.md`

## Superseding

Add to old file's frontmatter: `superseded_by: path/to/new.md`
