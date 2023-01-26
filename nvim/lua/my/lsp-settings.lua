-- https://github.com/williamboman/mason-lspconfig.nvim
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

-- https://github.com/jose-elias-alvarez/nvim-lsp-ts-utils

local utils = require "my.utils"

local servers = {
  "angularls",
  "bashls",
  "cssls",
  "denols",
  -- "eslint",
  "gopls",
  "graphql",
  "html",
  "jsonls",
  "phpactor",
  "prismals",
  "sumneko_lua",
  "svelte",
  "tailwindcss",
  "terraformls",
  "vuels",
  "volar",
  "yamlls"
  -- tsserver is managed by nvim-lsp-ts-utils
}

require("mason").setup()
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup(
  {
    ensure_installed = { "tsserver", unpack(servers) }
  }
)
local lsp_config = require("lspconfig")

local border_options = {
  border = "rounded",
  winhighlight = "Normal:Normal,FloatBorder:LineNr,CursorLine:Visual,Search:None",
  side_padding = 1
}

local common_handlers = {
  ["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
      -- let plugin lsp_lines handle virtual diagnostic text
      virtual_text = false
    }
  ),
  ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, border_options),
  ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, border_options),
  ["textDocument/codeAction"] = vim.lsp.with(vim.lsp.handlers.code_action, border_options)
}

local common_on_attach = function(client)
  vim.api.nvim_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  require "my.keybindings".lsp_keybindings(client)
  -- client.server_capabilities.document_formatting = false

  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.document_highlight then
    vim.cmd(
      [[
      augroup lsp_document_highlight
      autocmd! * <buffer>
      autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
      autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]] ,
      false
    )
  end
end

local denols = {
  root_dir = lsp_config.util.root_pattern({ "deno.json", "deno.jsonc", "deps.ts" }),
  init_options = {
    enable = true,
    lint = true,
    unstable = true
  }
}

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#eslint
-- local eslint = {
--   {
--     codeAction = {
--       disableRuleComment = {
--         enable = true,
--         location = "separateLine"
--       },
--       showDocumentation = {
--         enable = true
--       }
--     },
--     codeActionOnSave = {
--       enable = false,
--       mode = "all"
--     },
--     format = true,
--     nodePath = "",
--     onIgnoredFiles = "off",
--     packageManager = "npm",
--     quiet = false,
--     rulesCustomizations = {},
--     run = "onType",
--     useESLintClass = false,
--     validate = "on",
--     workingDirectory = {
--       mode = "location"
--     }
--   }
-- }

local sumneko_lua = {
  settings = {
    Lua = {
      dignostics = {
        globals = { "vim" }
      }
    }
  }
}

local vuels = {
  init_options = {
    vetur = {
      completion = {
        tagCasing = "initial",
        autoImport = true
      }
    }
  }
}

local jsonls = {
  settings = {
    json = {
      schemas = require "schemastore".json.schemas(),
      validate = { enable = true }
    }
  }
}

local custom_configs = {
  denols = denols,
  -- eslint = eslint,
  sumneko_lua = sumneko_lua,
  vuels = vuels,
  jsonls = jsonls
}

local function make_config(server_name)
  -- enable snippet support
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  local custom_config = {}

  if custom_configs[server_name] ~= nil then
    custom_config = custom_configs[server_name]
  end

  local merged_config =
  vim.tbl_deep_extend(
    "force",
    {
      capabilities = capabilities,
      -- map buffer local keybindings when the language server attaches
      on_attach = common_on_attach,
      handlers = common_handlers
    },
    custom_config
  )
  return merged_config
end

local function is_a_deno_project()
  return utils.has_root_file({ "deno.json", "deno.jsonc" })
end

local function is_a_vite_project()
  return utils.has_root_file({ "vite.config.js", "vite.config.ts" })
end

local function setup_server(server)
  if (server == "tsserver" and is_a_deno_project()) then
    return
  end
  if server == "denols" and utils.file_exists(vim.fn.getcwd() .. "/package.json") then
    return
  end
  if server == "volar" and not is_a_vite_project() then
    return
  end
  if server == "vuels" and is_a_vite_project() then
    return
  end

  local config = make_config(server)
  lsp_config[server].setup(config)
end

for _, name in pairs(servers) do
  setup_server(name)
end

-- https://github.com/jose-elias-alvarez/typescript.nvim
if not is_a_deno_project() then
  require("typescript").setup(
    {
      disable_commands = false, -- prevent the plugin from creating Vim commands
      debug = false, -- enable debug logging for commands
      go_to_source_definition = {
        fallback = true -- fall back to standard LSP definition on failure
      },
      server = {
        handlers = common_handlers,
        on_attach = common_on_attach
      }
    }
  )
end

-- https://github.com/ray-x/lsp_signature.nvim
require "lsp_signature".setup {
  hint_enable = true,
  hint_scheme = "Hint",
  hint_prefix = "» ",
  floating_window = false
}
