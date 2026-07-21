---
name: implement
description: Implement work from a ticket, spec, or inline description; auto-detects the next item from the task folders when no argument is given.
disable-model-invocation: true
argument-hint: [path-or-feature-description]
---

# Implement

Follows the `aiwork-protocol` skill. Don't enter plan mode — the input artifact is the plan.

## 1. Resolve input to one work item

`$ARGUMENTS` is one of:

- **Ticket path**: use directly. Verify the ticket is `status: ready` and every `blocked_by` ticket is `status: done`; if not, warn and ask.
- **Spec/PRD path**: scan its folder for a `tickets/` subfolder and pick the lowest-numbered **frontier** ticket (`status: ready`, all `blocked_by` done). If there are no tickets, the spec/PRD itself is the work item.
- **Inline feature description**: if trivial (fits one session, obvious approach), treat it as the work item. If non-trivial, stop and suggest `/to-spec`.
- **No args**: find the most recently modified task folder (per `aiwork-protocol` conventions), then apply the same order: frontier ticket, then spec/PRD. If everything is `done` but no `review.md` exists in the task folder, go straight to Wrap-up (§4). Nothing found → tell the user and stop.

## 2. Clarity gate

Before touching code, check the work item is concrete enough for one run. **Warn and stop for confirmation** if any hold:

- Open questions, TBDs, or unresolved decisions
- Scope spans many subsystems — suggest `/to-tickets` instead
- Key technical choices (data model, API shape, file targets) unspecified
- Success criteria too vague to tell when "done"
- Content is contradictory, out of order, or otherwise corrupted

Warn: "<item> is underspecified because <reason>. Implement anyway?" Wait.

The gate runs **once**, at the top level — against the spec/PRD or work item, not per ticket. A badly specified ticket discovered mid-chain doesn't stop for confirmation: resolve it with best judgment and record the gap and resolution in `implementation-notes.md`.

This is the **last stop**. Past this gate, run unattended to the end — no confirmations, no blocking questions.

## 3. Execution

This session acts as **orchestrator** and spawns one subagent per ticket.

- **Tickets exist**: for each frontier ticket in `blocked_by` order, spawn a subagent with the ticket path and the `<ticket-loop>` below as its instructions. When it returns, confirm the ticket file says `status: done` and a commit landed. Then spawn the next. If a ticket cannot be completed (tests won't pass, blocker discovered), stop the chain and report the state — never mark it done.
- **Standalone spec/PRD or trivial inline item**: run the `<ticket-loop>` directly in this session.

<ticket-loop>

1. Set ticket `status: in-progress`.
2. State your understanding of what needs to be done — the goal and the intended changes — before touching code. Not a question, just a statement for the record.
3. Implement. Use `/tdd` where possible, at the seams recorded in the spec's Testing Decisions section. Read files before modifying, follow existing patterns, don't expand scope.
4. Run `/simplify` — skip only when the change was a small mechanical edit.
5. Run `/verify`. Then confirm each acceptance criterion against actual behavior. Check off `- [ ]` → `- [x]`; set ticket `status: done`.
6. Commit. Do not ask.

Throughout: keep `implementation-notes.md` in the task folder (an `aiwork-protocol` artifact) as a chronological log. Two kinds of entries:

- **Workflow events** — one line each, always: ticket started, ticket done (with commit hash), chain stopped and why.
- **Substance** — recorded as it happens, not at the end: design decisions where the spec was ambiguous, intentional deviations from the spec and why, tradeoffs considered, open questions. Trivial work gets the workflow lines only.

</ticket-loop>

When no ready ticket remains, proceed to Wrap-up.

## 4. Wrap-up

Runs **once**, after the last item — never per ticket. Skip if `review.md` exists in the task folder and no tickets finished since; otherwise save the new review as the next number (`review_2.md`).

1. Run the full test suite plus other project checks (lint, build).
2. Review the branch — the whole diff across all ticket sessions. `/code-review low` for small/routine diffs, higher effort (medium/high/xhigh) scaled to size and risk. Fix every finding. Re-run the affected tests after fixing. A finding deliberately left unfixed goes into `implementation-notes.md` with the reason.
3. Save the review outcome as `review.md` per `aiwork-protocol`. Its presence marks wrap-up complete.
4. Commit remaining changes. Then report: tickets completed, commits made, review outcome, anything left open.
