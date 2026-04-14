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
