local opt = vim.opt


-- General

opt.iskeyword:append('-') -- Count strings joined by dashes as words

-- ===== Tabs and indentation =====
opt.tabstop = 2 -- Number of spaces that <Tab> counts for
opt.softtabstop = 2 -- Tabs and Backspaces feels like <Tab>
opt.shiftwidth = 2 -- Number of spaces to use for each step of indent
opt.shiftround = true -- Round the size of indentation (using < and >) to shiftwidth
opt.virtualedit = "" -- Do not move the cursor behind last char

-- appearance
opt.number = true
opt.numberwidth = 3
opt.signcolumn = "yes:1"

-- ===== Buffers =====
opt.hidden = true -- Allow buffer switching without saving
opt.splitright = true -- Puts new vsplit windows to the right of the current
opt.splitbelow = true -- Puts new split windows to the bottom of the current

-- ===== Wrapping =====
opt.linebreak = true -- Don't wrap words

-- ===== Search =====
opt.ignorecase = true -- Search case-insensitive
opt.smartcase = true -- ...except upper-case included

-- ===== Mouse =====
opt.mouse = "a" -- Enable the use of mouse in terminal

-- ===== Lines =====
opt.formatoptions:remove('o') -- Don't insert comment leader after 'o'
opt.scrolloff = 1 -- Let one line above and bellow
opt.sidescroll = 1
opt.sidescrolloff = 15
opt.joinspaces = false -- Prevents inserting two spaces after punctuation on a join (J)

-- Visual
opt.lazyredraw = true -- Postpone rendering after macro ans similar is done

-- completion options
opt.completeopt = "menu,menuone"

-- Undo
opt.undofile = true -- Automatically saves undo history to an undo file

-- terminal
opt.shell = "/usr/bin/zsh"

-- colors
local nightfox = require "nightfox"
nightfox.setup(
  {
    fox = "nordfox",
    colors = {bg = "#2d2d2d"}
  }
)
nightfox.load()

-- search
vim.cmd([[
  if executable("rg")
    set grepprg=rg\ --vimgrep\ --smart-case\ --engine\ auto\ --hidden
    set grepformat=%f:%l:%c:%m
  endif
]])

-- autocommands

-- Start terminal in insert mode
vim.cmd(
  [[
    augroup term
      autocmd!
      autocmd TermOpen * startinsert
    augroup END
  ]],
  true
)

-- Restore last cursor position and center the screen,
-- do it only if the cursor is not on first line
vim.cmd(
  [[
    augroup last_position
      autocmd!
      autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe 'normal! g`"zvzz' | endif
    augroup END
  ]],
  true
)
