-- https://github.com/williamboman/mason-lspconfig.nvim
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

-- https://github.com/folke/neodev.nvim
-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup()

local utils = require("my.utils")

local function is_a_deno_project()
  return utils.has_root_file({ "deno.json", "deno.jsonc" })
end

local function is_a_nuxt_project()
  return utils.has_root_file({ "nuxt.config.js", "nuxt.config.ts", ".nuxtrc" })
end

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
  "somesass_ls",
  "stylelint_lsp",
  "svelte",
  "tailwindcss",
  "terraformls",
  -- "ts_ls", -- managed by typescript-tools
  "vtsls",
  "vue_ls",
  "yamlls",
}

require("mason").setup()
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
  ensure_installed = servers,
  automatic_enable = {
    exclude = {
      "denols",
    },
  },
})
local lsp_config = require("lspconfig")

-- Doesn't work with neovim 0.11
local border_options = {
  border = "rounded",
  winhighlight = "Normal:Normal,FloatBorder:LineNr,CursorLine:Visual,Search:None",
  side_padding = 1,
}

-- This works with neovim 0.11 to use rounded borders
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "single"
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

local common_handlers = {}

local common_on_attach = function(client)
  -- do not allow any lsp servers to do formatting
  if client.server_capabilities.documentFormattingProvider then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end
end

-- Maybe upgrade logic for use in mixed repositories
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
  -- It is done in the conform.lua file
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

-- local capabilities_cmp = require("cmp_nvim_lsp").default_capabilities()

if not is_a_deno_project() then
  -- require("typescript-tools").setup({
  --   filetypes = {
  --     "javascript",
  --     "javascriptreact",
  --     "typescript",
  --     "typescriptreact",
  --   },
  --   handlers = common_handlers,
  --   settings = {
  --     -- spawn additional tsserver instance to calculate diagnostics on it
  --     separate_diagnostic_server = true,
  --     expose_as_code_action = "all",
  --     capabilities = capabilities_cmp,
  --     -- https://github.com/pmizio/typescript-tools.nvim/issues/132
  --     -- https://github.com/pmizio/typescript-tools.nvim/issues/249
  --     root_dir = root_pattern_exclude({
  --       root = { "package.json" },
  --       exclude = { "deno.json", "deno.jsonc" },
  --     }),
  --     single_file_support = false,
  --     tsserver_plugins = {
  --       "@vue/typescript-plugin",
  --     },
  --     tsserver_file_preferences = {
  --       includeInlayParameterNameHints = "all",
  --       includeCompletionsForModuleExports = true,
  --       quotePreference = "auto",
  --     },
  --     tsserver_format_options = {
  --       allowIncompleteCompletions = false,
  --       allowRenameOfImportPath = false,
  --     },
  --   },
  -- })
end

-- https://github.com/vuejs/language-tools?tab=readme-ov-file#none-hybrid-modesimilar-to-takeover-mode-configuration-requires-vuelanguage-server-version-207
-- local vtsls = {
--   filetypes = {
--     "vue",
--     "javascript",
--     "javascriptreact",
--     "typescript",
--     "typescriptreact",
--   },
--   init_options = {
--     -- vue = {
--     --   hybridMode = false,
--     -- },
--     typescript = {
--       tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib",
--     },
--   },
-- }

local jsonls = {
  settings = {
    json = {
      -- https://github.com/b0o/SchemaStore.nvim
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
}

-- Vue handling
--
-- based on https://github.com/vuejs/language-tools/wiki/Neovim

local vue_language_server_path = vim.fn.stdpath("data")
  .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
local vue_plugin = {
  name = "@vue/typescript-plugin",
  location = vue_language_server_path,
  languages = { "vue" },
  configNamespace = "typescript",
}

local vue_ls = {
  -- TODO temporary fix for https://github.com/mason-org/mason-lspconfig.nvim/issues/587
  init_options = {
    typescript = {
      tsdk = "",
    },
  },
  on_init = function(client)
    client.handlers["tsserver/request"] = function(_, result, context)
      local clients =
        vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })
      if #clients == 0 then
        vim.notify(
          "Could not find `vtsls` lsp client, `vue_ls` would not work without it.",
          vim.log.levels.ERROR
        )
        return
      end
      local ts_client = clients[1]

      local param = unpack(result)
      local id, command, payload = unpack(param)
      ts_client:exec_cmd({
        title = "vue_request_forward", -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
        command = "typescript.tsserverRequest",
        arguments = {
          command,
          payload,
        },
      }, { bufnr = context.bufnr }, function(_, r)
        local response_data = { { id, r.body } }
        ---@diagnostic disable-next-line: param-type-mismatch
        client:notify("tsserver/response", response_data)
      end)
    end
  end,
}

local shared_settings = {
  suggest = { completeFunctionCalls = true },
  inlayHints = {
    functionLikeReturnTypes = { enabled = true },
    parameterNames = { enabled = "all" },
    parameterTypes = { enabled = true },
    propertyDeclarationTypes = { enabled = true },
    variableTypes = { enabled = true },
  },
}

local vtsls = {
  settings = {
    typescript = shared_settings,
    javascript = shared_settings,
    vue = shared_settings,
    vtsls = {
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
        },
        enableMoveToFileCodeAction = true,
        autoUseWorkspaceTsdk = true,
        experimental = {
          maxInlayHintLength = 30,
        },
      },
      tsserver = {
        globalPlugins = {
          vue_plugin,
        },
      },
    },
  },
  filetypes = {
    "typescript",
    "javascript",
    "javascriptreact",
    "typescriptreact",
    "vue",
  },
}

local custom_configs = {
  denols = denols,
  eslint = eslint,
  jsonls = jsonls,
  lua_ls = lua_ls,
  vtsls = vtsls,
  vue_ls = vue_ls,
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

local function setup_server(server)
  local config = make_config(server)

  if server == "denols" and not is_a_deno_project() then
    return
  end

  -- managed by typescript-tools, skip the initialization
  -- if server == "ts_ls" then
  --   return
  -- end

  -- lsp_config[server].setup(config)
  vim.lsp.config(server, config)
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

-- vim.api.nvim_create_autocmd("LspAttach", {
--   group = vim.api.nvim_create_augroup("UserLspConfig", {}),
--   callback = function(args)
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     if client.server_capabilities.inlayHintProvider then
--       vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
--     end
--   end,
-- })
