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

## Development

**Package managers:**

- Prefer `pnpm` over `npm` (use `npm` if package-lock.json exists)
- Aliases: `ni` (install), `nr <script>` (run), `nun` (uninstall)

**Common scripts:**

- `nr build` / `nr test` / `nr verify` / `nr typecheck` / `nr lint:fix`

**Tools:** Prefer `fd` over `find`

## Git Workflow

- Always run `nr verify` before committing changes (if npm script "verify"
  exists in package.json)
- When work is complete and no follow-up work or questions remain, proactively ask: "Run /commit <suggested-message>?"

## Notes

- I have my personal and work related notes located in `~/ia`. Search for files there whenever I need my notes.

## Screenshots

- Screenshots I manually make are saved by default in `~/Pictures/Screenshots` by the Gnome screenshot utility.

## Plans

- At the end of each plan, give me a list of unresolved questions if any. Make the questions extremely concise. Sacrifice grammar for the sake of concision.

## Browser Usage

- Use browser-tools skill when: testing UI changes, debugging frontend issues,
  capturing screenshots, or verifying rendered output.
- When I ask "let me pick and element" you should load skill browser-tools and
  use browser-pick tool for it, check whether the browser is started beforehand
- when i ask to save something to specs you should create a file in .aitools/specs/ directory