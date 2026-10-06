---
name: publish-html
description: Publish an HTML file (or a folder with index.html) to html.lukastrumm.com, the artifacts site in ~/code/html. Publishing an existing slug replaces it with the new version. Use when the user says "publish html", "publish this", "republish", "put it on html.lukastrumm.com", "share this artifact", or wants a generated HTML page online.
---

# Publish HTML artifact

Site repo: `~/code/html` (GitHub `lttr/html`, branch `main`). Netlify serves `artifacts/` as is, no build step. Deploys come from the Netlify CLI, not from git push.

Publish right away. Don't ask for confirmation and don't start a local preview.

## Prerequisites

- `~/code/html` cloned and linked to its Netlify site.
- `ntl` on PATH and logged in. The skill does not run `ntl login` or `ntl link`; if either is missing, stop and tell the user.

## Inputs

- **Source**: an `.html` file or a folder containing `index.html` (plus CSS/JS/assets). If not given, use the last HTML file mentioned in the conversation.
- **Slug**: kebab-case, from the file name or title. If `artifacts/<slug>/` already exists, this is a new version: replace it.
- **Title**: from `<title>`, else the first `<h1>`.
- **Description**: 1-2 sentences on what it shows or does.
- **README** (optional): context, how it was generated, links to the source. Write one only when there's real context to add.

## Steps

1. `git -C ~/code/html pull --ff-only`
2. Copy the source to `~/code/html/artifacts/<slug>/`. A single file becomes `index.html`. When replacing, first clear out the old files except `README.md`. Check that the page is self-contained: no `file://` or absolute local paths, and any local assets copied along.
3. Add `<title>` and `<meta name="viewport">` if they're missing.
4. Write or update `artifacts/<slug>/README.md` if there's real context to add.
5. Index entry in `artifacts/index.html`:
   - New slug: add an entry at the top of the `<ul>`, matching the existing entries:
     ```html
     <li><a href="/<slug>/">Title</a> <small class="p-secondary-text-regular">YYYY-MM-DD · <a href="https://github.com/lttr/html/tree/main/artifacts/<slug>">readme</a></small><br>Description.</li>
     ```
     Leave out the ` · <a ...>readme</a>` part when there's no README. Use today's date.
   - Existing slug: keep the entry and its date. Update the title or description only if they changed.
6. Commit in `~/code/html` (`Add <slug>` or `Update <slug>`) and `git push`.
7. Deploy: `cd ~/code/html && ntl deploy --prod -m "<commit message>"`. The new version is live once the command returns.
8. Open `https://html.lukastrumm.com/<slug>/` in the browser with `xdg-open`.

## Reply

Reply with the URL only. Don't describe the steps (browser opened, index entry, README, commit, push). Add a line only if something went wrong or needs the user's attention, e.g. a failed push or deploy.
