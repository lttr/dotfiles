<!-- ~/.claude/CLAUDE.md symlinked here -->

## Response Style

- **Front-load key information** - User skims responses, but always show diffs after edits (summarize large diffs)
- **Be proactive** - Don't ask "Should I check X?" - just check it
- **Be curious and analytical** - Skip praise, investigate instead

## Documentation

- NEVER hallucinate or guess URLs
- Avoid mdash "—" unless in prose where it fits well

## Verification

Search before responding for: CLI flags/syntax, APIs, recent features, technical specs, time-sensitive claims.

## Dates

- Relative dates → use current date from system context, state calculated date before acting

## Development

**Package managers:**

- Prefer `pnpm` over `npm` (use `npm` if package-lock.json exists)
- Aliases: `ni` (install), `nr <script>` (run), `nun` (uninstall)
- Prefer `px` over `npx` (`px` tries pnpm exec, falls back to pnpm dlx)

**Common scripts:**

- `nr build` / `nr test` / `nr verify` / `nr typecheck` / `nr lint:fix`

**Tools:**

- Prefer `fd` over `find`
- Prefer `rg` over `grep`

## Git Workflow

- Always run `nr verify` before committing changes (if npm script "verify"
  exists in package.json)
- When work is complete and no follow-up work or questions remain, proactively ask: "Run /commit <suggested-message>?"

## Notes

- I have my personal and work related notes located in `~/ia`. Search for files there whenever I need my notes.

## Screenshots

- Screenshots I manually make are saved by default in `~/Pictures/Screenshots` by the Gnome screenshot utility.

## Browser Usage

- Use browser-tools skill when: testing UI changes, debugging frontend issues,
  capturing screenshots, or verifying rendered output.
- When I ask "let me pick and element" you should load skill browser-tools and
  use browser-pick tool for it, check whether the browser is started beforehand

## Plans

- Make the plan extremely concise. Sacrifice grammar for the sake of concision.
- At the end of each plan, give me a list of unresolved questions to answer, if any.
- Save plans to `.aiwork/{task-folder}/` per aiwork protocol.

## AI-Generated Artifacts

@aiwork-protocol.md
