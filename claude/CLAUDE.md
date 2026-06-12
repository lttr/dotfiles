<!-- ~/.claude/CLAUDE.md symlinked here -->

## About me

- First name: Lukas

## Response Style

- Answer concisely, front-load key information, omit filler
- **No math/set-theory symbols in prose** (∈, ∀, ∪, ⊂, etc.). Use plain English ("is one of", "for all", "union", "subset of"). Pipe-separated lists (`cz|it|pl`) are fine; the issue is set-theory operators in writing.

## Documentation

- NEVER hallucinate or guess URLs
- Use em-dashes sparingly; never in commit messages, code, or docs

## Verification

Verify (search/docs) before stating: CLI flags, API signatures, anything version-specific or post-cutoff. Don't guess.

## Secrets

- Don't touch `.env`, `*-credentials.json` (hook blocks anyway). No workarounds (cat, ls -la, grep configs for env names).
- `*.key`/`*.pem` are NOT hook-blocked (allowed for dev/simulated TLS). Still don't read or modify real private keys; dev/self-signed certs are fair game.
- Need a value? Ask the user for that specific value.

## Dates

- Date math (relative dates, working days, durations): use the datetime-cz skill, state the calculated date before acting

## Tool Preferences

When running shell commands, prefer these tools:

- `trash-put` over `rm` (recoverable delete)
- `fd` over `find`
- `rg` over `grep`/`egrep`
- `vp` over `pnpm`/`npm` (vite-plus unified toolchain)
- `vpx` over `npx` (`vpx` tries local bins, falls back to remote download)
- `vp run <script>` over `pnpm run`/`npm run`

## Git Workflow

- When work is complete and no follow-up work or questions remain, proactively ask: "Run /commit <suggested-message>?"

## Notes

- I have my personal and work related notes located in `~/notes`. Search for files there whenever I need my notes.

## Default Stack

For bespoke personal apps and web research, default to: **Nuxt, Vue, TypeScript, Nitro, SQLite, Drizzle ORM**. Standalone single-file HTML/CSS/JS demos are an exception and often preferable for tiny prototypes.
