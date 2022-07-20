-- https://github.com/hrsh7th/nvim-cmp

local lspkind = require "lspkind"
lspkind.init()

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
    return false
  end
  if (vim.api.nvim_win_get_cursor(0)) then
    local positionTable = vim.api.nvim_win_get_cursor(0)
    local line = positionTable[1]
    local col = positionTable[2]
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  else
    return false
  end
end

local cmp = require "cmp"
local luasnip = require "luasnip"

cmp.setup {
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end
  },
  completion = {
    autocomplete = true
  },
  mapping = {
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping(
      function()
        cmp.complete()
      end
    ),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true
    },
    ["<Tab>"] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end,
      {"i", "s"}
    ),
    ["<S-Tab>"] = cmp.mapping(
      function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end,
      {"i", "s"}
    )
  },
  sources = {
    {name = "cmp_jira"},
    {name = "cmp_vue_components"},
    {name = "git"},
    {name = "nvim_lsp_signature_help"},
    {name = "nvim_lua"},
    {name = "nvim_lsp", max_item_count = 10},
    {name = "path"},
    {name = "luasnip"}
    -- {name = "buffer", keyword_length = 5} -- too much noise
  },
  formatting = {
    format = lspkind.cmp_format {
      with_text = true,
      menu = {
        buffer = "[buf]",
        nvim_lsp = "[LSP]",
        nvim_lua = "[api]",
        path = "[path]",
        luasnip = "[snip]"
      }
    }
  }
}

require("goto-preview").setup {}
require("cmp_jira").setup {
  file_types = {"gitcommit"},
  jira = {
    -- email: optional, alternatively specify via $JIRA_USER_EMAIL
    -- url: optional, alternatively specify via $JIRA_WORKSPACE_URL
    -- jql: optional, lua format string, escaped username/email will be passed to string.format()
    jql = "assignee=%s+and+resolution=unresolved"
  }
}
require("cmp_vue_components").setup {
  file_types = {"vue"}
}
require("cmp_git").setup {
  filetypes = {"gitcommit"}
}
