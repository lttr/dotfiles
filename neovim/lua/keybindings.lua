local map = vim.api.nvim_set_keymap
local map_options = {noremap = true, silent = true}

--
----- Keyboard
--

vim.g.mapleader = ","
vim.g.maplocalleader = " "

local function nmap(left, right)
  map("n", left, right, map_options)
end

local function imap(left, right)
  map("i", left, right, map_options)
end

local function vmap(left, right)
  map("v", left, right, map_options)
end

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

-- ===== Open and reload $MYVIMRC =====
nmap("<leader>V", ":e $MYVIMRC<CR>")
nmap("<A-s>", ":e $MYVIMRC<CR>")
nmap("<leader><leader>x", ":call SaveAndExec()<CR>")

-- ===== Exiting =====
-- Quit buffer without closing the window (plugin Bbye)
nmap("Q", ":Bdelete<CR>")
-- Quit window
nmap("<leader>q", ":q<CR>")
-- Quit window with force
nmap("<leader>Q", ":q!<CR>")
-- Go to window left and right
nmap("<A-h>", "<C-w>h")
nmap("<A-l>", "<C-w>l")
nmap("<A-j>", "<C-w>j")
nmap("<A-k>", "<C-w>k")

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

-- Go substitute (case sensitive)
vmap("gs", [[y:set hls<CR>/\C<C-r>"<CR>``:%s/<C-r>"//g<Left><Left>]])
-- Go substitute word (case sensitive)
nmap("gs", [[:set hls<CR>:%s/\C\<<C-r><C-w>\>//g<Left><Left>]])

-- ===== Bubble lines up and down =====
-- Source http://vimrcfu.com/snippet/110
nmap("<A-J>", ":m .+1<CR>==")
nmap("<A-K>", ":m .-2<CR>==")
vmap("<A-J>", ":m '>+1<CR>gv=gv")
vmap("<A-K>", ":m '<-2<CR>gv=gv")

-- Code navigation
nmap("<C-b>", ":normal gd<CR>")

-- Formatting
nmap("<leader>F", "<cmd>FormatWrite<CR>")

-- Executing and running
nmap("<leader>e", ":AsyncRun -save=1 -mode=term -pos=right deno run -A --unstable %:p<CR>")

--
---- telescope
--

nmap("<C-p>", "<cmd> lua require('telescope.builtin').find_files({ hidden = true })<CR>")
nmap("<leader>fD", "<cmd>lua require('telescope.builtin').lsp_workspace_diagnostics()<CR>")
nmap("<leader>fa", "<cmd>lua require('telescope.builtin').commands()<CR>")
nmap("<leader>fb", "<cmd>lua require('telescope.builtin').buffers()<CR>")
nmap("<leader>fc", "<cmd>lua require('telescope.builtin').command_history()<CR>")
nmap("<leader>fd", "<cmd>lua require('telescope.builtin').lsp_document_diagnostics()<CR>")
nmap("<leader>fe", "<cmd>lua require('telescope.builtin').oldfiles({ previewer = false })<CR>")
nmap("<leader>ff", "<cmd>lua require('telescope.builtin').grep_string()<CR>")
nmap("<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<CR>")
nmap("<leader>fgi", "<cmd>lua require('telescope.builtin').git_commits()<CR>")
nmap("<leader>fgs", "<cmd>lua require('telescope.builtin').git_status({layout_strategy='horizontal'})<CR>")
nmap("<leader>fh", "<cmd>lua require('telescope.builtin').help_tags()<CR>")
nmap("<leader>fn", "<cmd>lua require('telescope.builtin').lsp_references()<CR>")
nmap("<leader>fo", "<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>")
nmap("<leader>fp", "<cmd>lua require('session-lens').search_session()<CR>")
nmap("<leader>fr", "<cmd>lua require('telescope.builtin').file_browser({ hidden = true })<CR>")
nmap("<leader>fs", "<cmd>lua require('telescope.builtin').search_history()<CR>")
nmap("<leader>fw", "<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<CR>")
nmap("<leader>fx", "<cmd>lua require('telescope.builtin').builtin()<CR>")
nmap("<leader>fz", "<cmd>lua require('telescope').extensions.zoxide.list{}<CR>")

--
-- nvim-lspconfig
--

local function lspKeybindings(client)
  nmap("gd", "<Cmd>lua vim.lsp.buf.definition()<CR>")
  nmap("gI", "<cmd>lua vim.lsp.buf.implementation()<CR>")
  nmap("<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>")
  nmap("<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>")
  nmap("<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>")
  nmap("gD", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
  nmap("gr", "<cmd>lua vim.lsp.buf.references()<CR>")
  nmap("<leader>l", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>")

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
-- lspsaga
--

nmap("<leader>ca", ":Lspsaga code_action<CR>")
vmap("<leader>ca", ":<C-U>Lspsaga range_code_action<CR>")
nmap("K", ":Lspsaga hover_doc<CR>")
nmap("<C-h>", ":Lspsaga signature_help<CR>")
nmap("gh", ":Lspsaga lsp_finder<CR>")

nmap("]d", ":Lspsaga diagnostic_jump_next<CR>")
nmap("[d", ":Lspsaga diagnostic_jump_prev<CR>")
nmap("<f2>", ":Lspsaga rename<CR>")
nmap("gD", ":Lspsaga preview_definition<CR>")
nmap("<localleader>d", ":Lspsaga show_line_diagnostics<CR>")

--
-- vim-togglelist
--

nmap("coa", ":call ToggleLocationList()<CR>")
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

--
-- diffview.vim
--

nmap("<leader>do", "<cmd>DiffviewOpen<CR>")
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
-- custom
--

nmap("<leader>c", ":C<space>")

-- export functions that needs to be called from init.lua
return {
  lspKeybindings = lspKeybindings
}
