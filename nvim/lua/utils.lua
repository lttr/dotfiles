-- utility functions to be used around the config

-- TODO modularize

function GetSelection()
  local selection_position = vim.fn.getpos("v")
  local cursor_position = vim.fn.getcurpos()
  local start_row = selection_position[2]
  local start_col = selection_position[3]
  local end_row = cursor_position[2]
  local end_col = cursor_position[3]

  -- start should be less then end
  if (start_row > end_row or (start_row == end_row and start_col > end_col)) then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end

  return start_row, start_col, end_row, end_col
end

function EvaluateJs()
  local current_buffer = 0
  local start_row, start_col, end_row, end_col = GetSelection()

  -- array of lines
  local text = {}

  if (start_col == end_col) then
    text = vim.api.nvim_buf_get_lines(current_buffer, start_row - 1, end_row, true)
  else
    text = vim.api.nvim_buf_get_text(current_buffer, start_row - 1, start_col - 1, end_row - 1, end_col, {})
  end

  local replacement = ""

  local Job = require "plenary.job"
  Job:new(
    {
      command = "deno",
      args = {"eval", "-p", "--", table.concat(text, ";")},
      on_stdout = function(_, return_val)
        -- remove escape sequence
        replacement = return_val:gsub("[^%g]", ""):gsub("%[%d%d?%a", "")
      end,
      on_stderr = function(_, return_val)
        print(return_val:gsub("[^%g]", ""):gsub("%[%d%d?%a", ""))
      end
    }
  ):sync()

  vim.api.nvim_buf_set_text(current_buffer, start_row - 1, start_col - 1, end_row - 1, end_col, {replacement})
end
