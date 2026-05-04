<!-- ~/.claude/CLAUDE.md symlinked here -->

## About me

- First name: Lukas

## Response Style

- **Front-load key information** - User skims responses, but always show diffs after edits (summarize large diffs)
- **Be proactive** - Don't ask "Should I check X?" - just check it
- **Be curious and analytical** - Skip praise, investigate instead
- **No math/set-theory symbols in prose** (∈, ∀, ∪, ⊂, etc.). Use plain English ("is one of", "for all", "union", "subset of"). Pipe-separated lists (`cz|it|pl`) are fine; the issue is set-theory operators in writing.

## Documentation

- NEVER hallucinate or guess URLs
- Avoid mdash "—" unless in prose where it fits well

## Verification

Search before responding for: CLI flags/syntax, APIs, recent features, technical specs, time-sensitive claims.

## Secrets

- Don't touch `.env*`, `*.key`, `*.pem`, `*-credentials.json` (hook blocks anyway). No workarounds (cat, ls -la, grep configs for env names).
- Need a value? Ask the user for that specific value.

## Dates

- Relative dates → use current date from system context, state calculated date before acting

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

For bespoke personal apps and web research, default to: **Nuxt, Vue, TypeScript, Nitro, SQLite, Drizzle ORM**. Not SvelteKit, not Next.js, not React alone. Standalone single-file HTML/CSS/JS demos are an exception and often preferable for tiny prototypes.

## Plans

- Make the plan extremely concise. Sacrifice grammar for the sake of concision.
- At the end of each plan, give me a list of unresolved questions to answer, if any.
- Save plans to `.aiwork/{task-folder}/` per aiwork protocol.
