-- https://github.com/yetone/avante.nvim/

require("avante_lib").load()

require("avante").setup({
  ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
  provider = "claude", -- Recommend using Claude
  -- auto_suggestions_provider = "claude",
  claude = {
    endpoint = "https://api.anthropic.com",
    model = "claude-3-7-sonnet-20250219",
    -- model = "claude-3-5-sonnet-20241022",
    timeout = 30000, -- Timeout in milliseconds
    temperature = 0,
    max_tokens = 8192,
    -- disable_tools = true, -- Disable tools for now (it's enabled by default) as it's causing rate-limit problems with Claude, see more here: https://github.com/yetone/avante.nvim/issues/1384
  },
  behaviour = {
    auto_suggestions = false,
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = true,
  },
  hints = { enabled = false },
  windows = {
    position = "right", -- the position of the sidebar
    wrap = true, -- similar to vim.o.wrap
    width = 35, -- default % based on available width
  },
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

-- build in keymaps
-- ask = "<leader>aa", -- ask
-- edit = "<leader>ae", -- edit in visual mode
-- refresh = "<leader>ar", -- refresh

require("which-key").add({
  { "<leader>a", group = "Avante" },
  {
    mode = { "n", "v" },
    {
      "<leader>ac",
      function() vim.cmd("AvanteClear") end,
      desc = "AvanteClear",
    },
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
      "<leader>ap",
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
