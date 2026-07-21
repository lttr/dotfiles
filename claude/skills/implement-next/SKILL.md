---
name: implement-next
description: Implement the next unimplemented plan or ticket, falling back to a spec/prd when neither exists.
allowed-tools: Read, Glob, Grep, Task, Write, Edit, AskUserQuestion, Bash
argument-hint: [plan-ticket-or-spec-path]
disable-model-invocation: true
---

# Implement Next Step

The plan (or ticket/spec/prd) already exists, skip plan mode and implement directly. Follows `aiwork-protocol`.

**Arguments (`$ARGUMENTS`):** Optional path to a plan, ticket, spec, or prd file. If omitted, auto-detect.

## 1. Find what to implement

- **Plan or ticket path given**: use directly. For a ticket, verify every `blocked_by` ticket is `status: done`; if not, warn and ask before proceeding
- **Spec/prd path given**: scan its folder for a `tickets/` subfolder — pick the lowest-numbered **frontier** ticket (`status: ready`, all `blocked_by` done); else lowest-numbered plan with `status: draft|active`; if none, implement the spec/prd directly
- **No args**: find most recently modified `aiwork-protocol` folder, then apply the same order: frontier ticket, then `draft|active` plan, then spec or prd
**Nothing found?** Tell user: "No plan, ticket, spec, or prd found.

## 2. If implementing from a spec/prd (no plan)

Check it's concrete enough for one run. **Warn and stop for confirmation** if any hold:

- Open questions, TBDs, or unresolved decisions
- Scope spans many subsystems, better split into plans
- Key technical choices (data model, API shape, file targets) unspecified
- Success criteria too vague to tell when "done"

Warn: "Spec too broad/underspecified because <reason>. Implement anyway?" Wait.

## 3. Implement

Read the plan or ticket (and referenced spec) or the spec/prd. If a plan, set `status: active`; if a ticket, set `status: in-progress`.

Execute the **Changes** section (or what the spec specifies). Read files before modifying, follow existing patterns, don't expand scope.

## 4. Verify & complete

Verify per the **Verification** section or success/acceptance criteria. Fix issues. Then set status:
- Plan frontmatter: `status: complete`
- Ticket frontmatter: `status: done`, check off acceptance criteria `- [ ]` -> `- [x]`
- Spec/prd checklist: `- [ ]` -> `- [x]`

## 5. Report

Summarize changes. If steps remain, ask: "Run `/implement-next`?"
