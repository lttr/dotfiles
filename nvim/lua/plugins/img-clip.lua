-- https://github.com/hakonharnes/img-clip.nvim

return {
  "HakonHarnes/img-clip.nvim",
  opts = {
    filetypes = {
      codecompanion = {
        dir_path = "/tmp",
        file_name = "img-clip_%Y-%m-%d-%H-%M-%S",
        prompt_for_file_name = false,
        template = "[Image]($FILE_PATH)",
        use_absolute_path = true,
      },
    },
  },
}
