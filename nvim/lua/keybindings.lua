local map = vim.keymap.set
local default_map_options = {noremap = true, silent = true}

--
----- Keyboard
--
vim.cmd([[
  let mapleader = ","
  let maplocalleader = "\<space>"
]])

local function mymap(mode, lhs, rhs, opts, bufnr)
  opts = opts or default_map_options
  if bufnr then
    opts.buffer = bufnr
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function nmap(left, right)
  mymap("n", left, right)
end

local function imap(left, right)
  mymap("i", left, right)
end

local function vmap(left, right)
  mymap("v", left, right)
end

local function tmap(left, right)
  mymap("t", left, right)
end

-- Identify the syntax highlighting group used at the cursor
-- Run :TSHighlightCapturesUnderCursor from treesitter-playground if on Treesitter managed filetype
nmap(
  "<F10>",
  [[:echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<" . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>]]
)

-- ===== Saving buffer =====
-- Use ctrl+s for saving, also in Insert mode (from mswin.vim)
nmap("<C-s>", ":update<CR>")
vmap("<C-s>", "<C-C>:update<CR>")
imap("<C-s>", "<Esc>:update<CR>")

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
-- Go to window left and right
nmap("<A-h>", "<C-w>h")
nmap("<A-l>", "<C-w>l")
nmap("<A-j>", "<C-w>j")
nmap("<A-k>", "<C-w>k")

-- open current buffer in vertical split
nmap("<leader>vv", ":vsplit<CR>")
nmap("<leader>vs", ":split<CR>")

-- expand the current buffer's path on ex command line
mymap("c", "%%", "getcmdtype() == ':' ? expand('%:h').'/' : '%%'", {expr = 1})

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
-- while preparing silently for repeated actions ('n' or '.')
nmap("s", "*``cgn<C-r>0<Esc><C-l>")

-- replace word under cursor, prepare 'n' and '.' to be used subsequently
nmap("gr", "*``cgn")
vmap("gr", 'y/<C-r>"<CR>Ncgn')
-- "gs" -- Go Substitute word under cursor (vim-substitute plugin)
vmap("*", [[y/\V<c-r>=escape(@",'/\')<cr><cr>]])

-- visual multi - cursor addition
nmap("<C-j>", ":call vm#commands#add_cursor_down(0, v:count1)<cr>")
nmap("<C-k>", ":call vm#commands#add_cursor_up(0, v:count1)<cr>")

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
-- nmap("<C-b>", ":normal gd<CR>")

-- Harpoon
nmap("<leader>1", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>")
nmap("+", "<cmd>lua require('harpoon.mark').add_file()<CR><cmd>lua require('notify').notify('harpooned')<CR>")
nmap("-", "<cmd>lua require('harpoon.mark').rm_file()<CR>")

nmap("<C-1>", "<cmd>lua require('harpoon.ui').nav_file(1)<CR>")
nmap("<C-2>", "<cmd>lua require('harpoon.ui').nav_file(2)<CR>")
nmap("<C-3>", "<cmd>lua require('harpoon.ui').nav_file(3)<CR>")
nmap("<C-4>", "<cmd>lua require('harpoon.ui').nav_file(4)<CR>")

-- Find references using search
-- nmap("gR", function() tb.lsp_references() end)

-- Formatting
nmap("<leader>F", "<cmd>FormatWrite<CR>")

-- Executing and running
nmap("<leader>r", "<cmd>AsyncRun -save=1 -mode=term -pos=right deno run -A --unstable %:p<CR>")
nmap("<leader>t", "<cmd>AsyncRun -save=1 -mode=term -pos=right deno test -A %:p<CR>")
nmap("<leader>a", ":AsyncRun -save=1 -mode=term -pos=right %:p<CR>")
nmap("<leader>e", "<cmd>%SnipRun<CR>")
vmap("<localleader>e", "<Plug>SnipRun")
vmap("<localleader>j", EvaluateJs)

-- help
nmap("<localleader>H", ":help <C-r><C-w><CR>")

-- paset console.log with current variable
-- inspired by https://github.com/meain/vim-printer
nmap("<localleader>l", [[ <cmd>exe "normal yiwoconsole.log('\<C-r>\"', \<C-r>\")"<CR>== ]])
vmap("<localleader>l", [[ <cmd>exe "normal yoconsole.log('\<C-r>\"', \<C-r>\")"<CR>== ]])

-- ensure , at the end of a line
nmap("<localleader>,", "<cmd>s/,*$/,/<CR><cmd>:nohls<CR>``")
-- ensure ; at the end of a line
nmap("<localleader>;", "<cmd>s/;*$/;/<CR><cmd>:nohls<CR>``")

-- terminal
nmap("<leader>T", "<cmd>vsplit term://zsh<CR>")
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

-- surround
nmap("y`", "<cmd>normal ysiw`<CR>")
nmap("y'", "<cmd>normal ysiw'<CR>")
nmap('y"', '<cmd>normal ysiw"<CR>')

--
---- telescope
--

local tb = require "telescope.builtin"
local tel = require "telescope"

local find_files = function()
  return tb.find_files(
    {
      find_command = {
        "rg",
        "--hidden",
        "--files",
        "--no-ignore",
        "--glob",
        "!.git",
        "--glob",
        "!node_modules",
        "--glob",
        "!build/",
        "--glob",
        "!dist/",
        "--glob",
        "!.lock"
      }
    }
  )
end

local document_symbols = function()
  return tb.lsp_document_symbols(
    {
      previewer = false,
      layout_config = {width = 90},
      symbols = {"function", "method"}
    }
  )
end

local live_grep = function()
  return tel.extensions.live_grep_args.live_grep_args()
end

nmap("<C-p>", find_files)
imap(
  "<C-t>",
  function()
    tb.find_files(
      {
        mappings = {
          i = {
            ["<CR>"] = require "telescope.actions".my_select_action
          }
        }
      }
    )
  end
)

nmap(
  "<leader>fa",
  function()
    tb.commands()
  end
)
nmap(
  "<leader>fb",
  function()
    tb.buffers()
  end
)
nmap(
  "<leader>fc",
  function()
    tb.command_history()
  end
)
nmap(
  "<leader>fd",
  function()
    tb.lsp_document_diagnostics()
  end
)
nmap(
  "<leader>fD",
  function()
    tb.lsp_workspace_diagnostics()
  end
)
nmap(
  "<leader>fe",
  function()
    tb.oldfiles({previewer = false})
  end
)
nmap(
  "<leader>ff",
  function()
    tb.grep_string()
  end
)
nmap("<leader>fg", live_grep)
vmap(
  "<leader>fg",
  function()
    tb.live_grep({default_text = GetVisualSelection()})
  end
)
nmap(
  "<leader>fG",
  function()
    tb.live_grep({default_text = vim.fn.expand("<cword>")})
  end
)
nmap(
  "<leader>fh",
  function()
    tb.help_tags()
  end
)
vmap(
  "<leader>fh",
  function()
    tb.help_tags({default_text = GetVisualSelection()})
  end
)
nmap(
  "<leader>fi",
  function()
    tb.find_files({cwd = "$HOME/dotfiles", previewer = false})
  end
)
nmap(
  "<leader>fI",
  function()
    tb.live_grep({cwd = "$HOME/dotfiles"})
  end
)
nmap(
  "<leader>fj",
  function()
    tb.extensions.harpoon.marks()
  end
)
nmap(
  "<leader>fk",
  function()
    tb.keymaps()
  end
)
nmap(
  "<leader>fl",
  function()
    tel.extensions.buffer_lines.buffer_lines()
  end
)

nmap("<leader>fo", document_symbols)
nmap(
  "<leader>fp",
  function()
    tb.extensions.repo.cached_list {file_ignore_patterns = {"/%.cache/", "/%.cargo/", "/%.local/"}}
  end
)
nmap("<leader>fr", "<cmd>Telescope file_browser<CR>")
nmap(
  "<leader>fs",
  function()
    tb.search_history()
  end
)
nmap(
  "<leader>ft",
  function()
    tb.git_status()
  end
)
nmap(
  "<leader>fw",
  function()
    tb.lsp_dynamic_workspace_symbols({default_text = vim.fn.expand("<cword>")})
  end
)
nmap(
  "<leader>fx",
  function()
    tb.builtin()
  end
)
nmap(
  "<leader>fz",
  function()
    tb.extensions.zoxide.list {}
  end
)
nmap(
  "<localleader>r",
  function()
    tb.lsp_references()
  end
)

--
-- nvim-lspconfig
--

local function lspKeybindings(client)
end

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
nmap("<localleader>d", "<cmd>Lspsaga show_line_diagnostics<CR>")

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
nmap("cod", "<Cmd>TroubleToggle<CR>")

-- inlay hints
nmap("coi", ":TSLspToggleInlayHints<CR>")

-- diagnostic hints
nmap("cov", require("lsp_lines").toggle)

--
-- vim-togglelist
--

nmap("col", ":call ToggleLocationList()<CR>")
nmap("coq", ":call ToggleQuickfixList()<CR>")

--
-- nvim-autopairs
--

mymap("i", "<CR>", "v:lua.MUtils.completion_confirm()", {expr = true, noremap = true})

--
-- gitsigns
--

local function gitsignsKeybindings(bufnr)
  local gs = package.loaded.gitsigns

  -- Navigation
  mymap(
    "n",
    "]c",
    function()
      if vim.wo.diff then
        return "]c"
      end
      vim.schedule(
        function()
          gs.next_hunk()
        end
      )
      return "<Ignore>"
    end,
    {expr = true}
  )

  mymap(
    "n",
    "[c",
    function()
      if vim.wo.diff then
        return "[c"
      end
      vim.schedule(
        function()
          gs.prev_hunk()
        end
      )
      return "<Ignore>"
    end,
    {expr = true}
  )

  -- Actions
  mymap({"n", "v"}, "<leader>hs", ":Gitsigns stage_hunk<CR>", default_map_options, bufnr)
  mymap({"n", "v"}, "<leader>hx", ":Gitsigns reset_hunk<CR>", default_map_options, bufnr)
  mymap("n", "<leader>hu", gs.undo_stage_hunk, default_map_options, bufnr)
  mymap("n", "<leader>hp", gs.preview_hunk, default_map_options, bufnr)
  mymap(
    "n",
    "<leader>hb",
    function()
      gs.blame_line {full = true}
    end
  )

  mymap("n", "<leader>hS", gs.stage_buffer, default_map_options, bufnr)
  mymap("n", "<leader>hX", gs.reset_buffer, default_map_options, bufnr)
  mymap("n", "<leader>hd", gs.diffthis, default_map_options, bufnr)
  mymap(
    "n",
    "<leader>hD",
    function()
      gs.diffthis("~")
    end,
    default_map_options,
    bufnr
  )
  mymap("n", "<leader>he", gs.toggle_deleted, default_map_options, bufnr)

  -- Text object
  mymap({"o", "x"}, "ih", ":<C-U>Gitsigns select_hunk<CR>", default_map_options, bufnr)
end

--
-- vim-fugitive
--

nmap("<leader>gs", "<cmd>Git<CR>")
nmap("<leader>gl", "<cmd>GV<CR>")
nmap("<leader>gh", "<cmd>GV!<CR>")
nmap("<leader>gp", "<cmd>Git push<CR>")

--
-- rnvimr
--

nmap("<leader>R", ":RnvimrToggle<CR>")

-- nvim-tree
nmap("<C-e>", "<cmd>NvimTreeFindFile<CR>")
nmap("<A-`>", "<cmd>NvimTreeToggle<CR>")

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
-- Zen mode
--
nmap(
  "<leader>z",
  function()
    require("zen-mode").toggle()
  end
)

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
nmap(
  "<localleader>T",
  function()
    require("rest-nvim").last()
  end
)

nmap(
  "<localleader>t",
  function()
    require("rest-nvim").run()
  end
)

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
  gitsignsKeybindings = gitsignsKeybindings,
  lspKeybindings = lspKeybindings,
  lspTsUtilsKeybindings = lspTsUtilsKeybindings
}
