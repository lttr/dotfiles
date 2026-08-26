# Archived Claude config

Deprecated skills, commands, and agents kept for reference. Nothing here is loaded by Claude Code: `~/.claude/skills` symlinks to `claude/skills/`, and this directory sits outside it.

Don't restore anything from here unless explicitly asked.

## Skills

### `write` (archived)

Rules for a concise, human-readable note, invoked as `/write`. Superseded by `wr`, which carries the same core rules (point first, short sentences, say it once) and applies to any prose instead of waiting for an explicit invocation.

### `technical-writing` (archived)

Rules for specs, design docs, RFCs, ADRs, and incident writeups. Two of its three rules duplicated `wr` (lede first, plain words before jargon), and the third moved into `wr` as rule 11, "Name the actor". It also opened with a phrase `wr` bans, so loading both skills gave contradictory instructions.

For prose readability use `wr`; for Lukas's voice use `my-writing-style`.
