local scan = require "plenary.scandir"
local utils = require "my.utils"
local path_join = utils.path_join

local source = {}

local opts = {
}

source.new = function()
	local self = setmetatable({}, { __index = source })
	return self
end

function source:is_available()
	local ext = vim.fn.expand('%:e')
	return ext == "vue"
end

function source:get_debug_name()
	return "nuxt-component"
end

function source:complete(params, callback)
	local cwd = vim.fn.getcwd()
	local components_folder = path_join(cwd, "components")
	local cmp_data = {}
	if vim.fn.isdirectory(components_folder) then
		local scan_opts = { depth = 2, search_pattern = ".*%.vue" }
		local result = scan.scan_dir(components_folder, scan_opts)
		for index, value in ipairs(result) do
			local start = false
			local component_name = ""
			for token in string.gmatch(value, "[^/]+") do
				if start then
					component_name = component_name .. token
				end
				if token == "components" then
					start = true
				end
			end
			table.insert(cmp_data, { label = component_name:gsub(".vue", "") })
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

require('cmp').register_source("nuxt_component", source.new())

return {
	setup = function(_opts)
		if _opts then
			opts = vim.tbl_deep_extend('force', opts, _opts) -- will extend the default options
		end
	end
}
