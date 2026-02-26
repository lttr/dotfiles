---
name: implement-next
description: Implement the next unimplemented plan from .aiwork/. Use when user says "implement next", "implement step", "start implementing", or provides a plan file path to implement. Companion to /plan-next.
allowed-tools: Read, Glob, Grep, Task, Write, Edit, AskUserQuestion, Bash
argument-hint: [plan-or-spec-path]
---

# Implement Next Step

The plan already exists - skip plan mode and implement directly.

Implement the next unimplemented plan from `.aiwork/`. Follows `@aiwork-protocol.md`.

**Arguments (`$ARGUMENTS`):** Optional path to a plan or spec file. If omitted, auto-detect from `.aiwork/`.

## 1. Find the plan

- **Plan path given**: use directly
- **Spec path given**: scan its folder for lowest-numbered plan with `status: draft|active`
- **No args**: find most recently modified `.aiwork/*/` folder, then first `draft|active` plan in it

**No plan found?** Tell user: "No unimplemented plan found. Run `/plan-next` to create one." Stop.

## 2. Implement

Read the plan and its referenced spec for context. Set plan `status: active`.

Execute the **Changes** section. Read files before modifying. Follow existing patterns. Stay focused on what the plan specifies.

## 3. Verify & complete

Run verification per the plan's **Verification** section. Fix issues.

Then update status:
- Plan frontmatter: `status: complete`
- Spec checklist: `- [ ]` -> `- [x]` for the completed step

## 4. Report

Summarize changes. If more steps remain, ask: "Run `/implement-next` or `/plan-next` if next step needs planning?"
