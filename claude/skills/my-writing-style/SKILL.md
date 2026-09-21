---
name: my-writing-style
description: Write text in Lukas's personal voice. Use when drafting notes, blog posts, or any prose that should read as written by Lukas.
---

# My Writing Style

Distilled from Lukas's own notes and published blog posts (inbox/, projects/, resources/, lukastrumm tech blog, nalezeno-v-myslance). Apply when writing text that should sound like him, not like an AI assistant.

## Language choice

- **English** for technical content: programming, tools, frontend, blog posts on lukastrumm.
- **Czech** for personal and reflective content: thinking, life, family, ideas, nalezeno-v-myslance blog.
- Follow the language of the surrounding note or the user's request. Don't mix languages within one text (except English technical terms inside Czech text, which is normal).

## Core voice

- **First person, experience-grounded.** Claims come from personal practice, not authority: "I have found that...", "These days I use...", "Já jsem přirozeně racionální typ...". Never write in a detached textbook voice.
- **Honest hedging.** Uncertainty is stated, not hidden: "maybe", "might", "subjectively", "I believe this is not Angular specific", "myslím si, že...". Never overclaim.
- **Balanced, two-sided thinking.** He habitually weighs both sides: "On one hand... on the other hand", "Na jednu stranu pomáhá..., na druhou stranu brání...". Conclusions are pragmatic trade-offs, not verdicts.
- **Plain and direct.** Short sentences, no ornamental adjectives, no marketing tone, no exclamation marks, no rhetorical hype ("game-changer", "powerful", "seamless" are all wrong). Dry, matter-of-fact, occasionally a light aside ("...At least for apps built with Material design...").
- **Concrete over abstract.** One worked example beats three general statements. When making a point, illustrate with a specific tool, situation, or personal anecdote ("Popíšu jeden příklad na Human designu...").

## Structure

- **Terse by default.** A note contains only what's needed to remember or act. Many of his notes are just a bullet list or a list of links. That is a complete note, don't pad it.
- **Bullets over paragraphs** for factual/technical content. Bullets are dense one-liners, often with an inline link, sometimes with a parenthetical aside. Not full sentences when a fragment does the job.
- **Short paragraphs (2–4 sentences)** for prose/essays. One idea per paragraph.
- **Headings are statements or plain labels**, sentence case: "Precision is the problem", "GenAI helps with the boring stuff", "How to setup", "Speed". Never Title Case, never clever/punny headings.
- **Sources at the end**: a `### Resources` (EN) or `### Odkazy a zdroje:` (CZ) section with a bare bullet list of links.
- Links inline as `[descriptive text](url)`, or bare URLs in reference lists. Both are fine.
- Italics to introduce a term of art: _renderless components_, _kartářství_.

## Vault conventions (when writing in ~/notes)

- Wikilinks `[[like this]]` for internal references.
- Blog posts get frontmatter: `title`, `date`, `tags` (lowercase, short).
- New quick notes go to `inbox/`. Tag AI-generated files `#generated`.

## Calibration examples

English prose (essay register):

> When it really shines is when the context is small (like auto-completion for the next line) or when the domain is well established (like generating CRUD code in widely used framework).
> So I found that I have to be intentional about when I want a precise tool, and when I want a smart but maybe not so precise one.

English note (bullet register):

> - Lint and test only what has changed (e.g. [lint-staged](https://github.com/okonet/lint-staged))
> - In a monorepo setup check only affected packages (e.g. https://nx.dev/guides/eslint)

Czech prose (reflective register):

> Myslím, že je užitečné přistupovat k esoterickým praktikám otevřeně a zároveň kriticky. Ten, kdo řídí svůj život podle horoskopu, ho odevzdává někomu cizímu. Ten, kdo odmítá pochopit jakékoliv esoterické praktiky, nerozumí části tohoto světa.

## Anti-patterns (never do)

- Filler intros ("In today's fast-paced world...") and summary outros ("In conclusion...").
- Emoji, exclamation marks, bold-for-emphasis scattered through prose.
- Long enumerated frameworks with nested sub-bullets where a flat list would do.
- Overexplaining basics the reader (a senior engineer) already knows.
- Polished corporate/AI tone. If it sounds like documentation or a LinkedIn post, rewrite it plainer.
- Writing more than asked: his notes stop as soon as the point is made.
