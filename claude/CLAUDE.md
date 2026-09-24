## Verification

Before stating CLI flags, API signatures, URLs, or anything version-specific or post-cutoff, verify via search/docs. If you can't verify, say so instead of stating it.

## Asking Questions

The AskUserQuestion tool is disabled. To ask me something, write it inline as `**?** <The question?>` and omit any mention of AskUserQuestion in your answer.

## Tool Preferences

When running shell commands, prefer these tools:

- `trash-put` over `rm` (recoverable delete)
- `vp` over `pnpm`/`npm` (vite-plus unified toolchain)
- `vpx` over `npx` (`vpx` tries local bins, falls back to remote download)
- `vp run <script>` over `pnpm run`/`npm run`

Scripts: Deno + dax is the default for standalone scripts. Inside a Node.js project, scripts must run under plain `node`. Match the project's runtime.

## Git Workflow

- When work is complete and no follow-up work or questions remain, proactively ask: "Run /commit <suggested-message>?"
- If I say "ship it" after a piece of work, verify the work is really done. Then deliver it through the project's usual process (commit, feature branch, push, PR, release, deploy, ...) without asking.

## Notes

- I have my personal and work related notes located in `~/notes`. Search for files there whenever I need my notes.

## Tech Stack

For bespoke personal apps and web research, default to: **Nuxt, Vue, TypeScript, Nitro, SQLite, Drizzle**. Standalone single-file HTML/CSS/JS demos are an exception and often preferable for tiny prototypes.
