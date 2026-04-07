---
name: deep-plan
description: Produce a thorough implementation plan using multi-agent codebase exploration. Use when user says "deep plan", "thorough plan", "multi-agent plan", or wants an exhaustive plan with parallel research and critique.
allowed-tools: Read, Glob, Grep, Task, Write, Edit, Agent, AskUserQuestion, Bash(ls:*), Bash(git:*)
argument-hint: [task description or file path]
---

# Deep Plan

Produce an exhaustive implementation plan via parallel multi-agent exploration, synthesis, and critique.

**Arguments (`$ARGUMENTS`):** Task description or path to a file containing the task definition. If empty, ask user what to plan.

## 1. Parallel exploration

Spawn 3 agents in parallel:

**Agent A - Architecture & existing code**
- Map relevant modules, files, patterns, conventions
- Trace data flow and call chains related to the task
- Note tests, types, and interfaces that constrain the implementation

**Agent B - Change surface**
- Identify every file that needs creation or modification, and what changes
- Flag files with high churn or recent changes (`git log --oneline -5 <file>`)

**Agent C - Risks & dependencies**
- Identify edge cases, breaking changes, migration needs
- Check for downstream consumers, shared utilities, cross-module impact
- Flag external dependencies, version constraints, config changes

## 2. Synthesize plan

Merge agent findings into this structure:

```markdown
## Summary
1-3 sentence approach description

## Changes
1. `path/to/file.ext` - what changes, why

## Implementation order
Numbered steps grouping related changes. Each step independently verifiable.

## Verification
- How to test each step
- Commands to run

## Risks
| Risk | Severity | Mitigation |
| ---- | -------- | ---------- |
```

Keep the plan concise. Sacrifice grammar for brevity.

## 3. Critique

Spawn a critique agent with the draft plan. It should challenge assumptions, find missing steps, flag verification gaps, and suggest simplifications. Incorporate valid feedback.

## 4. Save and present

If there is a convention for saving work artifacts, save the plan there. Otherwise present inline.
