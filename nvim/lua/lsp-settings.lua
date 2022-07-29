-- https://github.com/williamboman/nvim-lsp-installer
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
-- https://github.com/jose-elias-alvarez/nvim-lsp-ts-utils

local nvim_lsp = require("lspconfig")

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
local lsp_installer_servers = require("nvim-lsp-installer.servers")

local servers = {
  "angularjs",
  "bashls",
  "cssls",
  "denols",
  -- "eslint",
  "gopls",
  "graphql",
  "html",
  "jsonls",
  "sumneko_lua",
  "stylelint_lsp",
  "svelte",
  "tailwindcss",
  "terraformls",
  "tsserver",
  "vuels",
  -- "volar",
  "yamlls"
}

local common_handlers = {
  -- let plugin lsp_lines handle virtual diagnostic text
  ["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
      underline = true,
      signs = false,
      virtual_text = false,
      update_in_insert = false
    }
  )
}

local common_on_attach = function(client)
  vim.api.nvim_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  require "keybindings".lspKeybindings(client)
  client.resolved_capabilities.document_formatting = false

  -- Set autocommands conditional on server_capabilities
  -- if client.resolved_capabilities.document_highlight then
  -- vim.cmd(
  --   [[
  --     augroup lsp_document_highlight
  --     autocmd! * <buffer>
  --     autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
  --     autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
  --     augroup END
  --   ]],
  --   false
  -- )
  -- end
end

local tsserver = {
  root_dir = nvim_lsp.util.root_pattern("package.json"),
  -- Needed for inlayHints. Merge this table with your settings or copy
  -- it from the source if you want to add your own init_options.
  init_options = require("nvim-lsp-ts-utils").init_options,
  on_attach = function(client)
    local ts_utils = require("nvim-lsp-ts-utils")
    ts_utils.setup(
      {
        auto_inlay_hints = false
      }
    )
    -- required to fix code action ranges and filter diagnostics
    ts_utils.setup_client(client)
    require "keybindings".lspTsUtilsKeybindings()

    if client.config.flags then
      client.config.flags.allow_incremental_sync = true
    end
    client.resolved_capabilities.document_formatting = false
  end
}

local denols = {
  root_dir = nvim_lsp.util.root_pattern({"deno.json", "deps.ts"}),
  init_options = {
    enable = true,
    lint = true,
    unstable = true
  },
  on_attach = function(client)
    -- let null ls do the formatting
    client.resolved_capabilities.document_formatting = false
  end
}

local stylelint_lsp = {
  filetypes = {"css", "less", "scss", "vue", "javascriptreact", "typescriptreact"},
  settings = {
    stylelintplus = {
      autoFixOnFormat = true,
      autoFixOnSave = true
    }
  }
}

-- local eslint = {
--   on_attach = function(client)
--     -- neovim's LSP client does not currently support dynamic
--     -- capabilities registration, so we need to set
--     -- the resolved capabilities of the eslint server ourselves!
--     client.resolved_capabilities.document_formatting = true
--     common_on_attach(client)
--   end,
--   settings = {
--     format = {enable = true} -- this will enable formatting
--   }
-- }

local sumneko_lua = {
  cmd = {
    vim.fn.getenv "HOME" .. "/.local/share/nvim/lsp_servers/sumneko_lua/extension/server/bin/Linux/lua-language-server"
  },
  settings = {
    Lua = {
      dignostics = {
        globals = {"vim"}
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
      validate = {enable = true}
    }
  }
}

local custom_configs = {
  tsserver = tsserver,
  denols = denols,
  stylelint_lsp = stylelint_lsp,
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

local function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

for _, name in pairs(servers) do
  local server_available, requested_server = lsp_installer_servers.get_server(name)
  if server_available then
    requested_server:on_ready(
      function()
        local server = requested_server.name
        local config = make_config(server)
        -- if server == "eslint" and not file_exists(os.getenv("PWD") .. "/package.json") then
        -- return
        -- end
        if server == "stylelint_lsp" and not file_exists(os.getenv("PWD") .. "/package.json") then
          return
        end
        if server == "denols" and file_exists(os.getenv("PWD") .. "/package.json") then
          return
        end
        if server == "tsserver" and file_exists(os.getenv("PWD") .. "/deps.ts") then
          return
        end
        if server == "tsserver" and file_exists(os.getenv("PWD") .. "/deps.js") then
          return
        end
        if server == "tsserver" and file_exists(os.getenv("PWD") .. "/deno.json") then
          return
        end
        requested_server:setup(config)
      end
    )
    if not requested_server:is_installed() then
      -- Queue the server to be installed
      print("Installing " .. name)
      requested_server:install()
    end
  end
end

-- https://github.com/ray-x/lsp_signature.nvim
require "lsp_signature".setup {
  hint_enable = true,
  hint_scheme = "Hint",
  hint_prefix = "» ",
  floating_window = false
}
