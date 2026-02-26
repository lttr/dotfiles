---
name: next-steps
description: Show status overview and next steps for an .aiwork/ spec. Use when user says "next steps", "what's left", "status", "progress", or wants to see what's planned, unplanned, or incomplete for a task.
allowed-tools: Read, Glob, Grep
argument-hint: [spec-or-task-folder-path]
---

# Next Steps

Show a status overview for an `.aiwork/` task. Follows `@aiwork-protocol.md`.

**Arguments (`$ARGUMENTS`):** Optional path to a spec file or task folder. If omitted, find most recently modified `.aiwork/*/`.

## 1. Find the task folder

- **Spec/plan path given**: use its parent folder
- **Folder given**: use directly
- **No args**: most recently modified `.aiwork/*/`

## 2. Gather status

Read the spec and all plan files in the folder. For each step in the spec's implementation order:

- Is there a corresponding `plan_N.md`?
- What is the plan's `status:`? (`draft` / `active` / `complete` / `superseded`)
- Does the spec checklist mark it `[x]` or `[ ]`?

## 3. Report

Keep output brief. Print:

1. **Status table**: step number, title, plan file (or `-`), status
2. **Next action**: one line - `/implement-next`, `/plan-next`, or "all done"
3. **Open questions / blockers**: only if any exist, brief bullet list
