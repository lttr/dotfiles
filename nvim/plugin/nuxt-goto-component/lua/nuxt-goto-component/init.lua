local utils = require "my.utils"
local file_exists = utils.file_exists
local path_join = utils.path_join
local has_root_file = utils.has_root_file

local function matchstr(...)
	local ok, ret = pcall(vim.fn.matchstr, ...)
	return ok and ret or ""
end

local function get_cursorword()
	local column = vim.api.nvim_win_get_cursor(0)[2]
	local line = vim.api.nvim_get_current_line()
	local left = matchstr(line:sub(1, column + 1), [[\k*$]])
	local right = matchstr(line:sub(column + 1), [[^\k*]]):sub(2)
	local cursorword = left .. right
	return cursorword
end

local function find_component(path, name_parts, count)
	local component_file_name = table.concat(name_parts, "") .. ".vue"
	local component_file_path = path_join(path, component_file_name)
	if file_exists(component_file_path) then
		return component_file_path
	else
		local next_path = path_join(path, name_parts[1])
		if vim.fn.isdirectory(next_path) then
			table.remove(name_parts, 1)
			if count <= 1 then
				-- Component was not found and the table with name parts is empty
				return false
			end
			return find_component(next_path, name_parts, count - 1)
		end
	end
	return nil
end

local function go()
	if not has_root_file({ "nuxt.config.ts", "nuxt.config.js" }) then
		return false
	end
	local word = get_cursorword()
	if string.len(word) < 2 then
		return false
	end
	local component_name_parts = {}
	local parts_count = 0
	for part in string.gmatch(word, "[A-Z][a-z0-9]*") do
		parts_count = parts_count + 1
		table.insert(component_name_parts, part)
	end
	local cwd = vim.fn.getcwd()
	local components_folder = path_join(cwd, "components")
	if vim.fn.isdirectory(components_folder) then
		local component_file_path = find_component(components_folder, component_name_parts, parts_count)
		if component_file_path then
			vim.cmd("edit " .. component_file_path)
			return true
		end
	else
		print("There is no expected directory " .. components_folder)
	end
	return false
end

return {
	go = go
}
