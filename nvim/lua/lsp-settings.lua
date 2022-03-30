local option = vim.api.nvim_set_option

local lspconfig = require "lspconfig"

-- https://github.com/williamboman/nvim-lsp-installer

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
local lsp_installer_servers = require("nvim-lsp-installer.servers")

local servers = {
  "angularjs",
  "bashls",
  "cssls",
  "denols",
  "eslint",
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

local common_on_attach = function(client)
  option("omnifunc", "v:lua.vim.lsp.omnifunc")

  require "keybindings".lspKeybindings(client)
  require "lsp_signature".on_attach(
    {
      toggle_key = "<M-x>"
    }
  )

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.cmd(
      [[
        augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END
      ]],
      false
    )
  end
end

local tsserver = {
  on_attach = function(client)
    if client.config.flags then
      client.config.flags.allow_incremental_sync = true
    end
    client.resolved_capabilities.document_formatting = false
  end
}

local denols = {
  init_options = {
    enable = true,
    lint = true,
    unstable = true
  }
}

local vuels = {
  settings = {
    vetur = {
      completion = {
        autoImport = true,
        useScaffoldSnippets = true,
        tagCasing = "kebab"
      },
      validation = {
        template = true,
        script = true,
        style = true,
        templateProps = true,
        interpolation = true
      },
      languageFeatures = {
        codeActions = true,
        updateImportOnFileMove = true,
        semanticTokens = true
      },
      experimental = {
        templateInterpolationService = true
      }
    }
  }
}

local stylelint_lsp = {
  settings = {
    stylelintplus = {
      autoFixOnFormat = true,
      autoFixOnSave = true
    }
  }
}

local eslint = {
  on_attach = function(client)
    -- neovim's LSP client does not currently support dynamic
    -- capabilities registration, so we need to set
    -- the resolved capabilities of the eslint server ourselves!
    client.resolved_capabilities.document_formatting = true
    common_on_attach(client)
  end,
  settings = {
    format = {enable = true} -- this will enable formatting
  }
}

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

local custom_configs = {
  tsserver,
  denols,
  vuels,
  stylelint_lsp,
  eslint,
  sumneko_lua
}

local function make_config(server_name)
  -- enable snippet support
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  local custom_config = {}

  if custom_configs[server_name] ~= nil then
    custom_config = custom_configs[server_name]
  end

  return vim.tbl_deep_extend(
    "force",
    {
      capabilities = capabilities,
      -- map buffer local keybindings when the language server attaches
      on_attach = common_on_attach
    },
    custom_config
  )
end

function file_exists(name)
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
        if server == "eslint" and not file_exists(os.getenv("PWD") .. "/package.json") then
          return
        end
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
