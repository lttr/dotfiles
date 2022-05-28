-- Commit while adding all from ex command
vim.api.nvim_create_user_command(
  "CA",
  function(opts)
    os.execute('git add --all; git commit -m "' .. opts.args .. '"')
  end,
  {nargs = 1}
)

-- Commit from ex command
vim.api.nvim_create_user_command(
  "C",
  function(opts)
    os.execute('git commit -m "' .. opts.args .. '"')
  end,
  {nargs = 1}
)

-- Close all other buffers
vim.api.nvim_create_user_command("Bonly", ':update | %bdelete | edit # | normal `"', {})
