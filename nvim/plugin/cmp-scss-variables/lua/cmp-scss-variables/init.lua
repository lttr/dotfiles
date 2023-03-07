local utils = require("my.utils")
local path_join = utils.path_join
local file_exists = utils.file_exists
local current_sequence_starts_with = utils.current_sequence_starts_with
local read_file = utils.read_file

local source = {}

local opts = {
  files = {},
}

source.new = function()
  local self = setmetatable({}, { __index = source })
  return self
end

function source:is_available()
  local ext = vim.fn.expand("%:e")
  return ext == "scss" or ext == "vue"
end

function source:get_debug_name()
  return "scss_variables"
end

function source:complete(params, callback)
  if current_sequence_starts_with("$") then
    callback()
    return
  end
  local cwd = vim.fn.getcwd()
  local css_files = {}
  for i, css_file in ipairs(opts.files) do
    table.insert(css_files, path_join(cwd, css_file))
  end
  local cmp_data = {}
  for i, css_file_path in ipairs(css_files) do
    if file_exists(css_file_path) then
      local content = read_file(css_file_path) or ""
      local regexp = "(%$[^:]+):% ([^;]+);"
      for property, value in string.gmatch(content, regexp) do
        local cmp_item = {
          label = property,
          documentation = value,
        }
        table.insert(cmp_data, cmp_item)
      end
    end
  end
  callback(cmp_data)
end

function source:resolve(completion_item, callback)
  callback(completion_item)
end

function source:execute(completion_item, callback)
  callback(completion_item)
end

require("cmp").register_source("scss_variables", source.new())

return {
  setup = function(_opts)
    if _opts then
      opts = vim.tbl_deep_extend("force", opts, _opts) -- will extend the default options
    end
  end,
}
