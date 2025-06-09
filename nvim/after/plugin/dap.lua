-- https://github.com/mfussenegger/nvim-dap
-- https://github.com/mxsdev/nvim-dap-vscode-js

local dap = require("dap")

dap.adapters.node2 = {
  type = "executable",
  command = "node",
  args = {
    os.getenv("HOME")
      .. "/.local/share/nvim/mason/packages/node-debug2-adapter/out/src/nodeDebug.js",
  },
}

local dapui = require("dapui")

dapui.setup({
  layouts = {
    {
      elements = {
        { id = "scopes", size = 0.45 },
        "breakpoints",
        "stacks",
        "watches",
      },
      size = 60,
      position = "right",
    },
  },
})

dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
vim.keymap.set("n", "<leader>ui", require("dapui").toggle)

-- require("dap-vscode-js").setup({
-- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
-- debugger_path = vim.fn.stdpath("data") .. '/mason/packages/js-debug-adapter', -- Path to vscode-js-debug installation.
-- debugger_path = vim.fn.stdpath("data")
--   .. "/lazy/vscode-js-debug",
-- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
-- adapters = {
--   "chrome",
--   "node",
--   "pwa-node",
--   "pwa-chrome",
--   "pwa-msedge",
--   "node-terminal",
--   "pwa-extensionHost",
-- }, -- which adapters to register in nvim-dap
-- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
-- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
-- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
-- })

local js_based_languages =
  { "typescript", "javascript", "typescriptreact", "vue", "svelte" }

for _, language in ipairs(js_based_languages) do
  require("dap").configurations[language] = {
    {
      name = "Launch file",
      type = "node2",
      request = "launch",
      program = "${file}",
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = "inspector",
      console = "integratedTerminal",
    },
    {
      name = "Attach process",
      type = "node2",
      request = "attach",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
      port = 9229,
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
      port = 9229,
    },
    {
      type = "pwa-chrome",
      request = "launch",
      name = 'Start Chrome with "localhost"',
      url = "http://localhost:3000",
      webRoot = "${workspaceFolder}",
      userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir",
    },
  }
end
