---
name: agent-browser
description: Automate a real browser with the agent-browser CLI — open pages, snapshot interactive elements, click/fill by ref, extract content. Use when the user wants to browse, open a page, visit a URL, navigate a site, click or fill a form element, scrape, take a screenshot of a page, test a web app, or says "agent-browser". Works as a general-purpose browser automation tool in any repo, even ones without a local browser skill installed.
---

# agent-browser

General-purpose browser automation via the `agent-browser` CLI. Run `agent-browser --help` for the full command list.

## Core workflow

1. `agent-browser open <url>` — navigate to a page
2. `agent-browser snapshot -i` — get interactive elements with refs (`@e1`, `@e2`, ...)
3. `agent-browser click @e1` / `agent-browser fill @e2 "text"` — interact using refs
4. Re-snapshot after the page changes (navigation, dynamic content, dialogs)

## Local skills for heavy use

When a repo uses browser automation extensively (e.g. scripted test flows, recurring scraping jobs, repo-specific login dances), prefer installing a repo-local `agent-browser` skill or command that encodes the project's conventions. This global skill is the fallback for ad-hoc automation in repos without one.

## Screenshots: two traps

Verified against agent-browser 0.35.1 (`agent-browser screenshot --help`).

Signature is `agent-browser screenshot [selector] [path]` — both positional.

**1. The full-page flag is `--full` (or `-f`). `--full-page` does not exist.**
Because it is unrecognized, it is not rejected — it falls through into a positional slot:

```bash
agent-browser screenshot /abs/shot.png --full-page   # --full-page becomes the PATH
# -> "✓ Screenshot saved to --full-page", /abs/shot.png never written
agent-browser screenshot --full-page /abs/shot.png   # --full-page becomes the SELECTOR
# -> "✗ Element not found: --full-page"
```

The first form reports **success** while writing a junk file literally named `--full-page`.
Put the flag first, as in the CLI's own example:

```bash
agent-browser screenshot --full /abs/shot.png
```

**2. Always pass an absolute path.**
A relative path is resolved against the **browser daemon's** working directory — wherever the
persistent agent-browser process happened to be started — not the cwd of the shell you run the
command from. `cd /some/dir && agent-browser screenshot rel.png` writes `rel.png` into the
daemon's directory, silently littering an unrelated repo.

After any screenshot, confirm the file exists at the path you asked for (`ls -la <path>`) — the
CLI's success message echoes the path it *used*, which is not necessarily the one you intended.
