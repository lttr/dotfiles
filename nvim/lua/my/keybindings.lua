local utils = require("my.utils")

local default_map_options = { noremap = true, silent = true }

vim.cmd([[
  let mapleader = ","
  let maplocalleader = "\<space>"
]])

local function mymap(mode, lhs, rhs, opts, bufnr)
  opts = opts or {}
  local merged_opts = vim.tbl_extend("force", default_map_options, opts)
  if bufnr then
    opts.buffer = bufnr
  end
  vim.keymap.set(mode, lhs, rhs, merged_opts)
end

local function nmap(left, right, desc) mymap("n", left, right, { desc = desc }) end

local function imap(left, right, desc) mymap("i", left, right, { desc = desc }) end

local function vmap(left, right, desc) mymap("v", left, right, { desc = desc }) end

local function tmap(left, right, desc) mymap("t", left, right, { desc = desc }) end

local function nvmap(left, right, desc)
  mymap({ "n", "v" }, left, right, { desc = desc })
end

local function mapexpr(mode, lhs, rhs, desc)
  mymap(mode, lhs, rhs, { silent = true, expr = true, desc = desc })
end

-- Identify the syntax highlighting group used at the cursor
-- Run :TSHighlightCapturesUnderCursor from treesitter-playground if on Treesitter managed filetype
nmap("<F9>", "<cmd>TSHighlightCapturesUnderCursor<CR>")
nmap(
  "<F10>",
  [[:echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>]]
)

-- ===== Saving buffer =====
-- Use ctrl+s for saving, also in Insert mode (from mswin.vim)
nmap("<C-s>", ":write<CR>")
nmap("<leader>w", "<cmd>noautocmd write<CR>", "Save without actions after safe")
vmap("<C-s>", "<C-C>:write<CR>")
imap("<C-s>", "<Esc>:write<CR>")
nmap("<C-a>", "<C-a>:write<CR>")
nmap("<C-x>", "<C-x>:write<CR>")

-- comments
nmap("<C-_>", "<cmd>normal gcc<CR>") -- '_' is actually '/'
vmap("<C-_>", "<cmd>normal gc<CR>") -- '_' is actually '/'
nmap("<C-/>", "<cmd>normal gcc<CR>")
vmap("<C-/>", "<cmd>normal gc<CR>")

-- Consistency
-- Make the behaviour of Y consistent with D and C
-- (do the action from here to the end of line)
-- A default since neovim 0.6!
-- nmap("Y", "y$")

nmap("q", "<Nop>")
nmap("m", "q")

-- ===== Moving in buffer =====
nmap("j", "gj")
nmap("k", "gk")
vmap("j", "gj")
vmap("k", "gk")
nmap("n", "nzzzv")
nmap("N", "Nzzzv")

nmap("<C-u>", "<C-u>zzzv")
nmap("<C-d>", "<C-d>zzzv")

nmap("]q", "<cmd>cnext<CR>zzzv")
nmap("[q", "<cmd>cprevious<CR>zzzv")

-- Config files
nmap("<leader>x", ":call SaveAndExec()<CR>")

-- ===== Exiting =====
-- Quit buffer without closing the window, no back jumps will be possible (plugin Bbye)
nmap("Q", ":Bdelete<CR>")
-- Quit window and try to remove the buffer that left from that window
-- nmap("<leader>q", ":q<CR>:bd #<CR>")
nmap("<leader>q", ":q<CR>")
-- Quit window with force
nmap("<leader>Q", ":qall<CR>")
-- Quit all other buffers
nmap("<C-w><C-b>", "<cmd>Bonly<CR>")
-- nmap("<C-w><C-o>", ) -- this is default shortcut to close all other windows
-- Go to window left and right
nmap("<A-h>", "<C-w>h")
nmap("<A-l>", "<C-w>l")
nmap("<A-j>", "<C-w>j")
nmap("<A-k>", "<C-w>k")

-- tabs
nmap("<A-y", "<cmd>tabnext<CR>")

-- open current buffer in vertical split
nmap("<leader>vv", ":vsplit<CR>")
nmap("<leader>vs", ":split<CR>")

-- expand the current buffer's path on ex command line
mymap("c", "%%", "getcmdtype() == ':' ? expand('%:h').'/' : '%%'", { expr = 1 })

-- ===== Cut, Copy and Paste =====
-- Yank the contents of an overwritting selection into register "d (reyank the original content)
vmap("p", '"_dP')
-- Copy selection
vmap("<C-c>", '"+y')
-- Paste
nmap("<C-v>", '"+p')
-- Paste from insert mode
imap("<C-V>", '<Esc>"+p')
-- Paste over in visual mode
vmap("<C-V>", 'd"+gP')
-- Replace current word with yanked or deleted text (stamping)
-- while preparing silently for repeated actions ('n' or '.')
nmap("s", "*``cgn<C-r>0<Esc><C-l>")
vmap("s", "*``c<C-r>0<Esc><C-l>")

-- replace word under cursor, prepare 'n' and '.' to be used subsequently
nmap("gr", "*``cgn")
vmap("gr", 'y/<C-r>"<CR>Ncgn')
-- "gs" -- Go Substitute word under cursor (vim-substitute plugin)

-- visual multi - cursor addition
-- add cursor on current line and move down/up
nmap("<C-j>", ":call vm#commands#add_cursor_down(0, v:count1)<CR>")
nmap("<C-k>", ":call vm#commands#add_cursor_up(0, v:count1)<CR>")
-- create cursor for every line in current paragraph
nmap("<localleader>m", "vip:call vm#commands#visual_cursors()<CR>")
vmap("<localleader>m", ":call vm#commands#visual_cursors()<CR>")
-- create cursor for every occurance of current word
nmap("<localleader>M", ":call vm#commands#find_all(0, 1)<CR>")
vmap("<localleader>M", ":call vm#commands#find_all(0, 1)<CR>")

nmap("<localleader>E", '0yt=A<C-r>=<C-r>"<CR><Esc>')

-- search for selected text
vmap("//", [[y/\V<C-R>=escape(@",'/\')<CR><CR>]])

-- ===== Bubble lines up and down =====
-- Source http://vimrcfu.com/snippet/110
nmap("<A-J>", ":m .+1<CR>==")
nmap("<A-K>", ":m .-2<CR>==")
imap("<A-J>", "<Esc>:m .+1<CR>==")
imap("<A-K>", "<Esc>:m .-2<CR>==")
-- vmap("<A-J>", ":m '>+1<CR>gv=gv")
-- vmap("<A-K>", ":m '<-2<CR>gv=gv")

-- tags
-- remap emmet (https://github.com/mattn/emmet-vim/issues/86)
-- 'yat' creates a visual flash of the paragraph to help identify the scope of
-- change, 'dd' removes the ending tag and 'ds>' the starting tag
nmap("<C-Y>k", "yatvat<Esc>dd`<da>")

-- Code navigation
-- nmap("<C-b>", ":normal gd<CR>")

-- Harpoon
-- nmap("<localleader>=", function() require("harpoon.mark").add_file() end)
-- nmap("<localleader>-", function() require("harpoon.mark").rm_file() end)

-- nmap("<localleader>u", function() require("harpoon.ui").nav_file(1) end)
-- nmap("<localleader>i", function() require("harpoon.ui").nav_file(2) end)
-- nmap("<localleader>o", function() require("harpoon.ui").nav_file(3) end)
-- nmap("<localleader>p", function() require("harpoon.ui").toggle_quick_menu() end)

-- ts-node-action
nmap(
  "<localleader>i",
  require("ts-node-action").node_action,
  "Trigger TS Node Action"
)

-- Formatting
nmap("<leader>F", "<cmd>FormatWrite<CR>")
nmap("<localleader>w", "gwip")

-- Executing and running
vim.keymap.set(
  "n",
  "<leader>r",
  "<cmd>AsyncRun -save=1 -mode=term -pos=right deno run -A %:p<CR>",
  { silent = true, noremap = false }
)
nmap("<leader>n", "<cmd>AsyncRun -save=1 -mode=term -pos=right node %:p<CR>")
-- nmap(
--   "<localleader>t",
--   function() require("neotest").run.run(vim.fn.expand("%")) end
-- )
-- nmap("<localleader>T", function() require("neotest").summary.toggle() end)
nmap("<leader>a", ":AsyncRun -save=1 -mode=term -pos=right %:p<CR>")
nmap("<leader>e", "<cmd>%SnipRun<CR>")
vmap("<localleader>ee", "<Plug>SnipRun")
vmap("<localleader>j", utils.evaluate_js)

-- help
nmap("<localleader>H", ":help <C-r><C-w><CR>")

-- paset console.log with current variable
-- inspired by https://github.com/meain/vim-printer
nmap(
  "<localleader>l",
  [[ <cmd>exe "normal yiwoconsole.log('\<C-r>\"', \<C-r>\")"<CR>== ]]
)
vmap(
  "<localleader>l",
  [[ <cmd>exe "normal yoconsole.log('\<C-r>\"', \<C-r>\")"<CR>== ]]
)

nmap(
  "<localleader>c",
  "<cmd>ClassyAddClass<CR>",
  "Classy add class on current tag"
)
nmap(
  "<localleader>C",
  "<cmd>ClassyRemoveClass<CR>",
  "Classy remove class on current tag"
)
nmap(
  "<localleader>v",
  -- copy class (current word) and prepare a css rule just before ending
  -- </style> tag
  [[ yiw/\/style<CR>O<CR>.<Esc>pa {}<Esc>i<CR><Esc>O ]],
  "Implement class"
)

-- ensure , at the end of a line
nmap("<localleader>,", "<cmd>s/,*$/,/<CR><cmd>:nohls<CR>``")
-- ensure ; at the end of a line
nmap("<localleader>;", "<cmd>s/;*$/;/<CR><cmd>:nohls<CR>``")

-- terminal
nmap("<leader>t", "<cmd>ToggleTerm<CR>", "Toggle terminal")
nmap(
  "<localleader>t",
  "<cmd>ToggleTermSendCurrentLine<CR>",
  "Execute current line in terminal"
)

nmap("<leader>T", "<cmd>vsplit term://zsh<CR>")
tmap("<Esc>", [[<C-\><C-n>]])
tmap("<Esc>", [[<C-\><C-n>]])
tmap("<A-h>", [[<C-\><C-n><C-w>h]])
tmap("<A-j>", [[<C-\><C-n><C-w>j]])
tmap("<A-k>", [[<C-\><C-n><C-w>k]])
tmap("<A-l>", [[<C-\><C-n><C-w>l]])

nmap(
  "gz",
  "<cmd>silent execute '!xdg-open ' . shellescape('https://duckduckgo.com/?q=') . shellescape('<cWORD>')<CR>"
)
vmap(
  "gz",
  "y:silent execute '!xdg-open ' . shellescape('https://duckduckgo.com/?q=') . shellescape('<C-r>\"')<CR>"
)

nmap(
  "gZ",
  "<cmd>silent execute '!xdg-open ' . shellescape('https://duckduckgo.com/?q=') . shellescape('!') . shellescape('<cWORD>')<CR>"
)
vmap(
  "gZ",
  "y:silent execute '!xdg-open ' . shellescape('https://duckduckgo.com/?q=!%20') . shellescape('<C-r>\"')<CR>"
)

-- break undo sequence
imap(".", ".<C-g>u")
imap(",", ",<C-g>u")
imap("?", "?<C-g>u")

-- external apps
nmap("<F3>", "<cmd>silent !xdg-open %:p &<CR>")

-- paste file name without extension and without path
imap("<C-f>", "<C-r>=expand('%:t')<CR><Esc>dF.xa")

-- surround
nmap("y`", "<cmd>normal ysiw`<CR>")
nmap("y'", "<cmd>normal ysiw'<CR>")
nmap('y"', '<cmd>normal ysiw"<CR>')

--
---- telescope
--

local telescopeBuildin = require("telescope.builtin")
local telescope = require("telescope")

local find_files = function()
  return telescopeBuildin.find_files({
    find_command = {
      "rg",
      "--files",
    },
  })
end

local document_symbols = function()
  return telescopeBuildin.lsp_document_symbols({
    previewer = false,
    layout_config = { width = 90 },
    symbols = { "interface", "typeParameter", "function", "method" },
  })
end

local live_grep = function()
  return telescope.extensions.live_grep_args.live_grep_args()
end

local recent_files = function() return telescope.extensions.recent_files.pick() end

nmap("<C-p>", find_files)
imap(
  "<C-t>",
  function()
    telescopeBuildin.find_files({
      mappings = {
        i = {
          ["<CR>"] = require("telescope.actions").my_select_action,
        },
      },
    })
  end
)

nmap("<leader>fa", telescopeBuildin.commands, "Commands")
nmap("<leader>fb", telescopeBuildin.buffers, "Buffers")
nmap("<leader>fc", telescopeBuildin.command_history, "Command history")
nmap(
  "<leader>fd",
  function() telescopeBuildin.diagnostics({ bufnr = 0 }) end,
  "Diagnostics buffer"
)
nmap(
  "<leader>fd",
  function() telescopeBuildin.diagnostics() end,
  "Diagnostics all buffers"
)
nmap("<leader>fe", recent_files, "Recent files")
nmap("<leader>ff", telescopeBuildin.grep_string, "Find string under cursor")
nmap("<leader>fg", live_grep, "Live search ripgrep")
vmap(
  "<leader>fg",
  function() telescopeBuildin.live_grep({ default_text = GetVisualSelection() }) end,
  "Search form selection"
)
nmap(
  "<leader>fG",
  function()
    telescopeBuildin.live_grep({ default_text = vim.fn.expand("<cword>") })
  end,
  "Search under cursor"
)
nmap("<leader>fh", telescopeBuildin.help_tags, "Help")
nmap(
  "<leader>fH",
  function()
    telescopeBuildin.help_tags({ default_text = vim.fn.expand("<cword>") })
  end,
  "Help current word"
)
vmap(
  "<leader>fh",
  function() telescopeBuildin.help_tags({ default_text = GetVisualSelection() }) end,
  "Help from selection"
)
nmap(
  "<leader>fi",
  function() telescopeBuildin.find_files({ cwd = "$HOME/dotfiles" }) end,
  "Open dotfile"
)
nmap(
  "<leader>fI",
  function() telescopeBuildin.live_grep({ cwd = "$HOME/dotfiles" }) end,
  "Search in dotfiles"
)
nmap("<leader>fj", "<cmd>Telescope jsonfly<CR>", "JsonFly")
nmap("<leader>fk", telescopeBuildin.keymaps, "Keymaps")
nmap(
  "<leader>fl",
  telescope.extensions.buffer_lines.buffer_lines,
  "Buffer lines"
)
nmap(
  "<leader>fm",
  function()
    telescopeBuildin.lsp_dynamic_workspace_symbols({
      path_display = { "smart" },
      ignore_symbols = { "variable", "constant" },
    })
  end,
  "Symbols project"
)
nmap("<leader>fo", document_symbols, "Functions in document")
nmap("<leader>fp", telescope.extensions.repo.list, "Repositories")
nmap("<leader>fr", telescopeBuildin.lsp_references, "References")
nmap("<leader>fs", telescopeBuildin.search_history, "Search history")
nmap("<leader>ft", telescopeBuildin.git_status, "Git status")
nmap("<leader>fw", function()
  -- open file browser in folder of current file
  telescope.extensions.file_browser.file_browser({
    -- path = "%:p:h",
    -- cwd_to_path = true,
    grouped = true,
  })
end, "File browser")
nmap("<leader>fx", telescopeBuildin.builtin, "Telescope builtins")
nmap("<leader>fz", telescope.extensions.zoxide.list, "Recent directories")

--
-- nvim-lspconfig
--

-- build init neovim lsp

nmap("gd", function()
  local success = require("nuxt-navigation").go(false)
  if not success then
    vim.lsp.buf.definition({ reuse_win = true })
  end
end, "Go to definition")
nmap("gD", function()
  local success = require("nuxt-navigation").go(true)
  if not success then
    vim.lsp.buf.definition()
    vim.cmd("vsplit")
  end
end, "Go to definition in a window")
nmap(
  "gy",
  function() vim.lsp.buf.type_definition({ reuse_win = true }) end,
  "Type definition"
)
nmap("gY", function()
  vim.lsp.buf.type_definition()
  vim.cmd("vsplit")
end, "Type definition in a window")
nmap("gi", vim.lsp.buf.implementation, "Implementation")
nmap("gI", function()
  vim.lsp.buf.implementation()
  vim.cmd("vsplit")
end, "Implementation in a window")
nmap(
  "gh",
  function() vim.lsp.buf.typehierarchy("supertypes") end,
  "Type hierarchy super"
)
nmap(
  "gH",
  function() vim.lsp.buf.typehierarchy("subtypes") end,
  "Type hierarchy sub"
)
nmap("<localleader>r", vim.lsp.buf.references, "LSP references")
nmap("<localleader>R", "<cmd>TSToolsFileReferences<CR>", "File references")
nmap("<localleader>k", vim.lsp.buf.hover, "LSP hover")
nmap("<localleader>h", vim.lsp.buf.signature_help, "LSP signature_help")
-- nmap("<localleader>s", vim.lsp.buf.signature_help)
nmap("<F2>", vim.lsp.buf.rename)

-- code actions and refactoring
nmap("<leader>ca", vim.lsp.buf.code_action)
vmap("<leader>ca", vim.lsp.buf.code_action)
vmap("<localleader>er", require("react-extract").extract_to_current_file)
vmap("<localleader>ef", require("react-extract").extract_to_new_file)

nmap("<localleader>d", vim.diagnostic.open_float)

--
-- Typescript
--

nmap("<localleader>yo", "<cmd>TSToolsOrganizeImports<CR>", "Organize imports")
nmap(
  "<localleader>ya",
  "<cmd>TSToolsAddMissingImports<CR>",
  "Add missing imports"
)
nmap(
  "<localleader>yu",
  "<cmd>TSToolsRemoveUnusedImports<CR>",
  "Remove unused imports"
)
nmap("<localleader>yr", "<cmd>TSToolsRenameFile<CR>", "Typescript rename file")

-- Toggle stuff

-- nmap("co", "<Plug>(unimpaired-toggle)", "Unimpaired toggle")

-- yob 'background' (dark is off, light is on)
-- yoc 'cursorline'
-- yod 'diff' (actually |:diffthis| / |:diffoff|)
--e
nmap("cog", function() ToggleDiagnostics() end, "Toggle diagnostics")
-- yoh 'hlsearch'
-- yoi 'ignorecase'
--j
nmap("cok", require("lsp_lines").toggle, "Toggle diagnostic lines")
-- yol 'list'
nmap("coo", require("nvim-highlight-colors").toggle, "Toogle color highlights")
-- yon 'number'
nmap("cop", "<cmd>TroubleToggle<CR>", "Toggle Trouble")
nmap("coq", ":call ToggleQuickfixList()<CR>", "Toggle quickfix list")
-- yor 'relativenumber'
-- yos 'spell'
-- yot 'colorcolumn' ("+1" or last used value)
-- you 'cursorcolumn'
-- yov 'virtualedit'
nmap("coy", "<cmd>TSLspToggleInlayHints<CR>", "Toggle Treesitter inlay hints")
nmap("coi", function() vim.lsp.inlay_hint(0, nil) end, "Toggle LSP inlay hints")
-- yow 'wrap'
-- yox 'cursorline' 'cursorcolumn' (x as in crosshairs)

-- change case (addition to defaults in text-case.nvim)
nmap(
  "gt.",
  function() require("textcase").current_word("to_dot_case") end,
  "Convert to dot.case"
)
nmap(
  "gt/",
  function() require("textcase").current_word("to_path_case") end,
  "Convert to path/case"
)
nmap(
  "gt<space>",
  function() require("textcase").current_word("to_phrase_case") end,
  "Convert to Phrase case"
)
nmap(
  "gtt",
  function() require("textcase").current_word("to_title_case") end,
  "Convert to Title Case"
)

--
-- nvim-autopairs
--

mymap(
  "i",
  "<CR>",
  "v:lua.MUtils.completion_confirm()",
  { expr = true, noremap = true }
)

--
-- gitsigns
--

local function gitsigns_keybindings(bufnr)
  local gs = package.loaded.gitsigns

  -- Navigation
  mymap("n", "]c", function()
    if vim.wo.diff then
      return "]c"
    end
    vim.schedule(function() gs.next_hunk() end)
    return "<Ignore>"
  end, { expr = true })

  mymap("n", "[c", function()
    if vim.wo.diff then
      return "[c"
    end
    vim.schedule(function() gs.prev_hunk() end)
    return "<Ignore>"
  end, { expr = true })

  -- Actions
  nmap("<leader>hs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
  vmap("<leader>hs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
  nmap("<leader>hx", ":Gitsigns reset_hunk<CR>", "Restore hunk")
  vmap("<leader>hx", ":Gitsigns reset_hunk<CR>", "Restore hunk")
  nmap("<leader>hu", gs.undo_stage_hunk, "Restore staged hunk")
  nmap("<leader>hp", gs.preview_hunk, "Preview hunk")
  nmap(
    "<leader>hb",
    function() gs.blame_line({ full = true }) end,
    "Blame line"
  )

  nmap("<leader>hS", gs.stage_buffer, "Stage buffer")
  nmap("<leader>hX", gs.reset_buffer, "Restore buffer")
  nmap("<leader>hd", gs.diffthis, "Diff against index")
  nmap(
    "<leader>hD",
    function() gs.diffthis("~") end,
    "Diff against last commit"
  )
  nmap("<leader>he", gs.toggle_deleted, "Toggle deleted hunks")

  -- Text object
  mymap({ "o", "x" }, "ih", gs.select_hunk, default_map_options)
end

--
-- vim-fugitive
--

nmap("<leader>gs", "<cmd>Git<CR>")
nmap("<leader>gl", "<cmd>GV<CR>")
nmap("<leader>gh", "<cmd>GV!<CR>")
nmap("<leader>gp", "<cmd>Git push<CR>")
nmap("<leader>ga", "<cmd>Git add .<CR>")
nmap("<leader>gr", "<cmd>Git restore --staged .<CR>")
nmap("<leader>gb", "<cmd>Git blame<CR>")

--
-- rnvimr
--

-- also Alt-o
-- nmap("<leader>R", ":RnvimrToggle<CR>")

-- nvim-tree
nmap("<C-e>", "<cmd>NvimTreeFindFile<CR>")
nmap("<A-`>", "<cmd>NvimTreeToggle<CR>")

-- oil.nvim
nmap("-", "<cmd>Oil<CR>", "Open parent directory")
nmap("<localleader>-", require("oil").toggle_float)

-- ChatGPT.nvim
nmap("<A-g>", "<cmd>ChatGPT<CR>")
nvmap("<A-c>e", "<cmd>ChatGPTEditWithInstruction<CR>", "Edit with instruction")
nvmap("<A-c>g", "<cmd>ChatGPTRun grammar_correction<CR>", "Grammar Correction")
nvmap("<A-c>t", "<cmd>ChatGPTRun translate<CR>", "Translate")
nvmap("<A-c>k", "<cmd>ChatGPTRun keywords<CR>", "Keywords")
nvmap("<A-c>d", "<cmd>ChatGPTRun docstring<CR>", "Docstring")
nvmap("<A-c>a", "<cmd>ChatGPTRun add_tests<CR>", "Add Tests")
nvmap("<A-c>o", "<cmd>ChatGPTRun optimize_code<CR>", "Optimize Code")
nvmap("<A-c>s", "<cmd>ChatGPTRun summarize<CR>", "Summarize")
nvmap("<A-c>f", "<cmd>ChatGPTRun fix_bugs<CR>", "Fix Bugs")
nvmap("<A-c>x", "<cmd>ChatGPTRun explain_code<CR>", "Explain Code")
nvmap("<A-c>r", "<cmd>ChatGPTRun roxygen_edit<CR>", "Roxygen Edit")
nvmap(
  "<A-c>l",
  "<cmd>ChatGPTRun code_readability_analysis<CR>",
  "Code Readability Analysis"
)

--
-- diffview.vim
--

nmap("<leader>do", "<cmd>DiffviewOpen<CR>")
nmap("<leader>dm", "<cmd>DiffviewOpen master..HEAD<CR>")
nmap("<leader>dc", "<cmd>DiffviewClose<CR>")
nmap("<leader>de", "<cmd>DiffviewToggleFiles<CR>")
nmap("<leader>df", "<cmd>DiffviewFileHistory %<CR>")
nmap("<leader>dh", "<cmd>DiffviewFileHistory<CR>")
nmap("<leader>di", "<cmd>DiffviewFocusFiles<CR>")
nmap("<leader>dr", "<cmd>DiffviewRefresh<CR>")

--
-- Zen mode
--
nmap("<leader>z", require("zen-mode").toggle)

--
-- nvim-spectre
--
nmap("<leader>S", ":lua require('spectre').open()<CR>")
nmap("<leader>s", ":lua require('spectre').open_visual({select_word=true})<CR>")
vmap("<leader>s", ":lua require('spectre').open_visual()<CR>")
nmap("<leader>sp", "viw:lua require('spectre').open_file_search()<CR>")

--
-- rest.nvim
--
-- nmap("<localleader>T", require "rest-nvim".last)
-- nmap("<localleader>t", require "rest-nvim".run)

--
-- vim-translator
--
-- nahradit the text with translation
nmap("<A-t>", ":TranslateR<CR>")
vmap("<A-t>", ":TranslateR<CR>")
nmap("<A-T>", ":TranslateR --target_lang=EN<CR>")
vmap("<A-T>", ":TranslateR --target_lang=EN<CR>")

--
-- custom
--

-- start writing a commit message
nmap("<leader>C", "<cmd>call feedkeys(':C<space>', 'n')<CR>")

vim.cmd([[
  function! ExecuteMacroOverVisualRange()
    echo "@".getcmdline()
    execute ":'<,'>normal @".nr2char(getchar())
  endfunction
]])
vmap("@", ":<C-u>call ExecuteMacroOverVisualRange()<CR>")

-- Markdown filetype

local function markdown_keybindings()
  nmap("<LocalLeader>1", [[yypVr=<Esc><cmd>set nohls<CR>]])
  nmap("<LocalLeader>2", [[m`:s/^\(#*\)\ \?/##\ /<CR>``<cmd>set nohls<CR>]])
  nmap("<LocalLeader>3", [[m`:s/^\(#*\)\ \?/###\ /<CR>``<cmd>set nohls<CR>]])
  nmap("<LocalLeader>4", [[m`:s/^\(#*\)\ \?/####\ /<CR>``<cmd>set nohls<CR>]])
  nmap("<LocalLeader>b", [[viw<Esc>`>a**<Esc>`<i**<Esc>f*;]])
  vmap("<LocalLeader>b", [[<Esc>`>a**<Esc>`<i**<Esc>f*;]])
  nmap("<LocalLeader>i", [[viw<Esc>`>a_<Esc>`<i_<Esc>f_]])
  vmap("<LocalLeader>i", [[<Esc>`>a_<Esc>`<i_<Esc>f_]])
  nmap("<LocalLeader>`", [[viw<Esc>`>a`<Esc>`<i`<Esc>f`]])
  vmap("<LocalLeader>`", [[<Esc>`>a`<Esc>`<i`<Esc>f`]])
  nmap("<LocalLeader>9", [[vip<Esc>`<O```<Esc>`>o```<Esc>j]])
  vmap("<LocalLeader>9", [[<Esc>`<O```<Esc>`>o```<Esc>j]])
  nmap("<LocalLeader>u", [[vip:s/^\(\s*\)/\1- /<CR><cmd>set nohls<CR>]])
  vmap("<LocalLeader>u", [[:s/^\(\s*\)/\1- /<CR><cmd>set nohls<CR>]])
end

-- Debugger nvim-dap

--  Inspecting the state via the built-in REPL: :lua require'dap'.repl.open() or using the widget UI (:help dap-widgets)
nmap("<F4>", function() require("dap").repl.open() end)
--  Stepping through code via :lua require'dap'.step_over() and :lua require'dap'.step_into().
nmap("<F5>", function() require("dap").step_over() end)
nmap("<F6>", function() require("dap").step_into() end)
--  Launching debug sessions and resuming execution via :lua require'dap'.continue().
nmap("<F7>", function() require("dap").continue() end)
--  Setting breakpoints via :lua require'dap'.toggle_breakpoint().
nmap("<F8>", function() require("dap").toggle_breakpoint() end)

-- syntax-tree-surfer

-- Swap The Master Node relative to the cursor with it's siblings, Dot Repeatable

mapexpr("n", "vU", function()
  vim.opt.opfunc = "v:lua.STSSwapUpNormal_Dot"
  return "g@l"
end, "Swap around up")
mapexpr("n", "vD", function()
  vim.opt.opfunc = "v:lua.STSSwapDownNormal_Dot"
  return "g@l"
end, "Swap around down")
-- Swap Current Node at the Cursor with it's siblings, Dot Repeatable
mapexpr("n", "vd", function()
  vim.opt.opfunc = "v:lua.STSSwapCurrentNodeNextNormal_Dot"
  return "g@l"
end, "Swap inside down")
mapexpr("n", "vu", function()
  vim.opt.opfunc = "v:lua.STSSwapCurrentNodePrevNormal_Dot"
  return "g@l"
end, "Swap around up")

-- Visual Selection from Normal Mode
nmap("vx", "<cmd>STSSelectMasterNode<CR>", "SelectMasterNode")
nmap("vn", "<cmd>STSSelectCurrentNode<CR>", "SelectCurrentNode")
-- Select Nodes in Visual Mode
vmap("J", "<cmd>STSSelectNextSiblingNode<CR>", "Select next sibling node")
vmap("K", "<cmd>STSSelectPrevSiblingNode<CR>", "Select prev sibling node")
vmap("H", "<cmd>STSSelectParentNode<CR>", "Select parent node")
vmap("L", "<cmd>STSSelectChildNode<CR>", "Select child node")
-- Swapping Nodes in Visual Mode
vmap("<A-j>", "<cmd>STSSwapNextVisual<CR>", "Swap next visual")
vmap("<A-k>", "<cmd>STSSwapPrevVisual<CR>", "Swap prev visual")

-- splitjoin.nvim
nmap("gj", require("splitjoin").join, "Join the object under cursor")
nmap("g,", require("splitjoin").split, "Split the object under cursor")

-- export functions that needs to be called from init.lua
return {
  gitsigns_keybindings = gitsigns_keybindings,
  markdown_keybindings = markdown_keybindings,
}
