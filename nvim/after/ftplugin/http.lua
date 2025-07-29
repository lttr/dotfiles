vim.keymap.set(
  "n",
  "<leader>r",
  function() require("kulala").run() end,
  { silent = true, noremap = false, desc = "Run HTTP request" }
)
