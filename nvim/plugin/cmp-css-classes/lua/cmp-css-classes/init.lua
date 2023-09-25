local utils = require("my.utils")
local path_join = utils.path_join
local file_exists = utils.file_exists
local current_sequence_contains = utils.current_sequence_contains
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
  return ext == "html" or ext == "vue"
end

function source:get_debug_name()
  return "css_classes"
end

function source:complete(params, callback)
  -- if not current_sequence_contains("") then
  --   callback()
  --   return
  -- end
  local cwd = vim.fn.getcwd()
  local css_files = {}
  for i, css_file in ipairs(opts.files) do
    table.insert(css_files, path_join(cwd, css_file))
  end
  local cmp_data = {}
  for i, css_file_path in ipairs(css_files) do
    if file_exists(css_file_path) then
      local content = read_file(css_file_path) or ""
      local regexp = "([^0-9: ]%.)([^,(){} ]+)"
      local set_of_class_names = {}
      for _prefix, class_name in string.gmatch(content, regexp) do
        if not set_of_class_names[class_name] then
          local cmp_item = {
            label = class_name,
          }
          table.insert(cmp_data, cmp_item)
          set_of_class_names[class_name] = true
        end
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

require("cmp").register_source("css_variables", source.new())

return {
  setup = function(_opts)
    if _opts then
      opts = vim.tbl_deep_extend("force", opts, _opts) -- will extend the default options
    end
  end,
}
