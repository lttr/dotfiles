---
name: implement-with-notes
description: Implement a spec while keeping a running notes artifact.
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Task, Write, Edit, AskUserQuestion, Bash
argument-hint: <spec-or-input-doc-paths>
---

Implement `$ARGUMENTS`. As you work, maintain a running `implementation-notes.md` file (an `/aiwork-protocol` artifact) that captures anything I should know about how the implementation diverges from or interprets the spec, including:

- Design decisions: choices you made where the spec was ambiguous
- Deviations: places where you intentionally departed from the spec, and why
- Tradeoffs: alternatives you considered and why you picked what you did
- Open questions: anything you'd want me to confirm or revise

Update it as you go rather than at the end.
