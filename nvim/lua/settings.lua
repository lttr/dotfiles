local opt = vim.opt

-- General

opt.iskeyword:append("-") -- Count strings joined by dashes as words

vim.g.maplocalleader = "<space>"

-- Tabs and indentation
opt.tabstop = 2 -- Number of spaces that <Tab> counts for
opt.softtabstop = 2 -- Tabs and Backspaces feels like <Tab>
opt.shiftwidth = 2 -- Number of spaces to use for each step of indent
opt.shiftround = true -- Round the size of indentation (using < and >) to shiftwidth
opt.virtualedit = "" -- Do not move the cursor behind last char

-- Appearance
opt.number = true
opt.numberwidth = 3
opt.signcolumn = "yes:1"
opt.updatetime = 700

-- Buffers
opt.hidden = true -- Allow buffer switching without saving
opt.splitright = true -- Puts new vsplit windows to the right of the current
opt.splitbelow = true -- Puts new split windows to the bottom of the current

-- Wrapping
opt.linebreak = true -- Don't wrap words

-- Search
opt.ignorecase = true -- Search case-insensitive
opt.smartcase = true -- ...except upper-case included

-- Mouse
opt.mouse = "a" -- Enable the use of mouse in terminal

-- Lines
opt.formatoptions:remove("o") -- Don't insert comment leader after 'o'
opt.scrolloff = 1 -- Let one line above and bellow
opt.sidescroll = 1
opt.sidescrolloff = 15
opt.joinspaces = false -- Prevents inserting two spaces after punctuation on a join (J)

-- Visual
opt.lazyredraw = true -- Postpone rendering after macro ans similar is done

-- Completion options
opt.completeopt = "menu,menuone"

-- Undo
opt.undofile = true -- Automatically saves undo history to an undo file

-- Terminal
opt.shell = "/usr/bin/zsh"

-- Search
vim.cmd(
  [[
  if executable("rg")
    set grepprg=rg\ --vimgrep\ --smart-case\ --engine\ auto\ --hidden
    set grepformat=%f:%l:%c:%m
  endif
]]
)
