---
allowed-tools: Read, Glob, Grep, Task, Write, Edit, AskUserQuestion, EnterPlanMode, ExitPlanMode, Bash(ls:*), Bash(find:*)
description: Plan the next implementation step from a spec file
argument-hint: [spec-file-path]
---

## Task

Plan the next unplanned/unimplemented step from an implementation spec.

**Arguments (`$ARGUMENTS`):** Optional path to a spec file. If not provided, find the most recent `spec.md` in `.aiwork/*/`.

## Steps

### 1. Find the spec

If `$ARGUMENTS` is provided, use it as the spec path. Otherwise:

```
Glob pattern=".aiwork/*/spec.md"
```

Pick the most recently modified spec. If none found, ask user.

### 2. Determine the next step

Read the spec file. Identify all work items / implementation steps listed in it.

Then scan the spec's folder for existing plan files:

```
Glob pattern="plan*.md" path="<spec-folder>"
```

Read each existing plan to understand which steps are already planned or implemented. The next step is the first work item from the spec that has no corresponding plan yet.

If all steps are planned, inform the user and stop.

### 3. Enter plan mode

Call EnterPlanMode. Then:

1. **Explore** the codebase for the identified step using Task(Explore) agents - understand files to modify, existing patterns, dependencies
2. **Design** the implementation approach - keep it concise, actionable
3. **Clarify** ambiguities with AskUserQuestion

### 4. Write the plan

Save the plan next to the spec file as `plan_N.md` where N is the next available number (always numbered, even for the first: `plan_1.md`).

Use aiwork frontmatter:

```yaml
---
status: draft
ticket: "<from spec>"
step: N - <step title from spec>
references:
  - <spec file path>
---
```

Plan content:
- **Context**: Why this change, what problem it solves
- **Changes**: Files to create/modify with concise descriptions of what changes
- **Verification**: How to test the changes

Also write a copy to the plan mode plan file path for ExitPlanMode to pick up.

### 5. User review

Call ExitPlanMode to let the user review and approve the plan.

### 6. After approval

Tell the user:
- "Plan approved. To implement, clear context and run: `implement step N from <spec-path>`"
- Or offer to start implementation directly if the step is small
