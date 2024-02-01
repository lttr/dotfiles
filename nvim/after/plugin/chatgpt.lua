-- https://github.com/jackMort/ChatGPT.nvim

require "chatgpt".setup {
  openai_params = {
    model = "gpt-4",
  },
  openai_edit_params = {
    model = "gpt-4-1106-preview",
  },
  popup_layout = {
    center = {
      width = "60%",
      height = "70%",
    },
  },
}
