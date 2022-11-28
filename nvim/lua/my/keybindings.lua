local utils = require "my.utils"

local default_map_options = { noremap = true, silent = true }

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
nmap("<F9>", "<cmd>TSHighlightCapturesUnderCursor<CR>")
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
-- Quit all other buffers
nmap("<C-w><C-b>", "<cmd>Bonly<CR>")
-- nmap("<C-w><C-o>", ) -- this is default shortcut to close all other windows
-- Go to window left and right
nmap("<A-h>", "<C-w>h")
nmap("<A-l>", "<C-w>l")
nmap("<A-j>", "<C-w>j")
nmap("<A-k>", "<C-w>k")

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

-- replace word under cursor, prepare 'n' and '.' to be used subsequently
nmap("gr", "*``cgn")
vmap("gr", 'y/<C-r>"<CR>Ncgn')
-- "gs" -- Go Substitute word under cursor (vim-substitute plugin)
vmap("*", [[y/\V<c-r>=escape(@",'/\')<cr><cr>]])

-- visual multi - cursor addition
-- add cursor on current line and move down/up
nmap("<C-j>", ":call vm#commands#add_cursor_down(0, v:count1)<CR>")
nmap("<C-k>", ":call vm#commands#add_cursor_up(0, v:count1)<CR>")
-- create cursor for every line in current paragraph
nmap("<localleader>m", "vip:call vm#commands#visual_cursors()<CR>")
-- create cursor for every occurance of current word
nmap("<localleader>M", ":call vm#commands#find_all(0, 1)<CR>")

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

-- tags
-- remap emmet (https://github.com/mattn/emmet-vim/issues/86)
-- 'yat' creates a visual flash of the paragraph to help identify the scope of
-- change, 'dd' removes the ending tag and 'ds>' the starting tag
nmap("<C-Y>k", "yatvat<Esc>dd`<da>")

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

-- Formatting
nmap("<leader>F", "<cmd>FormatWrite<CR>")

-- Executing and running
nmap("<leader>r", "<cmd>AsyncRun -save=1 -mode=term -pos=right deno run -A --unstable %:p<CR>")
nmap("<leader>t", "<cmd>AsyncRun -save=1 -mode=term -pos=right deno test -A %:p<CR>")
nmap(
  "<leader>T",
  function()
    require("neotest").run.run(vim.fn.expand("%"))
  end
)
nmap("<leader>a", ":AsyncRun -save=1 -mode=term -pos=right %:p<CR>")
nmap("<leader>e", "<cmd>%SnipRun<CR>")
vmap("<localleader>ee", "<Plug>SnipRun")
vmap("<localleader>j", utils.evaluate_js)

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
-- nmap("<leader>T", "<cmd>vsplit term://zsh<CR>")
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

local telescopeBuildin = require "telescope.builtin"
local telescope = require "telescope"

local find_files = function()
  return telescopeBuildin.find_files(
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
  return telescopeBuildin.lsp_document_symbols(
    {
      previewer = false,
      layout_config = { width = 90 },
      symbols = { "function", "method" }
    }
  )
end

local live_grep = function()
  return telescope.extensions.live_grep_args.live_grep_args()
end

local recent_files = function()
  return telescope.extensions.recent_files.pick()
end

nmap("<C-p>", find_files)
imap(
  "<C-t>",
  function()
    telescopeBuildin.find_files(
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

nmap("<leader>fa", telescopeBuildin.commands)
nmap("<leader>fb", telescopeBuildin.buffers)
nmap("<leader>fc", telescopeBuildin.command_history)
nmap(
  "<leader>fd",
  function()
    telescopeBuildin.lsp_document_diagnostics()
  end
)
nmap(
  "<leader>fD",
  function()
    telescopeBuildin.lsp_workspace_diagnostics()
  end
)
nmap("<leader>fe", recent_files)
nmap("<leader>ff", telescopeBuildin.grep_string)
nmap("<leader>fg", live_grep)
vmap(
  "<leader>fg",
  function()
    telescopeBuildin.live_grep({ default_text = GetVisualSelection() })
  end
)
nmap(
  "<leader>fG",
  function()
    telescopeBuildin.live_grep({ default_text = vim.fn.expand("<cword>") })
  end
)
nmap("<leader>fh", telescopeBuildin.help_tags)
vmap(
  "<leader>fh",
  function()
    telescopeBuildin.help_tags({ default_text = GetVisualSelection() })
  end
)
nmap(
  "<leader>fi",
  function()
    telescopeBuildin.find_files({ cwd = "$HOME/dotfiles" })
  end
)
nmap(
  "<leader>fI",
  function()
    telescopeBuildin.live_grep({ cwd = "$HOME/dotfiles" })
  end
)
nmap("<leader>fj", telescope.extensions.harpoon.marks)
nmap("<leader>fk", telescopeBuildin.keymaps)
nmap("<leader>fl", telescope.extensions.buffer_lines.buffer_lines)

nmap("<leader>fo", document_symbols)
nmap(
  "<leader>fp",
  function()
    telescope.extensions.repo.cached_list { file_ignore_patterns = { "/%.cache/", "/%.cargo/", "/%.local/" } }
  end
)
nmap(
  "<leader>fw",
  function()
    -- open file browser in folder of current file
    telescope.extensions.file_browser.file_browser({ path = "%:p:h", cwd_to_path = true })
  end
)
nmap(
  "<leader>fs",
  function()
    telescopeBuildin.search_history()
  end
)
nmap("<leader>ft", telescopeBuildin.git_status)
nmap("<leader>fx", telescopeBuildin.builtin)
nmap("<leader>fz", telescope.extensions.zoxide.list)
nmap("<leader>fr", telescopeBuildin.lsp_references)

--
-- nvim-lspconfig
--

local function lsp_keybindings(client)
end

-- build init neovim lsp
nmap("gd", vim.lsp.buf.definition)
nmap("gI", vim.lsp.buf.implementation)
nmap("gD", vim.lsp.buf.type_definition)
nmap("gR", vim.lsp.buf.references)
nmap("<localleader>k", vim.lsp.buf.hover)
nmap("<localleader>h", vim.lsp.buf.signature_help)
nmap("<localleader>s", vim.lsp.buf.signature_help)
nmap("<F2>", vim.lsp.buf.rename)

-- code actions and refactoring
nmap("<leader>ca", vim.lsp.buf.code_action)
vmap("<leader>ca", vim.lsp.buf.code_action)
vmap("<localleader>er", require("react-extract").extract_to_current_file)
vmap("<localleader>ef", require("react-extract").extract_to_new_file)

nmap("]d", vim.diagnostic.goto_next)
nmap("[d", vim.diagnostic.goto_prev)
nmap("<localleader>d", vim.diagnostic.open_float)

--
-- typescript.nvim
--
nmap("<localleader>yo", require "typescript".actions.organizeImports)
nmap("<localleader>ya", require "typescript".actions.addMissingImports)
nmap("<localleader>yu", require "typescript".actions.removeUnused)
nmap("<localleader>yr", "<cmd>TypescriptRenameFile<CR>")

--
-- Trouble
--
nmap("cot", "<Cmd>TroubleToggle<CR>")

-- inlay hints
nmap("coi", ":TSLspToggleInlayHints<CR>")

-- diagnostic hints
nmap("cov", require("lsp_lines").toggle)

nmap(
  "cod",
  function()
    ToggleDiagnostics()
  end
)

--
-- vim-togglelist
--

nmap("coq", ":call ToggleQuickfixList()<CR>")

--
-- nvim-autopairs
--

mymap("i", "<CR>", "v:lua.MUtils.completion_confirm()", { expr = true, noremap = true })

--
-- gitsigns
--

local function gitsigns_keybindings(bufnr)
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
    { expr = true }
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
    { expr = true }
  )

  -- Actions
  mymap({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", default_map_options, bufnr)
  mymap({ "n", "v" }, "<leader>hx", ":Gitsigns reset_hunk<CR>", default_map_options, bufnr)
  mymap("n", "<leader>hu", gs.undo_stage_hunk, default_map_options, bufnr)
  mymap("n", "<leader>hp", gs.preview_hunk, default_map_options, bufnr)
  mymap(
    "n",
    "<leader>hb",
    function()
      gs.blame_line { full = true }
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
  mymap({ "o", "x" }, "ih", gs.select_hunk, default_map_options, bufnr)
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

--
-- rnvimr
--

-- also Alt-o
-- nmap("<leader>R", ":RnvimrToggle<CR>")

-- nvim-tree
nmap("<C-e>", "<cmd>NvimTreeFindFile<CR>")
nmap("<A-`>", "<cmd>NvimTreeToggle<CR>")

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
nmap("<leader>z", require "zen-mode".toggle)

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
nmap("<localleader>T", require "rest-nvim".last)
nmap("<localleader>t", require "rest-nvim".run)

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
  gitsigns_keybindings = gitsigns_keybindings,
  lsp_keybindings = lsp_keybindings
}
