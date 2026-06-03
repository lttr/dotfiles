---
name: gv
description: Start a `gv --collect` review session — open the git-history-viewer in the browser so the user authors inline review comments on the current repo, then act on the feedback they finish with. Use when the user says "gv", "gv collect", "collect review", "start a review session", "let me review", "gv review", or wants to hand-author review comments in the browser for Claude to implement.
allowed-tools: Bash(gv:*), Bash(vpx:*)
---

# Collect Review Comments with gv

`gv --collect` (the user's git-history-viewer, `@lttr/gv`) serves the current repo in
the browser, lets the user write review comments on the diff, and on **"Finish review"**
prints them to stdout for you to act on.

## Workflow

1. Confirm `cwd` is the repo to review (else pass `--repo <path>`).
2. Launch with `run_in_background: true` (it blocks until Finish): `gv --collect`
   (fallback: `vpx @lttr/gv --collect`).
3. Tell the user: browser is open — add comments, then click **"Finish review"**. Wait
   for the process to exit; don't poll.
4. On exit, comments appear between `===GV_COMMENTS_BEGIN===` / `===GV_COMMENTS_END===`.
   Treat each as a change request, implement it, summarize per comment.

## Notes

- Empty block (finished with no comments) → say so and stop; don't invent work.
- Pass through `<file>` (preselect) and `--port <n>` if the user mentions them.
- Inverse `gv --comments <file.json>` only *displays* comments — not this skill.
