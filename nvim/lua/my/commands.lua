-- Commit while adding all from ex command
vim.api.nvim_create_user_command(
  "CA",
  function(opts)
    os.execute('git add --all; git commit -m "' .. opts.args .. '"')
  end,
  { nargs = 1 }
)

-- Stage all files
vim.api.nvim_create_user_command("GA", "Git add --all", {})
-- Push
vim.api.nvim_create_user_command("GP", "Git push", {})

-- Commit from ex command
vim.api.nvim_create_user_command(
  "C",
  function(opts) os.execute('git commit -m "' .. opts.args .. '"') end,
  { nargs = 1 }
)

-- Create new file next to current one
vim.api.nvim_create_user_command("N", ":sp %:h/<args>", { nargs = 1 })

-- Close all other buffers
vim.api.nvim_create_user_command(
  "Bonly",
  ':update | %bdelete | edit # | normal `"',
  {}
)

-- Plugin manager
vim.api.nvim_create_user_command("PI", "PackerInstall", {})
vim.api.nvim_create_user_command("PS", "PackerSync", {})

-- Restart LSP service sometimes necessary to pick up external changes
vim.api.nvim_create_user_command("LR", "LspRestart", {})
-- Show LSP info
vim.api.nvim_create_user_command("LI", "LspInfo", {})

-- Extract matching lines into new buffer (http://vim.wikia.com/wiki/VimTip1063)
vim.api.nvim_create_user_command(
  "Filter",
  [[let @a='' | execute 'g/<args>/y A' | new | setlocal bt=nofile | put! a]],
  { nargs = 1 }
)
