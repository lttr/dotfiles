-- https://github.com/williamboman/mason-lspconfig.nvim
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

-- https://github.com/folke/neodev.nvim
-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup()

local utils = require("my.utils")

local servers = {
  "bashls",
  "cssls",
  "denols",
  "eslint",
  "graphql",
  "html",
  "jsonls",
  "lua_ls",
  "marksman",
  "phpactor",
  "pyright",
  "stylelint_lsp",
  "tailwindcss",
  "terraformls",
  "volar",
  "yamlls",
}

require("mason").setup()
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
  ensure_installed = { unpack(servers) },
})
local lsp_config = require("lspconfig")

local border_options = {
  border = "rounded",
  winhighlight = "Normal:Normal,FloatBorder:LineNr,CursorLine:Visual,Search:None",
  side_padding = 1,
}

local common_handlers = {
  ["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
      -- let plugin lsp_lines handle virtual diagnostic text
      virtual_text = false,
    }
  ),
  ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, border_options),
  ["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    border_options
  ),
  ["textDocument/codeAction"] = vim.lsp.with(
    vim.lsp.handlers.code_action,
    border_options
  ),
}

local common_on_attach = function(client)
  -- vim.api.nvim_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  -- stop jsonls and cssls and volar from formatting (I use prettier for that)
  if client.server_capabilities.documentFormattingProvider then
    if
      client.name == "jsonls"
      or client.name == "cssls"
      or client.name == "volar"
    then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end
  end
  -- Set autocommands conditional on server_capabilities
  -- if client.server_capabilities.document_highlight then
  --   vim.cmd(
  --     [[
  --     augroup lsp_document_highlight
  --     autocmd! * <buffer>
  --     autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
  --     autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
  --     augroup END
  --   ]],
  --     false
  --   )
  -- end
end

-- https://github.com/davidosomething/format-ts-errors.nvim
-- local pretty_ts_error_handlers = {
--   ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
--     if result.diagnostics == nil then
--       return
--     end
--
--     -- ignore some ts_ls diagnostics
--     local idx = 1
--     while idx <= #result.diagnostics do
--       local entry = result.diagnostics[idx]
--
--       local formatter = require("format-ts-errors")[entry.code]
--       entry.message = formatter and formatter(entry.message) or entry.message
--
--       -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
--       if entry.code == 80001 then
--         -- { message = "File is a CommonJS module; it may be converted to an ES module.", }
--         table.remove(result.diagnostics, idx)
--       else
--         idx = idx + 1
--       end
--     end
--
--     vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
--   end,
-- }

-- TODO upgrade logic for use in mixed repositories
-- https://www.npbee.me/posts/deno-and-typescript-in-a-monorepo-neovim-lsp
local denols = {
  root_dir = lsp_config.util.root_pattern({
    "deno.json",
    "deno.jsonc",
    "deps.ts",
  }),
  init_options = {
    enable = true,
    lint = true,
    unstable = true,
  },
}

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#eslint

local eslint = {
  -- It is better to run eslint --fix and then prettier in order to have the
  -- code formatted even after the eslint transformation which is not always
  -- precise.
  -- on_attach = function(client, bufnr)
  --   vim.api.nvim_create_autocmd("BufWritePre", {
  --     buffer = bufnr,
  --     command = "EslintFixAll",
  --   })
  -- end,
  -- When using ESLint, there might be rules that we want to automatically fix,
  -- but not immediately when saving.
  -- codeActionOnSave = {
  --   enable = true,
  --   mode = "all",
  -- },
  -- If we have disabled the automatic fixes for some rules, but the editor
  -- still displays them as errors.
  -- rulesCustomizations = {},
  experimental = {
    useFlatConfig = true,
  },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
    "svelte",
    "astro",
    "graphql",
  },
}

local lua_ls = {
  Lua = {
    checkThirdParty = false,
    hint = { enable = true },
  },
}

---Specialized root pattern that allows for an exclusion
---@param opt { root: string[], exclude: string[] }
---@return fun(file_name: string): string | nil
local function root_pattern_exclude(opt)
  local lsputil = require("lspconfig.util")

  return function(fname)
    local excluded_root = lsputil.root_pattern(opt.exclude)(fname)
    local included_root = lsputil.root_pattern(opt.root)(fname)

    if excluded_root then
      return nil
    else
      return included_root
    end
  end
end

local capabilities_cmp = require("cmp_nvim_lsp").default_capabilities()

require("typescript-tools").setup({
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  settings = {
    -- spawn additional tsserver instance to calculate diagnostics on it
    separate_diagnostic_server = true,
    expose_as_code_action = { "all" },
    capabilities = capabilities_cmp,
    root_dir = root_pattern_exclude({
      root = { "package.json" },
      exclude = { "deno.json", "deno.jsonc" },
    }),
    single_file_support = false,
    tsserver_plugins = {
      "@vue/typescript-plugin",
    },
  },
})

-- https://github.com/vuejs/language-tools?tab=readme-ov-file#none-hybrid-modesimilar-to-takeover-mode-configuration-requires-vuelanguage-server-version-207
local volar = {
  -- handlers = pretty_ts_error_handlers,
  filetypes = {
    -- "typescript",
    -- "javascript",
    -- "javascriptreact",
    -- "typescriptreact",
    "vue",
  },
  init_options = {
    vue = {
      hybridMode = false,
    },
  },
}

local jsonls = {
  settings = {
    json = {
      -- https://github.com/b0o/SchemaStore.nvim
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
}

local custom_configs = {
  denols = denols,
  eslint = eslint,
  lua_ls = lua_ls,
  volar = volar,
  jsonls = jsonls,
}

local function make_config(server_name)
  -- enable snippet support
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  local custom_config = {}

  if custom_configs[server_name] ~= nil then
    custom_config = custom_configs[server_name]
  end

  local merged_config = vim.tbl_deep_extend("force", {
    capabilities = capabilities,
    -- map buffer local keybindings when the language server attaches
    on_attach = common_on_attach,
    handlers = common_handlers,
  }, custom_config)
  return merged_config
end

local function is_a_deno_project()
  return utils.has_root_file({ "deno.json", "deno.jsonc" })
end

local function is_a_vite_project()
  return utils.has_root_file({ "vite.config.js", "vite.config.ts" })
end

local function is_a_nuxt_project()
  return utils.has_root_file({ "nuxt.config.js", "nuxt.config.ts", ".nuxtrc" })
end

local function setup_server(server)
  -- if server == "ts_ls" and (is_a_deno_project()) then
  --   return
  -- end

  if
    server == "denols"
    and utils.file_exists(vim.fn.getcwd() .. "/package.json")
    and not utils.file_exists(vim.fn.getcwd() .. "/deno.json")
  then
    return
  end

  -- if server == "volar" and is_a_deno_project() then
  --   return
  -- end

  local config = make_config(server)
  lsp_config[server].setup(config)
end

for _, name in pairs(servers) do
  setup_server(name)
end

-- https://github.com/ray-x/lsp_signature.nvim
require("lsp_signature").setup({
  hint_enable = true,
  hint_scheme = "Hint",
  hint_prefix = "» ",
  floating_window = false,
})
