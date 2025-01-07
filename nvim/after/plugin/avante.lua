-- https://github.com/yetone/avante.nvim/

require("avante_lib").load()

require("avante").setup({
  ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
  provider = "claude", -- Recommend using Claude
  -- auto_suggestions_provider = "claude",
  claude = {
    endpoint = "https://api.anthropic.com",
    model = "claude-3-5-sonnet-20241022",
    temperature = 0,
    max_tokens = 4096,
  },
  behaviour = {
    auto_suggestions = false,
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = true,
  },
  -- mappings = {
  --   --- @class AvanteConflictMappings
  --   diff = {
  --     ours = "co",
  --     theirs = "ct",
  --     all_theirs = "ca",
  --     both = "cb",
  --     cursor = "cc",
  --     next = "]x",
  --     prev = "[x",
  --   },
  --   suggestion = {
  --     accept = "<M-l>",
  --     next = "<M-]>",
  --     prev = "<M-[>",
  --     dismiss = "<C-]>",
  --   },
  --   jump = {
  --     next = "]]",
  --     prev = "[[",
  --   },
  --   submit = {
  --     normal = "<CR>",
  --     insert = "<C-s>",
  --   },
  --   sidebar = {
  --     apply_all = "A",
  --     apply_cursor = "a",
  --     switch_windows = "<Tab>",
  --     reverse_switch_windows = "<S-Tab>",
  --   },
  -- },
  hints = { enabled = false },
  -- windows = {
  --   ---@type "right" | "left" | "top" | "bottom"
  --   position = "right", -- the position of the sidebar
  --   wrap = true, -- similar to vim.o.wrap
  --   width = 30, -- default % based on available width
  --   sidebar_header = {
  --     enabled = true, -- true, false to enable/disable the header
  --     align = "center", -- left, center, right for title
  --     rounded = true,
  --   },
  --   input = {
  --     prefix = "> ",
  --     height = 8, -- Height of the input window in vertical layout
  --   },
  --   edit = {
  --     border = "rounded",
  --     start_insert = true, -- Start insert mode when opening the edit window
  --   },
  --   ask = {
  --     floating = false, -- Open the 'AvanteAsk' prompt in a floating window
  --     start_insert = true, -- Start insert mode when opening the ask window
  --     border = "rounded",
  --     ---@type "ours" | "theirs"
  --     focus_on_apply = "ours", -- which diff to focus after applying
  --   },
  -- },
  -- highlights = {
  --   ---@type AvanteConflictHighlights
  --   diff = {
  --     current = "DiffText",
  --     incoming = "DiffAdd",
  --   },
  -- },
  -- --- @class AvanteConflictUserConfig
  -- diff = {
  --   autojump = true,
  --   ---@type string | fun(): any
  --   list_opener = "copen",
  --   --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
  --   --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
  --   --- Disable by setting to -1.
  --   override_timeoutlen = 500,
  -- },
})

-- prefil edit window with common scenarios to avoid repeating query and submit immediately
local prefill_edit_window = function(request)
  require("avante.api").edit()
  local code_bufnr = vim.api.nvim_get_current_buf()
  local code_winid = vim.api.nvim_get_current_win()
  if code_bufnr == nil or code_winid == nil then
    return
  end
  vim.api.nvim_buf_set_lines(code_bufnr, 0, -1, false, { request })
  -- Optionally set the cursor position to the end of the input
  vim.api.nvim_win_set_cursor(code_winid, { 1, #request + 1 })
  -- Simulate Ctrl+S keypress to submit
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<C-s>", true, true, true),
    "v",
    true
  )
end

-- note most templates are inspired from ChatGPT.nvim -> chatgpt-actions.json
local avante_grammar_correction = [[
  Correct the text to standard English, but keep any source code structure
  intact. Do point out any typos in the code as well. If the visible text is in
  a different language, use such language for the visible text and do not
  translate it into English.
  ]]
local avante_keywords = "Extract the main keywords from the following text"
local avante_code_readability_analysis = [[
  You must identify any readability issues in the code snippet.
  Some readability issues to consider:
  - Unclear naming
  - Unclear purpose
  - Redundant or obvious comments
  - Lack of comments
  - Long or complex one liners
  - Too much nesting
  - Long variable names
  - Inconsistent naming and code style.
  - Code repetition
  You may identify additional problems. The user submits a small section of code from a larger file.
  Only list lines with readability issues, in the format <line_num>|<issue and proposed solution>
  If there's no issues with code respond with only: <OK>
]]
local avante_optimize_code = "Optimize the following code"
local avante_summarize = "Summarize the following text"
local avante_translate =
  "Translate this into Chinese, but keep any code blocks inside intact"
local avante_explain_code = "Explain the following code"
local avante_complete_code = "Complete the following codes written in "
  .. vim.bo.filetype
local avante_add_docstring = "Add docstring to the following codes"
local avante_fix_bugs = "Fix the bugs inside the following codes if any"
local avante_add_tests = "Implement tests for the following code"

require("which-key").add({
  { "<leader>a", group = "Avante" }, -- NOTE: add for avante.nvim
  {
    mode = { "n", "v" },
    {
      "<leader>ag",
      function()
        require("avante.api").ask({ question = avante_grammar_correction })
      end,
      desc = "Grammar Correction(ask)",
    },
    {
      "<leader>ak",
      function() require("avante.api").ask({ question = avante_keywords }) end,
      desc = "Keywords(ask)",
    },
    {
      "<leader>al",
      function()
        require("avante.api").ask({
          question = avante_code_readability_analysis,
        })
      end,
      desc = "Code Readability Analysis(ask)",
    },
    {
      "<leader>ao",
      function() require("avante.api").ask({ question = avante_optimize_code }) end,
      desc = "Optimize Code(ask)",
    },
    {
      "<leader>am",
      function() require("avante.api").ask({ question = avante_summarize }) end,
      desc = "Summarize text(ask)",
    },
    {
      "<leader>an",
      function() require("avante.api").ask({ question = avante_translate }) end,
      desc = "Translate text(ask)",
    },
    {
      "<leader>ax",
      function() require("avante.api").ask({ question = avante_explain_code }) end,
      desc = "Explain Code(ask)",
    },
    {
      "<leader>ac",
      function() require("avante.api").ask({ question = avante_complete_code }) end,
      desc = "Complete Code(ask)",
    },
    {
      "<leader>ad",
      function() require("avante.api").ask({ question = avante_add_docstring }) end,
      desc = "Docstring(ask)",
    },
    {
      "<leader>ab",
      function() require("avante.api").ask({ question = avante_fix_bugs }) end,
      desc = "Fix Bugs(ask)",
    },
    {
      "<leader>au",
      function() require("avante.api").ask({ question = avante_add_tests }) end,
      desc = "Add Tests(ask)",
    },
  },
})
