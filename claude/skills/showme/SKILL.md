---
name: showme
description: Open a real (headed) browser, drive it to a specific state in a web app — a feature, a flow, a particular screen, or a bug — then leave the window open for the user to click around in, with a short note on what to try and what to watch for. Use when the user wants to "show me X", "take me to that state/screen", "let me click around in it", "open a browser I can play with", "set up the repro", "drive me to <feature/flow/situation>", or describes any app state they want to experience firsthand.
allowed-tools: Bash(agent-browser:*)
---

# showme

Drive a headed browser to a described state, then hand the user the live window.
The state can be anything — a feature to try, a flow mid-way, a specific screen,
an edge case, or a bug. Your job is the tedious setup; theirs is the experiencing.

This skill only adds the **headed + leave-open + handoff** wrapper. For the actual
driving (navigate, snapshot, click, fill, login), use the **`agent-browser`** skill
— don't re-derive it here.

## Steps

1. **Target** — from context, work out the URL (prod/staging/`localhost:PORT`; start the dev server first if it's this repo's app and it isn't running), the preconditions that define the state, and the point of interest. Ask one tight question only if genuinely ambiguous.

2. **Open headed, named session:**
   ```bash
   agent-browser open --headed --session showme <url>
   ```
   No window? A headless daemon was already up — `agent-browser close --all`, then reopen.

3. **Drive to the state** via the `agent-browser` snapshot-and-ref loop. Stop *at or just before* the point of interest — don't fire the key action yourself unless it's needed to reach the state and isn't destructive; leave it for the user.

4. **Hand over — do NOT close.** Leave the window open (the daemon keeps it alive) and tell the user, in a few lines:
   - **It's open** — session `showme`, on which page.
   - **You are here** — current state + what you set up.
   - **Try this** — the exact action (e.g. "click the blue *Save* button").
   - **You'll see** — what should happen, so they know what to look for.

   Offer `agent-browser close --session showme` for when they're done.

## Notes

- Reuse login state with `--profile Default`, or `--profile ~/.showme-profile` for a persistent custom profile.
- Never auto-close — the open window is the deliverable.
