-- utility functions to be used around the config

local M = {}

local get_selection = function()
  local selection_position = vim.fn.getpos("v")
  local cursor_position = vim.fn.getcurpos()
  local start_row = selection_position[2]
  local start_col = selection_position[3]
  local end_row = cursor_position[2]
  local end_col = cursor_position[3]

  -- start should be less then end
  if start_row > end_row or (start_row == end_row and start_col > end_col) then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end

  return start_row, start_col, end_row, end_col
end

M.evaluate_js = function()
  local current_buffer = 0
  local start_row, start_col, end_row, end_col = get_selection()

  -- array of lines
  local text = {}

  if start_col == end_col then
    text =
      vim.api.nvim_buf_get_lines(current_buffer, start_row - 1, end_row, true)
  else
    text = vim.api.nvim_buf_get_text(
      current_buffer,
      start_row - 1,
      start_col - 1,
      end_row - 1,
      end_col,
      {}
    )
  end

  local replacement = ""

  local Job = require("plenary.job")
  Job:new({
    command = "deno",
    args = { "eval", "-p", "--", table.concat(text, ";") },
    on_stdout = function(_, return_val)
      -- remove escape sequence
      replacement = return_val:gsub("[^%g]", ""):gsub("%[%d%d?%a", "")
    end,
    on_stderr = function(_, return_val)
      print(return_val:gsub("[^%g]", ""):gsub("%[%d%d?%a", ""))
    end,
  }):sync()

  vim.api.nvim_buf_set_text(
    current_buffer,
    start_row - 1,
    start_col - 1,
    end_row - 1,
    end_col,
    { replacement }
  )
end

-- Look for files that match (exactly) one of the given file names
-- It looks for matches in current directory and every parent up to HOME dir
M.has_root_file = function(file_names)
  local home = vim.env.HOME
  local path = vim.fn.expand("%:p:h")
  while true do
    local handle = vim.loop.fs_scandir(path)
    local entry = nil
    local scan = function(h)
      entry = vim.loop.fs_scandir_next(h)
    end

    -- For files that are outside of local file system (the fs function failed)
    -- only check the "cwd" directory
    if not pcall(scan, handle) then
      for _, name in ipairs(file_names) do
        if M.file_exists(M.path_join(vim.fn.getcwd(), name)) then
          return true
        end
      end
      return false
    end

    while entry do
      for _, name in ipairs(file_names) do
        if entry == name then
          return true
        end
      end
      entry = vim.loop.fs_scandir_next(handle)
    end
    if home == path then
      break
    end
    local _, lastSlashIndex = string.find(path, ".*/")
    path = string.sub(path, 1, lastSlashIndex - 1)
  end
  return false
end

M.file_exists = function(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

M.read_file = function(path)
  local file = io.open(path, "rb")
  if not file then
    return nil
  end
  local content = file:read("*a")
  file:close()
  return content
end

M.path_join = function(...)
  local path_separator = "/"
  local result = table
    .concat(vim.tbl_flatten({ ... }), path_separator)
    :gsub(path_separator .. "+", path_separator)
  return result
end

M.string_startswith = function(input, start)
  return input:sub(1, #start) == start
end

M.string_contains = function(input, sub)
  return input:find(sub, 1, true) ~= nil
end

M.current_sequence_starts_with = function(start)
  local word = vim.fn.expand("<cWORD>")
  return M.string_startswith(word, start)
end

M.current_sequence_contains = function(start)
  local word = vim.fn.expand("<cWORD>")
  return M.string_contains(word, start)
end

return M
