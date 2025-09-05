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
vim.api.nvim_create_user_command("PI", "Lazy install", {})
vim.api.nvim_create_user_command("PS", "Lazy sync", {})

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

-- Lint all files in current working directory using Eslint
vim.api.nvim_create_user_command(
  "Eslint",
  function() require("eslint-spawn").go() end,
  {}
)

-- Open a new buffer with the contents of :mess
vim.api.nvim_create_user_command("Messages", function()
  local messages = vim.fn.execute("messages")
  vim.cmd("split")
  vim.cmd("enew")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(messages, "\n"))
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.filetype = "bash"
end, {})
vim.api.nvim_create_user_command("Mess", "Messages", {})

vim.api.nvim_create_user_command(
  "Date",
  function() vim.cmd("normal i" .. " " .. os.date("%Y-%m-%d")) end,
  {}
)

-- Get active LSP clients
vim.api.nvim_create_user_command("ActiveLsp", function()
  vim.print(
    vim.tbl_map(
      function(c) return c.name end,
      vim.lsp.get_clients({ bufnr = 0 })
    )
  )
end, {})
