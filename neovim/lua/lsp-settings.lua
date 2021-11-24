local option = vim.api.nvim_set_option

local lspconfig = require "lspconfig"

--
-- nvim-lsp-installer
--

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
local lsp_installer_servers = require("nvim-lsp-installer.servers")

local servers = {
  "bashls",
  "cssls",
  "denols",
  "eslint",
  "html",
  "jsonls",
  "sumneko_lua",
  "stylelint_lsp",
  "svelte",
  "tsserver",
  "vuels",
  "yamlls"
}

local common_on_attach = function(client)
  option("omnifunc", "v:lua.vim.lsp.omnifunc")

  require "keybindings".lspKeybindings(client)

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

local tsserver_config = {
  on_attach = function(client)
    if client.config.flags then
      client.config.flags.allow_incremental_sync = true
    end
    client.resolved_capabilities.document_formatting = false
  end
}

local denols_config = {
  init_options = {
    enable = true,
    lint = true,
    unstable = true
  },
  root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc", "tsconfig.json")
}

local vuels_config = {
  settings = {
    vetur = {
      completion = {
        autoImport = true,
        useScaffoldSnippets = true
      },
      validation = {
        template = true,
        script = true,
        style = true,
        templateProps = true,
        interpolation = true
      },
      experimental = {
        templateInterpolationService = true
      }
    }
  }
}

local stylelint_lsp_config = {
  settings = {
    stylelintplus = {
      autoFixOnFormat = true,
      autoFixOnSave = true
    }
  }
}

local eslint_config = {
  on_attach = function(client)
    -- neovim's LSP client does not currently support dynamic
    -- capabilities registration, so we need to setth
    -- the resolved capabilities of the eslint server ourselves!
    client.resolved_capabilities.document_formatting = true
    common_on_attach(client)
  end,
  settings = {
    format = {enable = true} -- this will enable formatting
  }
}

local function make_config(server_name)
  -- enable snippet support
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  local custom_config = {}

  if server_name == "tsserver" then
    custom_config = tsserver_config
  end
  if server_name == "stylelint_lsp" then
    custom_config = stylelint_lsp_config
  end
  if server_name == "denols" then
    custom_config = denols_config
  end
  if server_name == "vuels" then
    custom_config = vuels_config
  end
  if server_name == "stylelint_lsp" then
    custom_config = stylelint_lsp_config
  end
  if server_name == "eslint" then
    custom_config = eslint_config
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

for _, name in pairs(servers) do
  local server_available, requested_server = lsp_installer_servers.get_server(name)
  if server_available then
    requested_server:on_ready(
      function()
        local config = make_config(requested_server.name)
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

-- local luadev =
--   require("lua-dev").setup {
--   -- workaround to disable error message ("cmd is not configured for lua language server")
--   lspconfig = {
--     enabled = false
--   }
-- }

-- lspconfig.sumneko_lua.setup(luadev)

-- bash
-- lspconfig.bashls.setup(
--   {
--     filetypes = {"sh", "bash", "zsh"}
--   }
-- )
