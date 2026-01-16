<!-- ~/.claude/CLAUDE.md symlinked here -->

## Response Style

- **Optimize for quick shared understanding** - User skims responses, so front-load key information
- **Be concise by default** - Only elaborate when asked
- **Focus on essential information only**
- **No praise or filler** - Skip "Perfect!", "Excellent!", "You're right!" - be curious and analytical instead
- **Be proactive** - Don't ask "Should I check X?" - just check it using agents, skills, websearch, or context

## Documentation

- NEVER hallucinate or guess URLs

## Verification

Search before responding for: CLI flags/syntax, APIs, recent features, technical specs, time-sensitive claims.

## Dates

- Relative dates → use "Today's date" from `<env>` block, state calculated date before acting

## Development

**Package managers:**

- Prefer `pnpm` over `npm` (use `npm` if package-lock.json exists)
- Aliases: `ni` (install), `nr <script>` (run), `nun` (uninstall)

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
- Save plans to `.aitools/plans/` using standard naming convention

## Project Local Memory

`.aitools/` directory stores AI-generated artifacts per project:

| Folder          | Purpose                                      |
| --------------- | -------------------------------------------- |
| `plans/`        | Implementation plans                         |
| `specs/`        | Task specifications                          |
| `triage/`       | Ticket analysis summaries and clarifications |
| `reviews/`      | Code review reports                          |
| `logs/`         | Logs describing AI tools' actions            |
| `package-docs/` | Downloaded package documentation             |

**Naming convention**: `{timestamp}_{slug}.md`

- Timestamp: `YYYY-MM-DD_HH-MM`
- Example: `2025-01-16_09-30_auth-refactor.md`
- Slugify: lowercase, spaces→hyphens, no special chars, max 50 chars

When asked to save specs, plans, etc. → use this convention.
