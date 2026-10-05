---
name: routines
description: Use when the user mentions a routine, a scheduled or cloud run, a trig_ ID or RemoteTrigger, asks to find, change or debug a routine's prompt or schedule, or asks why a routine run failed or did nothing.
---

# Routines

## Finding a routine

`RemoteTrigger list` returns one page of 20 routines and ignores `cursor`, so
asking for the next page returns the first one again. A routine missing from it may still
exist, so never say it doesn't.

Look up IDs in this order:

1. The project's docs (for example `docs/cloud-routines.md`).
2. The desktop app's HTTP cache, which holds the routines the user has viewed:
   `grep -rhoaE 'trig_01[A-Za-z0-9]{20,}' ~/.config/Claude | sort | uniq -c`
3. Then `RemoteTrigger get` on each ID that `list` didn't return, and match by
   `name`. A `get` by ID always works.

Ask the user only if all three fail. The desktop app has no address bar, so they
can't copy a URL from it.

## Editing

`update` takes a partial body, but send the whole `job_config.ccr` from `get`
with only the prompt changed: `events[0].data.message.content`. Keep the event
`uuid`.

The desktop app doesn't refresh a routine changed through the API. Tell the user
to reopen it and never to Save an edit dialog opened before the change, because
saving writes the old prompt back.

The routine runs against the pushed default branch. If the new prompt points at
a file, push that file before the next run.

## Gotchas

- Cron: minimum interval is one hour; anything more frequent is rejected.
  Runs exactly on the hour can start minutes late, so prefer e.g. `7 9 * * *`.
- One-off runs auto-disable after firing. To rerun, set a new time.
- Text passed with **Run now** or an API fire arrives in a
  `<routine-fire-payload>` block marked untrusted. The prompt must explicitly
  tell Claude to act on that block, or it is ignored.
- A green run status only means no infrastructure error. Read the run
  transcript to see whether the task worked.
- The Default environment blocks hosts outside its allowlist (`403`,
  `x-deny-reason: host_not_allowed`). Connectors are not affected.
- If GitHub auth lapses, runs are skipped for 72 hours, then the routine turns
  itself off and must be re-enabled.

Docs: https://code.claude.com/docs/en/routines
