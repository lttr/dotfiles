# Reorganize dotfiles/claude → claude-marketplace

## Related Plans

- **`claude-code-meta-tooling.md`** - Plugin/skill creator + list commands (implement first)

---

## Analysis: Dependency Categories

### A. Fully Generic → MOVE
- `commands/assess/generic.md` - Works standalone
- `commands/assess/update.md` - Works standalone
- `commands/toolsforai/docs.md` - Uses Context7 API via curl

### B. Framework-Specific → MOVE to existing plugin
- `commands/assess/nuxt-4.md` → nuxt plugin

### C. Personal with Hardcoded Paths → KEEP
- `skills/mcp-manager/` - Scripts have `~/dotfiles/claude/...` paths
- `commands/pick.md` - References browser-tools plugin

### D. Personal Workflow/Preferences → KEEP
- `commands/gst.md`, `commit.md`, `verify.md` - Personal git workflow
- `commands/prime/puleocss.md` - Personal CSS framework
- `hooks/*` - Personal automation
- `scripts/status-line.js` - Personal status bar
- `output-styles/concise.md` - Personal preference
- `agents/js-web-code-reviewer.md` - Personal code review
- `skills/pdf-to-markdown/`, `img-optimize/` - Personal workflows
- `settings.json` - Instance config

---

## Proposed New Plugins

### 1. **assess** plugin
```
plugins/assess/
├── .claude-plugin/plugin.json
├── commands/assess/
│   ├── generic.md
│   └── update.md
└── README.md
```

### 2. **toolsforai** plugin
```
plugins/toolsforai/
├── .claude-plugin/plugin.json
├── commands/toolsforai/docs.md
└── README.md
```

---

## Move to Existing Plugin

### nuxt plugin
Add: `commands/assess/nuxt-4.md` → `/nuxt:assess`

---

## Keep in dotfiles (final list)

```
dotfiles/claude/
├── CLAUDE.md
├── settings.json
├── agents/js-web-code-reviewer.md
├── commands/
│   ├── gst.md
│   ├── commit.md
│   ├── verify.md
│   ├── pick.md
│   ├── what.md
│   └── prime/puleocss.md
├── hooks/
│   ├── code-quality.sh
│   ├── format-code.sh
│   ├── reset-timer-on-clear.sh
│   └── context-agents-md.sh
├── output-styles/concise.md
├── scripts/status-line.js
└── skills/
    ├── mcp-manager/
    ├── pdf-to-markdown/
    └── img-optimize/
```

---

## Migration Steps

1. Implement `claude-code-meta-tooling.md` first
2. Create `assess` and `toolsforai` plugins in marketplace
3. Add `assess/nuxt-4.md` to existing nuxt plugin
4. Update marketplace.json
5. Test installations
6. Remove moved files from dotfiles
7. Commit both repos

---

## Unresolved Questions

- `toolsforai` worth a plugin or just delete? (uses Context7 API)
