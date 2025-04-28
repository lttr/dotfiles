-- https://github.com/hrsh7th/nvim-cmp

local lspkind = require("lspkind")
lspkind.init()

local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
    return false
  end
  if vim.api.nvim_win_get_cursor(0) then
    local positionTable = vim.api.nvim_win_get_cursor(0)
    local line = positionTable[1]
    local col = positionTable[2]
    return col ~= 0
      and vim.api
          .nvim_buf_get_lines(0, line - 1, line, true)[1]
          :sub(col, col)
          :match("%s")
        == nil
  else
    return false
  end
end

local cmp = require("cmp")
local luasnip = require("luasnip")

local border_options = {
  border = "rounded",
  winhighlight = "Normal:Normal,FloatBorder:LineNr,CursorLine:Visual,Search:None",
  side_padding = 1,
}

local tab_function = function(fallback)
  -- if cmp.visible() then
  --   cmp.select_next_item()
  -- else
  if luasnip.expand_or_jumpable() then
    luasnip.expand_or_jump()
  elseif has_words_before() then
    cmp.complete()
  else
    fallback()
  end
end

cmp.setup({
  performance = {
    max_view_entries = 12,
  },
  snippet = {
    expand = function(args) require("luasnip").lsp_expand(args.body) end,
  },
  completion = {
    -- Only show the autocompletion menu when manually triggered
    autocomplete = false,
    -- DO select the first item, but DON'T insert it yet (wait for enter)
    completeopt = "menu,menuone,fuzzy,noinsert",
  },
  window = {
    completion = cmp.config.window.bordered(border_options),
    documentation = cmp.config.window.bordered(border_options),
  },
  mapping = {
    -- ["<c-a>"] = cmp.mapping.complete {
    --   config = {
    --     sources = {
    --       { name = "cody" },
    --     },
    --   },
    -- },
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping(function(fallback) fallback() end),
    ["<C-k>"] = cmp.mapping.select_prev_item({
      behavior = cmp.SelectBehavior.Select,
    }),
    ["<C-j>"] = cmp.mapping.select_next_item({
      behavior = cmp.SelectBehavior.Select,
    }),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping(function() cmp.complete() end),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    }),
    ["<Tab>"] = cmp.mapping(tab_function, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  sources = {
    { name = "luasnip", max_item_count = 3 },
    -- { name = "cody" },
    { name = "codeium" },
    {
      name = "nvim_lsp",
      -- Based on https://github.com/vuejs/language-tools/discussions/4495
      -- Improved autocompletion in Vue files
      ---@param entry cmp.Entry
      ---@param ctx cmp.Context
      entry_filter = function(entry, ctx)
        -- Check if the buffer type is 'vue'
        if ctx.filetype ~= "vue" then
          return true
        end

        local cursor_before_line = ctx.cursor_before_line
        -- For events
        if cursor_before_line:sub(-1) == "@" then
          return entry.completion_item.label:match("^@")
        -- For props also exclude events with `:on-` prefix
        elseif cursor_before_line:sub(-1) == ":" then
          return entry.completion_item.label:match("^:")
            and not entry.completion_item.label:match("^:on%-")
        else
          return true
        end
      end,
    },
    { name = "html-css" },
    { name = "css_classes" },
    { name = "css_variables" },
    { name = "scss_variables" },
    { name = "nuxt_component" },
    { name = "path" },
    { name = "cmp_jira" },
    { name = "git" },
    { name = "nvim_lsp_signature_help" },
    { name = "nvim_lua" },
    -- { name = "buffer", keyword_length = 5 } -- too much noise
  },
  formatting = {
    fields = { cmp.ItemField.Kind, cmp.ItemField.Abbr, cmp.ItemField.Menu },
    format = lspkind.cmp_format({
      mode = "symbol",
      maxwidth = 36,
      ellipsis_char = "…",
      menu = {
        -- cody = "[cody]",
        codeium = "codeium",
        css_classes = "css-class",
        css_variables = "css-var",
        scss_variables = "scss-var",
        nuxt_component = "nuxt",
        path = "path",
        nvim_lsp = "LSP",
        nvim_lua = "api",
        luasnip = "snip",
        buffer = "buf",
      },
    }),
  },
})

require("cmp_css_variables").setup({
  files = {
    "./node_modules/@lttr/puleo/output/puleo.post.css",
    "./assets/css/main.css",
    "./app/assets/css/main.css", -- Nuxt 4
    "./node_modules/open-props/open-props.min.css",
    "./assets/css/settings.css",
    "./packages/base-styles/dist/runtime/assets/css/main.min.css",
    "./output/puleo.post.css",
  },
})

require("cmp-css-classes").setup({
  files = {
    "./node_modules/@lttr/puleo/output/puleo.post.css",
    "./assets/css/main.css",
    "./packages/base-styles/src/runtime/assets/css/main.min.css",
    "./node_modules/open-props/open-props.min.css",
    "./output/puleo.min.css",
  },
})

require("cmp-scss-variables").setup({
  files = {
    "./assets/styles/abstracts/_variables.scss",
    "./assets/styles/variables.scss",
  },
})

require("cmp_jira").setup({
  file_types = { "gitcommit" },
  jira = {
    -- email: optional, alternatively specify via $JIRA_USER_EMAIL
    -- url: optional, alternatively specify via $JIRA_WORKSPACE_URL
    -- jql: optional, lua format string, escaped username/email will be passed to string.format()
    jql = "assignee=%s",
  },
})

require("cmp_git").setup({
  filetypes = { "gitcommit" },
})
