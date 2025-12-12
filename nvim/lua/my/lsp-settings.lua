-- https://github.com/williamboman/mason-lspconfig.nvim
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md

local utils = require("my.utils")

local function is_a_deno_project()
  return utils.has_root_file({ "deno.json", "deno.jsonc" })
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
  "phpactor",
  "pyright",
  "somesass_ls",
  "stylelint_lsp",
  "svelte",
  "tailwindcss",
  "terraformls",
  "vtsls",
  -- NOTE: vue_ls removed - vtsls handles Vue files via @vue/typescript-plugin
  -- The vue_ls server (vue-language-server) provides additional features like
  -- template intellisense, but requires explicit cmd config since nvim-lspconfig
  -- doesn't have a built-in config for it yet. For most use cases, vtsls + the
  -- vue plugin is sufficient.
  "yamlls",
}

require("mason").setup()
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
  ensure_installed = servers,
  -- automatic_enable is disabled because:
  -- 1. It only provides configs for ~20 servers in mason-lspconfig/lsp/
  -- 2. For other servers (vtsls, eslint, tailwindcss, etc.), it just calls vim.lsp.enable() without config
  -- 3. Without proper config (cmd, root_dir, etc.), servers fail to start
  -- 4. Manual setup below ensures all servers get complete configurations from nvim-lspconfig
  automatic_enable = false,
})
local lsp_config = require("lspconfig")

-- This works with neovim 0.11 to use rounded borders
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "single"
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

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

local jsonls = {
  settings = {
    json = {
      -- https://github.com/b0o/SchemaStore.nvim
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
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
  preferences = {
    includeInlayParameterNameHints = "all",
    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
    includeInlayFunctionParameterTypeHints = true,
    includeInlayVariableTypeHints = true,
    includeInlayPropertyDeclarationTypeHints = true,
    includeInlayFunctionLikeReturnTypeHints = true,
    includeInlayEnumMemberValueHints = true,
  },
}

-- Vue + TypeScript handling
--
-- References:
-- - https://github.com/vuejs/language-tools/wiki/Neovim
-- - https://github.com/KazariEX/dxup (enhanced Nuxt/Vue DX)
--
-- For Nuxt 4.2+ projects, enable dxup features in nuxt.config.ts:
--   experimental: { typescriptPlugin: true }
-- Then run `nuxt prepare` and restart LSP.
--
-- dxup provides:
-- - Go to definition for auto-imported components, composables, nitro routes
-- - Automatic rename updates for auto-imported components
-- - Better navigation for runtime config, typed pages, etc.

-- Path to vue-language-server installed by Mason
-- This is needed for the @vue/typescript-plugin which provides Vue SFC support in TS files
local vue_language_server_path = vim.fn.stdpath("data")
  .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

-- The Vue TypeScript plugin enables TypeScript features in .vue files
-- It gets loaded by vtsls/tsserver to provide intellisense for Vue SFCs
local vue_plugin = {
  name = "@vue/typescript-plugin",
  location = vue_language_server_path,
  languages = { "vue" },
  configNamespace = "typescript",
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
        -- IMPORTANT: autoUseWorkspaceTsdk is critical for dxup/Nuxt to work correctly
        -- It ensures vtsls uses the project's node_modules/typescript instead of a bundled version.
        -- This is required because:
        -- 1. dxup hooks into TypeScript as a plugin (configured in tsconfig.json or nuxt.config.ts)
        -- 2. The plugin only loads if vtsls uses the same TS instance where dxup is registered
        -- 3. Without this, "go to definition" jumps to generated .nuxt types instead of source files
        autoUseWorkspaceTsdk = true,
        maxInlayHintLength = 30,
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
  -- NOTE on tsdk (TypeScript SDK path):
  -- - autoUseWorkspaceTsdk=true (above) makes vtsls prefer workspace TS when available
  -- - If workspace has no TS, vtsls falls back to its bundled version
  -- - We don't set explicit tsdk here because:
  --   1. vim.fn.getcwd() at config load time points to wrong directory
  --   2. Explicit tsdk can override autoUseWorkspaceTsdk incorrectly
  -- - If you get "prepareRename failed" errors, ensure the project has typescript installed:
  --   pnpm add -D typescript
}

local tailwindcss = {
  filetypes = {
    "html",
    "css",
    "scss",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
    "svelte",
  },
  settings = {
    tailwindCSS = {
      includeLanguages = {
        vue = "vue",
        html = "html",
      },
    },
  },
}

-- stylelint_lsp: Only start if project has a stylelint config file
-- Without this, stylelint-lsp errors on every file: "No configuration provided"
-- The `conditional = true` flag tells setup_server to skip this server if root_dir returns nil
local stylelint_lsp = {
  conditional = true,
  root_dir = lsp_config.util.root_pattern(
    ".stylelintrc",
    ".stylelintrc.js",
    ".stylelintrc.json",
    ".stylelintrc.yaml",
    ".stylelintrc.yml",
    "stylelint.config.js",
    "stylelint.config.cjs",
    "stylelint.config.mjs"
  ),
}

local custom_configs = {
  denols = denols,
  eslint = eslint,
  jsonls = jsonls,
  stylelint_lsp = stylelint_lsp,
  lua_ls = lua_ls,
  vtsls = vtsls,
  tailwindcss = tailwindcss,
}

local function make_config(server_name)
  -- enable snippet support
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  local custom_config = {}

  if custom_configs[server_name] ~= nil then
    custom_config = custom_configs[server_name]
  end

  -- Get default config from lspconfig which includes cmd
  local default_config = {}
  local ok, lspconfig_def = pcall(require, "lspconfig.configs." .. server_name)
  if ok and lspconfig_def.default_config then
    default_config = lspconfig_def.default_config
  end

  local merged_config = vim.tbl_deep_extend("force", {
    capabilities = capabilities,
    -- map buffer local keybindings when the language server attaches
    on_attach = common_on_attach,
    autostart = true,
  }, default_config, custom_config)

  -- WORKAROUND: Neovim 0.11 LSP API breaking change compatibility wrapper
  --
  -- In neovim 0.11, vim.lsp.enable() now passes buffer numbers to root_dir functions,
  -- but nvim-lspconfig's root_dir functions expect file paths (strings).
  -- This causes errors like "vim/fs.lua:0: path: expected string, got number"
  --
  -- This wrapper converts buffer numbers to file paths before calling the original root_dir.
  --
  -- Can be removed when:
  -- - nvim-lspconfig updates their root_dir functions to handle buffer numbers, OR
  -- - You stop using vim.lsp.enable() and switch to a different LSP setup method
  if merged_config.root_dir and type(merged_config.root_dir) == "function" then
    local original_root_dir = merged_config.root_dir
    merged_config.root_dir = function(path_or_bufnr)
      -- Convert buffer number to file path
      if type(path_or_bufnr) == "number" then
        path_or_bufnr = vim.api.nvim_buf_get_name(path_or_bufnr)
      end
      return original_root_dir(path_or_bufnr)
    end
  end

  return merged_config
end

local function setup_server(server)
  local config = make_config(server)

  if server == "denols" and not is_a_deno_project() then
    return
  end

  -- Configure the server with complete config (including cmd, root_dir, etc.)
  vim.lsp.config(server, config)
  -- Enable the server (this is our manual enable, replacing mason's incomplete automatic_enable)
  vim.lsp.enable(server)

  -- Set up autocommand to start server on appropriate filetypes
  if config.filetypes then
    vim.api.nvim_create_autocmd("FileType", {
      pattern = config.filetypes,
      callback = function(args)
        local bufname = vim.api.nvim_buf_get_name(args.buf)
        local root_dir = vim.fn.getcwd()

        -- Only calculate root_dir if we have a valid buffer name
        if
          bufname ~= ""
          and config.root_dir
          and type(config.root_dir) == "function"
        then
          local calculated_root = config.root_dir(bufname)
          if calculated_root then
            root_dir = calculated_root
          elseif config.conditional then
            -- For conditional servers (like stylelint_lsp), don't start if
            -- root_dir returns nil (meaning required config file not found)
            return
          end
        end

        vim.lsp.start({
          name = server,
          cmd = config.cmd,
          root_dir = root_dir,
          capabilities = config.capabilities,
          on_attach = config.on_attach,
          settings = config.settings,
        }, { bufnr = args.buf })
      end,
      group = vim.api.nvim_create_augroup(
        "lsp_autostart_" .. server,
        { clear = true }
      ),
    })
  end
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
