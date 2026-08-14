<!-- ~/.claude/CLAUDE.md symlinked here -->

## Verification

Verify (search/docs) before stating: CLI flags, API signatures, URLs, anything version-specific or post-cutoff. Never hallucinate or guess; don't state if unverified.

## Asking Questions

The AskUserQuestion tool is disabled. To ask me something, write it inline as `**Question:** <The question?>` and omit any mention of AskUserQuestion in your answer.

## Tool Preferences

When running shell commands, prefer these tools:

- `trash-put` over `rm` (recoverable delete)
- `vp` over `pnpm`/`npm` (vite-plus unified toolchain)
- `vpx` over `npx` (`vpx` tries local bins, falls back to remote download)
- `vp run <script>` over `pnpm run`/`npm run`

## Git Workflow

- When work is complete and no follow-up work or questions remain, proactively ask: "Run /commit <suggested-message>?"

## Notes

- I have my personal and work related notes located in `~/notes`. Search for files there whenever I need my notes.

## Tech Stack

For bespoke personal apps and web research, default to: **Nuxt, Vue, TypeScript, Nitro, SQLite, Drizzle**. Standalone single-file HTML/CSS/JS demos are an exception and often preferable for tiny prototypes.
