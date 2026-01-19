---
created: 2026-01-19
type: plan
status: active
---

# Plan: Rename .aitools → .aiwork

## Goal

Rename `.aitools` → `.aiwork` and all references (aitools → aiwork).

## Approach

Hardcode `.aiwork` everywhere:
- Simple find/replace across all files
- Remove `plansDirectory` setting (hook hardcodes path)
- Consistent, predictable behavior

## Files to Modify

### dotfiles/claude/

| File | Changes |
|------|---------|
| `AITOOLS.md` | Rename → `AIWORK.md`, update content |
| `CLAUDE.md` | `@AITOOLS.md` → `@AIWORK.md`, update text refs |
| `settings.json` | Remove `plansDirectory` (hook will hardcode) |
| `hooks/copy-plan-to-aitools.ts` | Rename → `copy-plan-to-aiwork.ts`, hardcode `.aiwork` |
| `commands/recall.md` | `.aitools/plans` → AI work dir concept |
| `commands/assess/update.md` | `.aitools/logs` → concept |
| `commands/assess/nuxt-4.md` | `.aitools/` mention → concept |
| `commands/toolsforai/docs.md` | `.aitools/package-docs` → concept |

### dotfiles/ root

| Action |
|--------|
| `mv .aitools .aiwork` |

### ~/.claude/

| Action |
|--------|
| `rm AITOOLS.md` symlink |
| `ln -s ~/dotfiles/claude/AIWORK.md ~/.claude/AIWORK.md` |

### claude-marketplace/plugins/

| File | Changes |
|------|---------|
| `aitools-protocol/` | Rename dir → `aiwork-folder-protocol/` |
| `aiwork-folder-protocol/AITOOLS.md` | Rename → `AIWORK.md`, update content |
| `aiwork-folder-protocol/README.md` | Update all refs |
| `aiwork-folder-protocol/.claude-plugin/plugin.json` | name, keywords |
| `dev-flow/README.md` | aitools-protocol → aiwork-folder-protocol |
| `dev-flow/commands/triage.md` | `.aitools/triage` → `.aiwork/triage` |
| `dev-flow/commands/azdo/triage.md` | same |
| `dev-flow/skills/triage/SKILL.md` | same |
| `dev-flow/skills/spec/SKILL.md` | `.aitools/triage`, `.aitools/specs` |
| `dev-flow/skills/code-review/SKILL.md` | `.aitools/reviews` |

## Hook Update

```typescript
// Hardcoded - simple and predictable
const plansDir = join(cwd, '.aiwork', 'plans');
```

## Documentation Wording

- `.aiwork` = "folder for AI-related work"
- Protocol plugin name: `aiwork-folder-protocol`

## Steps

1. Rename AITOOLS.md → AIWORK.md, update content
2. Update CLAUDE.md (@AITOOLS.md → @AIWORK.md)
3. Remove plansDirectory from settings.json
4. Rename hook, hardcode .aiwork
5. Update command files (.aitools → .aiwork)
6. Rename .aitools → .aiwork folder
7. Update ~/.claude symlink
8. Rename marketplace plugin dir + update files
9. Update dev-flow references

## Verification

1. Start new session → check AIWORK.md loads
2. Run plan mode → exit → verify plan copies to `.aiwork/plans/`
3. Run `/df:triage` → verify output goes to `.aiwork/triage/`
