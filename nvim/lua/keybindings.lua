local map = vim.keymap.set
local map_options = {noremap = true, silent = true}

--
----- Keyboard
--
vim.cmd([[
  let mapleader = ","
  let maplocalleader = "\<space>"
]])

local function nmap(left, right)
  map("n", left, right, map_options)
end

local function imap(left, right)
  map("i", left, right, map_options)
end

local function vmap(left, right)
  map("v", left, right, map_options)
end

local function tmap(left, right)
  map("t", left, right, map_options)
end

-- Identify the syntax highlighting group used at the cursor
-- Run :TSHighlightCapturesUnderCursor from treesitter-playground if on Treesitter managed filetype
nmap(
  "<F10>",
  [[:echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>]]
)

-- ===== Saving buffer =====
-- Use ctrl+s for saving, also in Insert mode (from mswin.vim)
map("n", "<C-s>", ":update<CR>", map_options)
map("v", "<C-s>", "<C-C>:update<CR>", map_options)
map("i", "<C-s>", "<Esc>:update<CR>", map_options)

-- comments
nmap("<C-_>", "<cmd>normal gcc<CR>") -- '_' is actually '/'
vmap("<C-_>", "<cmd>normal gc<CR>") -- '_' is actually '/'

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

nmap("]q", "<cmd>cnext<CR>zzzv")
nmap("[q", "<cmd>cprevious<CR>zzzv")

nmap("]c", "<cmd>Gitsigns next_hunk<CR>zzzv")
nmap("[c", "<cmd>Gitsigns prev_hunk<CR>zzzv")

-- Hunks (changes)
nmap("<leader>hs", "<cmd>Gitsigns stage_hunk<CR>")
nmap("<leader>hu", "<cmd>Gitsigns undo_stage_hunk<CR>")
nmap("<leader>hr", "<cmd>Gitsigns reset_hunk<CR>")
nmap("<leader>hx", "<cmd>Gitsigns reset_hunk<CR>")
nmap("<leader>hp", "<cmd>Gitsigns preview_hunk<CR>")

-- Config files
nmap("<leader><leader>x", ":call SaveAndExec()<CR>")

-- ===== Exiting =====
-- Quit buffer without closing the window, no back jumps will be possible (plugin Bbye)
nmap("Q", ":Bwipeout<CR>")
-- Quit window and try to remove the buffer that left from that window
-- nmap("<leader>q", ":q<CR>:bd #<CR>")
nmap("<leader>q", ":q<CR>")
-- Quit window with force
nmap("<leader>Q", ":q!|bd #<CR>")
-- Go to window left and right
nmap("<A-h>", "<C-w>h")
nmap("<A-l>", "<C-w>l")
nmap("<A-j>", "<C-w>j")
nmap("<A-k>", "<C-w>k")
-- open current buffer in vertical split
nmap("<leader>v", ":vsplit<CR>")
-- new files - does not work TODO
nmap("<localleader>fv", ":vsplit <C-r>=expand('%:h')")
nmap("<localleader>fs", ":split %:h")
nmap("<localleader>fe", ":edit %:h")

-- ===== Cut, Copy and Paste =====
-- " Don't yank the contents of an overwritten selection (reyank the original content)
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
nmap("s", '"_diwPb')

-- replace word under cursor, prepare 'n' and '.' to be used subsequently
nmap("cn", "*``cgn")
vmap("s", 'y/<C-r>"<CR>Ncgn')

-- search for selected text
vmap("//", [[y/\V<C-R>=escape(@",'/\')<CR><CR>]])

-- ===== Bubble lines up and down =====
-- Source http://vimrcfu.com/snippet/110
nmap("<A-J>", ":m .+1<CR>==")
nmap("<A-K>", ":m .-2<CR>==")
imap("<A-J>", "<Esc>:m .+1<CR>==")
imap("<A-K>", "<Esc>:m .-2<CR>==")
vmap("<A-J>", ":m '>+1<CR>gv=gv")
vmap("<A-K>", ":m '<-2<CR>gv=gv")

-- Code navigation
nmap("<C-b>", ":normal gd<CR>")

nmap("<C-J", "")

-- Harpoon
nmap("<localleader>1", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>")
nmap("+", "<cmd>lua require('harpoon.mark').add_file()<CR>")
nmap("-", "<cmd>lua require('harpoon.mark').rm_file()<CR>")

nmap("<C-1>", "<cmd>lua require('harpoon.ui').nav_file(1)<CR>")
nmap("<C-2>", "<cmd>lua require('harpoon.ui').nav_file(2)<CR>")
nmap("<C-3>", "<cmd>lua require('harpoon.ui').nav_file(3)<CR>")
nmap("<C-4>", "<cmd>lua require('harpoon.ui').nav_file(4)<CR>")

-- Find references using search
-- nmap("gR", "<cmd>lua require('telescope.builtin').lsp_references()<CR>")

-- Formatting
nmap("<leader>F", "<cmd>FormatWrite<CR>")

-- Executing and running
nmap("<leader>E", ":AsyncRun -save=1 -mode=term -pos=right deno run -A --unstable %:p<CR>")
nmap("<leader>e", "<cmd>%SnipRun<CR>")
nmap("<localleader>E", "<Plug>SnipRun")
nmap("<localleader>e", "<Plug>SnipRunOperator")
vmap("<localleader>e", "<Plug>SnipRun")

-- paset console.log with current variable
-- inspired by https://github.com/meain/vim-printer
nmap("<localleader>l", [[ <cmd>exe "normal yiwoconsole.log('\<C-r>\"', \<C-r>\")"<CR>== ]])
vmap("<localleader>l", [[ <cmd>exe "normal yoconsole.log('\<C-r>\"', \<C-r>\")"<CR>== ]])

-- terminal
nmap("<leader>t", "<cmd>vsplit term://zsh<CR>")
tmap("<Esc>", [[<C-\><C-n>]])
tmap("<Esc>", [[<C-\><C-n>]])
tmap("<A-h>", [[<C-\><C-n><C-w>h]])
tmap("<A-j>", [[<C-\><C-n><C-w>j]])
tmap("<A-k>", [[<C-\><C-n><C-w>k]])
tmap("<A-l>", [[<C-\><C-n><C-w>l]])

-- open word under cursor via OS
nmap("gx", "<cmd>silent execute '!xdg-open ' . shellescape('<cWORD>')<CR>")
vmap("gx", 'y:silent execute \'!xdg-open \' . shellescape(\'<C-r>"\')<CR>')

nmap("gz", "<cmd>silent execute '!xdg-open ' . shellescape('https://duckduckgo.com/?q=') . shellescape('<cWORD>')<CR>")
vmap(
  "gz",
  'y:silent execute \'!xdg-open \' . shellescape(\'https://duckduckgo.com/?q=\') . shellescape(\'<C-r>"\')<CR>'
)

nmap(
  "gZ",
  "<cmd>silent execute '!xdg-open ' . shellescape('https://duckduckgo.com/?q=') . shellescape('!') . shellescape('<cWORD>')<CR>"
)
vmap(
  "gZ",
  'y:silent execute \'!xdg-open \' . shellescape(\'https://duckduckgo.com/?q=!%20\') . shellescape(\'<C-r>"\')<CR>'
)

-- break undo sequence
imap(".", ".<C-g>u")
imap(",", ",<C-g>u")
imap("?", "?<C-g>u")

-- external apps
nmap("<F3>", "<cmd>silent !xdg-open %:p &<CR>")

-- paste file name without extension and without path
imap("<C-f>", "<C-r>=expand('%:t')<CR><Esc>dF.xa")

--
---- telescope
--

local find_files = function()
  return require("telescope.builtin").find_files(
    {
      find_command = {"rg", "--hidden", "--files", "--glob", "!.git"}
    }
  )
end

nmap("<C-p>", find_files)
nmap("<leader>fa", "<cmd>lua require('telescope.builtin').commands()<CR>")
nmap("<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<CR>")
nmap("<leader>fc", "<cmd>lua require('telescope.builtin').command_history()<CR>")
nmap("<leader>fd", "<cmd>lua require('telescope.builtin').lsp_document_diagnostics()<CR>")
nmap("<leader>fD", "<cmd>lua require('telescope.builtin').lsp_workspace_diagnostics()<CR>")
nmap("<leader>fe", "<cmd>lua require('telescope.builtin').oldfiles({previewer=false})<CR>")
nmap("<leader>ff", "<cmd>lua require('telescope.builtin').grep_string()<CR>")

local live_grep = function()
  return require("telescope").extensions.live_grep_raw.live_grep_raw()
end
nmap("<leader>fg", live_grep)

nmap("<leader>fG", "<cmd>lua require('telescope.builtin').live_grep({default_text = vim.fn.expand('<cword>')})<CR>")
nmap("<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<CR>")
nmap("<leader>fi", "<cmd>lua require('telescope.builtin').find_files({cwd='$HOME/dotfiles', previewer=false})<CR>")
nmap("<leader>fI", "<cmd>lua require('telescope.builtin').live_grep({cwd='$HOME/dotfiles'})<CR>")
nmap("<leader>fj", "<cmd>lua require('telescope').extensions.harpoon.marks()<CR>")

local document_symbols = function()
  return require("telescope.builtin").lsp_document_symbols(
    {
      previewer = false,
      layout_config = {width = 90},
      symbols = {"function", "method"}
    }
  )
end

nmap("<leader>fo", document_symbols)
nmap(
  "<leader>fp",
  "<cmd>lua require('telescope').extensions.repo.cached_list{file_ignore_patterns={'/%.cache/', '/%.cargo/', '/%.local/'}}<CR>"
)
nmap("<leader>fr", "<cmd>Telescope file_browser<CR>")
nmap("<leader>fs", "<cmd>lua require('telescope.builtin').search_history()<CR>")
nmap("<leader>ft", "<cmd>lua require('telescope.builtin').git_status()<CR>")
nmap(
  "<leader>fw",
  "<cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols({default_text = vim.fn.expand('<cword>')})<CR>"
)
nmap("<leader>fx", "<cmd>lua require('telescope.builtin').builtin()<CR>")
nmap("<leader>fz", "<cmd>lua require('telescope').extensions.zoxide.list{}<CR>")
nmap("gr", "<cmd>lua require('telescope.builtin').lsp_references()<CR>")

--
-- nvim-lspconfig
--

local function lspKeybindings(client)
  -- build init neovim lsp
  nmap("gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
  nmap("gI", "<cmd>lua vim.lsp.buf.implementation()<CR>")
  nmap("gD", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
  -- nmap("K", "<cmd>lua vim.lsp.buf.hover()<CR>")
  nmap("<localleader>k", "<cmd>lua vim.lsp.buf.hover()<CR>")
  nmap("<localleader>h", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
  nmap("<localleader>s", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
  nmap("<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>")

  -- lspsaga
  nmap("<leader>ca", ":Lspsaga code_action<CR>")
  vmap("<leader>ca", ":<C-U>Lspsaga range_code_action<CR>")
  nmap("K", ":Lspsaga hover_doc<CR>")
  nmap("gh", ":Lspsaga lsp_finder<CR>")
  nmap("]d", ":Lspsaga diagnostic_jump_next<CR>")
  nmap("[d", ":Lspsaga diagnostic_jump_prev<CR>")
  -- nmap("gD", ":Lspsaga preview_definition<CR>")
  nmap("<localleader>d", ":Lspsaga show_line_diagnostics<CR>")

  --
  -- Set some keybinds conditional on server capabilities

  -- I rely on formatter.nvim for now instead of LSP based
  -- formatting. CLI tools has more flexibility
  --
  -- if client.resolved_capabilities.document_formatting then
  --   nmap("<leader>F", "<cmd>lua vim.lsp.buf.formatting()<CR>")
  -- elseif client.resolved_capabilities.document_range_formatting then
  --   nmap("<leader>F", "<cmd>lua vim.lsp.buf.range_formatting()<CR>")
  -- end
end

--
-- nvim-lsp-ts-utils
--
local function lspTsUtilsKeybindings()
  nmap("<localleader>io", ":TSLspOrganize<CR>")
  nmap("<localleader>ir", ":TSLspRenameFile<CR>")
  nmap("<localleader>ia", ":TSLspImportAll<CR>")
end

--
-- Trouble
--
nmap("<leader>d", "<Cmd>TroubleToggle<CR>")

nmap("cod", ":lua vim.diagnostic.config({ virtual_text = {source = 'always'} })<CR>")
nmap("coD", ":lua vim.diagnostic.config({ virtual_text = false })<CR>")

-- inlay hints
nmap("coi", ":TSLspToggleInlayHints<CR>")

--
-- vim-togglelist
--

nmap("col", ":call ToggleLocationList()<CR>")
nmap("coq", ":call ToggleQuickfixList()<CR>")

--
-- nvim-autopairs
--

map("i", "<CR>", "v:lua.MUtils.completion_confirm()", {expr = true, noremap = true})

--
-- vim-fugitive
--

nmap("<leader>gs", ":Git<CR>")

--
-- rnvimr
--

nmap("<leader>r", ":RnvimrToggle<CR>")

-- nvim-tree
nmap("<C-e>", "<cmd>NvimTreeFindFile<CR>")
nmap("<A-1>", "<cmd>NvimTreeToggle<CR>")

-- vim-dirvish
nmap("<leader>D", "<Cmd>Dirvish %<CR>")

--
-- diffview.vim
--

nmap("<leader>do", "<cmd>DiffviewOpen<CR>")
nmap("<leader>dm", "<cmd>DiffviewOpen master..HEAD<CR>")
nmap("<leader>dc", "<cmd>DiffviewClose<CR>")
nmap("<leader>de", "<cmd>DiffviewToggleFiles<CR>")
nmap("<leader>df", "<cmd>DiffviewFileHistory<CR>")
nmap("<leader>di", "<cmd>DiffviewFocusFiles<CR>")
nmap("<leader>dr", "<cmd>DiffviewRefresh<CR>")

--
-- goyo
--
nmap("<leader>G", ":Goyo<CR>")

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
nmap("<localleader>t", ":lua require('rest-nvim').run()<CR>")

--
-- vim-translator
--
-- nahradit the text with translation
nmap("<A-t>", ":TranslateR<CR>")
vmap("<A-t>", ":TranslateR<CR>")

--
-- custom
--

-- start writing a commit message
nmap("<leader>C", "<cmd>call feedkeys(':C<space>', 'n')<CR>")

vim.cmd(
  [[
  function! ExecuteMacroOverVisualRange()
    echo "@".getcmdline()
    execute ":'<,'>normal @".nr2char(getchar())
  endfunction
]]
)
vmap("@", ":<C-u>call ExecuteMacroOverVisualRange()<CR>")

-- export functions that needs to be called from init.lua
return {
  lspKeybindings = lspKeybindings,
  lspTsUtilsKeybindings = lspTsUtilsKeybindings
}
