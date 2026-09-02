---
paths:
  - "claude/skills/**"
  - "claude/agents/**"
---

# Authoring skills and agents in `claude/`

- Paths: address a skill's own bundled files as `$CLAUDE_SKILL_DIR/<file>`. Never a hardcoded `~/.claude/skills/<name>/` (that path is a symlink into this repo) and never a relative path (it does not resolve).
- Keep skills portable: no project names, ports, hosts, or install locations baked in. Anything environment-specific is an argument the caller passes.
- State prerequisites explicitly — tools on PATH, env vars, what the caller must already have running — and say which of them the skill does *not* start itself.
- Plugin skills live in `~/code/claude-marketplace`, not here; its `CLAUDE.md` covers `${CLAUDE_PLUGIN_ROOT}` and the command/skill naming rules.
