local scan = require("plenary.scandir")

local utils = require("my.utils")
local file_exists = utils.file_exists
local path_join = utils.path_join
local has_root_file = utils.has_root_file
local find_root_directory = utils.find_root_directory
local read_file = utils.read_file

local function matchstr(...)
  local ok, ret = pcall(vim.fn.matchstr, ...)
  return ok and ret or ""
end

-- I am not sure what is differnt about this
-- from vim.fn.expand('<cword>')
local function get_cursorword()
  local column = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local left = matchstr(line:sub(1, column + 1), [[\k*$]])
  local right = matchstr(line:sub(column + 1), [[^\k*]]):sub(2)
  local cursorword = left .. right
  return cursorword
end

local function find_component(path, name_parts, count)
  local component_name = table.concat(name_parts, "")
  local component_variants = {
    component_name .. ".vue",
    component_name .. ".client.vue",
    component_name .. ".server.vue",
    component_name .. "/" .. component_name .. ".vue",
  }
  for i, component_name_variant in ipairs(component_variants) do
    local component_file_path = path_join(path, component_name_variant)
    if file_exists(component_file_path) then
      return component_file_path
    end
  end
  local next_path = path_join(path, name_parts[1])
  if next_path and vim.fn.isdirectory(next_path) then
    table.remove(name_parts, 1)
    if count <= 1 then
      -- Component was not found and the table with name parts is empty
      return false
    end
    return find_component(next_path, name_parts, count - 1)
  end
  return nil
end

local function find_component_simple(path, component_name)
  local paths =
    vim.split(vim.fn.glob(path .. "/**/" .. component_name .. ".vue"), "\\n")
  if paths[1] == "" then
    return nil
  end
  return paths[1]
end

local function handle_component(word, vsplit)
  local edit_command = "edit"
  if vsplit then
    edit_command = "vsplit"
  end
  local component_name_parts = {}
  local parts_count = 0
  for part in string.gmatch(word, "[A-Z][a-z0-9]*") do
    parts_count = parts_count + 1
    table.insert(component_name_parts, part)
  end

  local components_folder = find_root_directory("components")
  if components_folder and vim.fn.isdirectory(components_folder) then
    local component_file_path = nil
    component_file_path = find_component_simple(components_folder, word)
    if not component_file_path then
      component_file_path =
        find_component(components_folder, component_name_parts, parts_count)
    end
    if component_file_path then
      vim.cmd(edit_command .. " " .. component_file_path)
      return true
    end
  else
    local directory = ""
    if components_folder then
      directory = components_folder
    end
    print("There is no expected directory " .. directory)
  end

  local dot_nuxt_folder = find_root_directory(".nuxt", vim.fn.getcwd())
  if dot_nuxt_folder and vim.fn.isdirectory(dot_nuxt_folder) then
    local components_file_path = path_join(dot_nuxt_folder, "components.d.ts")
    local components_file_contents = read_file(components_file_path)
    if components_file_contents then
      -- The line looks like this:
      -- 'ComponentName': typeof import("../components/ComponentName.vue")['default']
      local match_string = "'" .. word .. "'" .. ': typeof import%("(.-)"%)'
      local path_match = string.match(components_file_contents, match_string)
      if not path_match then
        return false
      end
      local component_file_path = string.gsub(path_match, "dist", "src")
      local resolved_path =
        vim.fn.resolve(dot_nuxt_folder .. "../" .. component_file_path)
      vim.cmd(edit_command .. " " .. resolved_path)
      return true
    end
  end

  return false
end

local function handle_composable(word)
  local cwd = vim.fn.getcwd()
  local composables_folder_name = "composables"
  if string.match(word, "Store") then
    composables_folder_name = "stores"
  end
  local composables_folder = find_root_directory(composables_folder_name)
  if composables_folder and vim.fn.isdirectory(composables_folder) then
    local file_name = word .. ".ts"
    if string.match(word, "Store") then
      file_name = word:sub(4) .. ".ts" -- omit the leading "use" prefix
    end

    local scan_opts = { depth = 10, search_pattern = ".*%.ts" }
    local result = scan.scan_dir(composables_folder, scan_opts)
    local composable_file_path = nil
    for index, value in ipairs(result) do
      if string.match(value, file_name .. "$") then
        composable_file_path = value
      end
    end

    if composable_file_path then
      vim.cmd("edit " .. composable_file_path)
      return true
    end
  else
    print("There is no expected directory " .. composables_folder)
  end
  return false
end

local function go(vsplit)
  if not (vim.fn.expand("%:e") == "vue") then
    return false
  end
  if not has_root_file({ "nuxt.config.ts", "nuxt.config.js", ".nuxtrc" }) then
    return false
  end
  local word = get_cursorword()
  if string.len(word) < 2 then
    return false
  end
  if word:sub(1, 3) == "use" then
    return handle_composable(word)
  else
    return handle_component(word, vsplit)
  end
end

return {
  go = go,
}
