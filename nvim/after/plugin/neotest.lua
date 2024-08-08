-- https://github.com/nvim-neotest/neotest

require("neotest").setup({
  adapters = {
    require("neotest-jest")({
      jestCommand = "npm test --",
      jestConfigFile = "jest.config.ts",
      env = { CI = true },
      cwd = function() return vim.fn.getcwd() end,
    }),
  },
})
