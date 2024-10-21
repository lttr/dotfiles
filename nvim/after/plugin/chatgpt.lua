-- https://github.com/jackMort/ChatGPT.nvim

require("chatgpt").setup({
  openai_params = {
    model = "gpt-4o",
    max_tokens = 4000,
  },
  openai_edit_params = {
    model = "gpt-4o",
    max_tokens = 10000,
  },
  popup_layout = {
    center = {
      width = "60%",
      height = "70%",
    },
  },
})
