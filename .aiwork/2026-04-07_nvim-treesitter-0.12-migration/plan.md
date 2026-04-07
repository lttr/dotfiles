---
references:
  - https://github.com/nvim-treesitter/nvim-treesitter (main branch README)
  - https://github.com/nvim-treesitter/nvim-treesitter/discussions/7901
  - https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main
---

# nvim-treesitter 0.12 migration plan

Full incompatible rewrite. Treat as new plugin, set up from scratch.

## Prerequisite

- `tree-sitter-cli` (>= 0.26.1) must be on PATH (not via npm)
- Verify: `tree-sitter --version`

## Step 1: Update nvim-treesitter plugin spec

**File:** `nvim/lua/my/packages.lua`

Old:
```lua
{ "nvim-treesitter/nvim-treesitter", build = false }
```

New:
```lua
{ "nvim-treesitter/nvim-treesitter", lazy = false, build = ":TSUpdate" }
```

## Step 2: Rewrite treesitter config

**File:** `nvim/after/plugin/treesitter.lua`

Old API (`require("nvim-treesitter.configs").setup()`) is gone. Replace with:

```lua
-- Install parsers (async)
require("nvim-treesitter").install("all")

-- Highlight + indent are now built-in Neovim features, enabled per-filetype:
-- highlight: vim.treesitter.start() -- already default in 0.12 for supported langs
-- indent: vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
```

Highlight is auto-enabled in 0.12 for languages with bundled queries.
Indent via treesitter needs explicit opt-in per filetype or global autocmd.

Decide: global treesitter indent autocmd vs per-filetype.

## Step 3: Migrate textobjects

**File:** `nvim/after/plugin/treesitter.lua` (or new file)

Old: textobjects config nested inside `nvim-treesitter.configs.setup()`.
New: separate `require("nvim-treesitter-textobjects").setup()` + explicit keymaps.

```lua
require("nvim-treesitter-textobjects").setup({
  select = { lookahead = true },
  move = { set_jumps = true },
})

-- Select
local sel = require("nvim-treesitter-textobjects.select").select_textobject
for _, map in ipairs({
  { "af", "@function.outer" }, { "if", "@function.inner" },
  { "ar", "@parameter.outer" }, { "ir", "@parameter.inner" },
  { "ac", "@class.outer" }, { "ic", "@class.inner" },
  { "aa", "@attribute.outer" }, { "ia", "@attribute.inner" },
  { "ai", "@conditional.outer" }, { "ii", "@conditional.inner" },
}) do
  vim.keymap.set({ "x", "o" }, map[1], function() sel(map[2], "textobjects") end)
end

-- Move
local move = require("nvim-treesitter-textobjects.move")
vim.keymap.set({ "n", "x", "o" }, "<A-]>", function() move.goto_next_start("@function.outer", "textobjects") end)
vim.keymap.set({ "n", "x", "o" }, "<A-[>", function() move.goto_previous_start("@function.outer", "textobjects") end)

-- Swap
local swap = require("nvim-treesitter-textobjects.swap")
vim.keymap.set("n", "<localleader>r", function() swap.swap_next("@parameter.inner") end)
vim.keymap.set("n", "<localleader>R", function() swap.swap_previous("@parameter.inner") end)
```

lsp_interop (peek definition) - check if still available in new API, may need alternative.

## Step 4: Handle ts-context-commentstring

Currently: `require("ts_context_commentstring").setup({})`
This plugin (JoosepAlviste/nvim-ts-context-commentstring) should work independently.
Verify it doesn't depend on old nvim-treesitter module API.

## Step 5: Handle syntax-tree-surfer

`ziontee113/syntax-tree-surfer` - last updated Nov 2024, uses nvim-treesitter API.
Risk: may use removed internals. Test after migration; if broken, consider:
- Replacing with built-in 0.12 incremental selection (`v_an`, `v_in`, `]n`, `[n`)
- Note: 0.12 migration guide says incremental selection removed from plugin,
  but Neovim 0.12 itself added `v_an`/`v_in`/`v_]n`/`v_[n` as built-in

## Step 6: Handle vim-matchup

`andymass/vim-matchup` - no longer configurable through nvim-treesitter.
Must handle its own setup. Current config is minimal (just matchparen offscreen).
Should work as-is since it doesn't depend on treesitter module config.

## Step 7: Verify & test

- Open TS/Vue/Lua files, confirm highlighting works
- Test textobjects: `vaf`, `vir`, etc.
- Test move: `<A-]>`, `<A-[>`
- Test swap: `<localleader>r`, `<localleader>R`
- Test syntax-tree-surfer: `vx`, `vn`, `J`/`K` in visual
- Test comments: `gcc`, context-aware in Vue/JSX
- Check `:messages` for errors
- Check `:checkhealth` for treesitter issues

## Resolved questions

1. **install("all")** - Works as `require("nvim-treesitter").install({ "all" })` (table wrapper needed).
2. **Indent** - Use global FileType autocmd setting `indentexpr`. Same behavior as old `indent = { enable = true }`.
3. **lsp_interop** - Gone from textobjects API. `gF`/`gC` peek bindings need alternative (LSP hover or separate peek plugin).
4. **syntax-tree-surfer** - Will break. Depends on removed `nvim-treesitter.ts_utils`. Built-in `v_an`/`v_in` covers node expansion only, not sibling nav/swap. No drop-in replacement exists.
5. **ignore_install** - No equivalent in 0.12. Either accept `ipkg` errors or switch from `"all"` to explicit parser list.
