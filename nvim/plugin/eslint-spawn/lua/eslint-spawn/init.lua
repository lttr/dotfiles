-- Credits: https://github.com/mfussenegger/nvim-lint/blob/master/lua/lint/linters/eslint.lua

local Job = require("plenary.job")

local BINARY_NAME = "eslint"
local SEVERITIES = {
  vim.diagnostic.severity.WARN,
  vim.diagnostic.severity.ERROR,
}

local namespace = vim.api.nvim_create_namespace(BINARY_NAME)

local function args()
  return { '--format', 'json', vim.fn.getcwd() }
end

local function command()
  local local_binary = vim.fn.fnamemodify('./node_modules/.bin/' .. BINARY_NAME, ':p')
  return vim.loop.fs_stat(local_binary) and local_binary or BINARY_NAME
end

local function publish(diagnostics, bufnr)
  if vim.api.nvim_buf_is_valid(bufnr) then
    vim.diagnostic.set(namespace, bufnr, diagnostics)
  end
end

local function parser(output)
  if vim.trim(output) == "" then
    return {}
  end
  local decode_opts = { luanil = { object = true, array = true } }
  local ok, data = pcall(vim.json.decode, output, decode_opts)
  if not ok then
    return {
      {
        lnum = 0,
        col = 0,
        message = "Could not parse linter output due to: " .. data .. "\noutput: " .. output
      }
    }
  end
  -- See https://eslint.org/docs/latest/use/formatters/#json
  local diagnostics = {}
  for _, result in ipairs(data or {}) do
    for _, msg in ipairs(result.messages or {}) do
      local diagnostic = {
        lnum = msg.line and (msg.line - 1) or 0,
        end_lnum = msg.endLine and (msg.endLine - 1) or nil,
        col = msg.column and (msg.column - 1) or 0,
        end_col = msg.endColumn and (msg.endColumn - 1) or nil,
        message = msg.message,
        code = msg.ruleId,
        severity = SEVERITIES[msg.severity],
        source = BINARY_NAME
      }
      table.insert(diagnostics, {
        file = result.filePath,
        diagnostic = diagnostic
      })
    end
  end
  return diagnostics
end

local function run_eslint()
  local output
  Job:new({
    command = command(),
    args = args(),
    on_stdout = function(_, return_val)
      output = return_val
    end,
    on_stderr = function(_, return_val)
      output = return_val
    end,
  }):sync()

  return output
end


local function go()
  -- remove all current diagnostics in order to prevend duplicates
  vim.diagnostic.reset()
  local eslint_result = run_eslint()
  local parser_result = parser(eslint_result)
  local counter_warn = 0
  local counter_error = 0
  for _, item in ipairs(parser_result) do
    -- open buffer for every file with linting error
    local bufnr = vim.fn.bufadd(item.file)
    -- add bufnr into the diagnostic table
    local diagnostic = vim.tbl_extend("force", item.diagnostic, { bufnr = bufnr })
    publish({ diagnostic }, bufnr)
    if (diagnostic.severity == vim.diagnostic.severity.WARN) then
      counter_warn = counter_warn + 1
    else
      counter_error = counter_error + 1
    end
  end
  -- print how many diagnostics were published
  if counter_error > 0 or counter_warn > 0 then
    print("Found " ..
      counter_error .. " linting errors and " .. counter_warn .. " warnings.")
    vim.diagnostic.setqflist({ name = namespace, open = true })
  else
    print("No linting errors found.")
  end
end


return {
  go = go,
}
