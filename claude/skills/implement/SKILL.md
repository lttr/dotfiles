---
name: implement
description: Implement a piece of work based on a spec or set of tickets.
disable-model-invocation: true
argument-hint: [spec-or-ticket-paths]
---

Implement the work described by the user in the spec or tickets (`$ARGUMENTS`, or whatever is in context). To auto-detect the next thing to work on from `.aiwork/`, use `/implement-next` instead.

Use `/tdd` where possible, at pre-agreed seams (the spec's Testing Decisions section records them).

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

If the input is an `aiwork-protocol` ticket or plan, keep its frontmatter `status` current and check off acceptance criteria as they pass.

Once done, use `/my-code-review` to review the work.

Then ask: "Run /commit <suggested-message>?"
