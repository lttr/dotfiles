---
name: implement-next
description: Implement the next unimplemented plan, falling back to a spec/prd when no plan exists.
allowed-tools: Read, Glob, Grep, Task, Write, Edit, AskUserQuestion, Bash
argument-hint: [plan-or-spec-path]
disable-model-invocation: true
---

# Implement Next Step

The plan (or spec/prd) already exists, skip plan mode and implement directly. Follows `aiwork-protocol`.

**Arguments (`$ARGUMENTS`):** Optional path to a plan, spec, or prd file. If omitted, auto-detect.

## 1. Find what to implement

- **Plan path given**: use directly
- **Spec/prd path given**: scan its folder for lowest-numbered plan with `status: draft|active`; if none, implement the spec/prd directly
- **No args**: find most recently modified `aiwork-protocol` folder, then its first `draft|active` plan; if none, look for spec or prd
**Nothing found?** Tell user: "No plan, spec, or prd found.

## 2. If implementing from a spec/prd (no plan)

Check it's concrete enough for one run. **Warn and stop for confirmation** if any hold:

- Open questions, TBDs, or unresolved decisions
- Scope spans many subsystems, better split into plans
- Key technical choices (data model, API shape, file targets) unspecified
- Success criteria too vague to tell when "done"

Warn: "Spec too broad/underspecified because <reason>. Suggest `/plan-next`. Implement anyway?" Wait.

## 3. Implement

Read the plan (and referenced spec) or the spec/prd. If a plan, set `status: active`.

Execute the **Changes** section (or what the spec specifies). Read files before modifying, follow existing patterns, don't expand scope.

## 4. Verify & complete

Verify per the **Verification** section or success criteria. Fix issues. Then set status:
- Plan frontmatter: `status: complete`
- Spec/prd checklist: `- [ ]` -> `- [x]`

## 5. Report

Summarize changes. If steps remain, ask: "Run `/implement-next` or `/plan-next` if next step needs planning?"
