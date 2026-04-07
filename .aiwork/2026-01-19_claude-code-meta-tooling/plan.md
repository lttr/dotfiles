---
status: complete
---

# Claude Code Authoring Plugin (`cc`)

## Goal

Move Claude Code authoring tools (for creating plugins, skills, commands) to marketplace as `cc` plugin.

## Resulting Commands & Skills

Commands:
- `/cc:list:plugins`, `/cc:list:commands`, `/cc:list:hooks`, etc.
- `/cc:command:create`

Skills:
- `cc:plugin-creator`
- `cc:skill-creator`

## What to Move

### From dotfiles/claude/

**Skills:**
- `skills/plugin-creator/` → `cc:plugin-creator`
- `skills/skill-creator/` → `cc:skill-creator`

**Commands:**
- `commands/list/*.md` (10 files) → `/cc:list:*`
- `commands/command/create.md` → `/cc:command:create`

## What to Delete (redundant)

- `skills/claude-code-cli/` - built-in `claude-code-guide` agent covers this
- `commands/prime/claude-code.md` - built-in agent fetches same docs

## New Plugin Structure

```
plugins/cc/
├── .claude-plugin/plugin.json
├── skills/
│   ├── plugin-creator/
│   │   ├── SKILL.md
│   │   ├── references/
│   │   │   ├── plugin-structure.md
│   │   │   ├── marketplace-schema.md
│   │   │   └── workflows.md
│   │   └── scripts/
│   │       ├── create_plugin.py
│   │       └── bump_version.py
│   └── skill-creator/
│       ├── SKILL.md
│       ├── LICENSE.txt
│       ├── references/
│       └── scripts/
│           └── init_skill.py
├── commands/
│   ├── list/
│   │   ├── builtin-commands.md
│   │   ├── builtin-agents.md
│   │   ├── builtin-tools.md
│   │   ├── custom-commands.md
│   │   ├── custom-agents.md
│   │   ├── custom-skills.md
│   │   ├── mcp-tools.md
│   │   ├── hooks.md
│   │   ├── plugins.md
│   │   └── memory.md
│   └── command/
│       └── create.md
└── README.md
```

## plugin.json

```json
{
  "name": "cc",
  "version": "1.0.0",
  "description": "Claude Code authoring tools: create plugins, skills, commands, and introspect Claude Code internals",
  "author": {
    "name": "Lukas Trumm"
  },
  "keywords": ["claude-code", "plugin", "skill", "authoring", "introspection"]
}
```

## Steps

1. Delete redundant items from dotfiles
2. Create `plugins/cc/` in marketplace
3. Copy skills and commands
4. Add plugin.json (version 1.0.0)
5. Update marketplace.json
6. Test installation
7. Remove originals from dotfiles

## Unresolved Questions

None. Reference `claude-code-guide` built-in agent in README.
