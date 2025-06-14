-- https://codecompanion.olimorris.dev

return {
  "olimorris/codecompanion.nvim", -- The KING of AI programming
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
  dependencies = {
    -- "j-hui/fidget.nvim", -- Display status
    -- "ravitemer/codecompanion-history.nvim", -- Save and load conversation history
    -- {
    --   "ravitemer/mcphub.nvim", -- Manage MCP servers
    --   cmd = "MCPHub",
    --   build = "pnpm add -g mcp-hub@latest",
    --   config = true,
    -- },
    -- {
    --   "HakonHarnes/img-clip.nvim", -- Share images with the chat buffer
    --   event = "VeryLazy",
    --   cmd = "PasteImage",
    --   opts = {
    --     filetypes = {
    --       codecompanion = {
    --         prompt_for_file_name = false,
    --         template = "[Image]($FILE_PATH)",
    --         use_absolute_path = true,
    --       },
    --     },
    --   },
    -- },
  },
  opts = {
    -- extensions = {
    --   history = {
    --     enabled = true,
    --     opts = {
    --       keymap = "gh",
    --       save_chat_keymap = "sc",
    --       auto_save = false,
    --       auto_generate_title = true,
    --       continue_last_chat = false,
    --       delete_on_clearing_chat = false,
    --       picker = "snacks",
    --       enable_logging = false,
    --       dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
    --     },
    --   },
    --   mcphub = {
    --     callback = "mcphub.extensions.codecompanion",
    --     opts = {
    --       make_vars = true,
    --       make_slash_commands = true,
    --       show_result_in_chat = true,
    --     },
    --   },
    -- },
    -- prompt_library = {
    --   ["Test workflow"] = {
    --     strategy = "workflow",
    --     description = "Use a workflow to test the plugin",
    --     opts = {
    --       index = 4,
    --     },
    --     prompts = {
    --       {
    --         {
    --           role = "user",
    --           content = "Generate a Python class for managing a book library with methods for adding, removing, and searching books",
    --           opts = {
    --             auto_submit = false,
    --           },
    --         },
    --       },
    --       {
    --         {
    --           role = "user",
    --           content = "Write unit tests for the library class you just created",
    --           opts = {
    --             auto_submit = true,
    --           },
    --         },
    --       },
    --       {
    --         {
    --           role = "user",
    --           content = "Create a TypeScript interface for a complex e-commerce shopping cart system",
    --           opts = {
    --             auto_submit = true,
    --           },
    --         },
    --       },
    --       {
    --         {
    --           role = "user",
    --           content = "Write a recursive algorithm to balance a binary search tree in Java",
    --           opts = {
    --             auto_submit = true,
    --           },
    --         },
    --       },
    --       {
    --         {
    --           role = "user",
    --           content = "Generate a comprehensive regex pattern to validate email addresses with explanations",
    --           opts = {
    --             auto_submit = true,
    --           },
    --         },
    --       },
    --       {
    --         {
    --           role = "user",
    --           content = "Create a Rust struct and implementation for a thread-safe message queue",
    --           opts = {
    --             auto_submit = true,
    --           },
    --         },
    --       },
    --       {
    --         {
    --           role = "user",
    --           content = "Write a GitHub Actions workflow file for CI/CD with multiple stages",
    --           opts = {
    --             auto_submit = true,
    --           },
    --         },
    --       },
    --       {
    --         {
    --           role = "user",
    --           content = "Create SQL queries for a complex database schema with joins across 4 tables",
    --           opts = {
    --             auto_submit = true,
    --           },
    --         },
    --       },
    --       {
    --         {
    --           role = "user",
    --           content = "Write a Lua configuration for Neovim with custom keybindings and plugins",
    --           opts = {
    --             auto_submit = true,
    --           },
    --         },
    --       },
    --       {
    --         {
    --           role = "user",
    --           content = "Generate documentation in JSDoc format for a complex JavaScript API client",
    --           opts = {
    --             auto_submit = true,
    --           },
    --         },
    --       },
    --     },
    --   },
    -- },
    strategies = {
      chat = {
        adapter = "anthropic",
        roles = {
          user = "lt",
        },
        keymaps = {
          send = {
            modes = {
              i = { "<C-CR>", "<C-s>" },
            },
          },
          completion = {
            modes = {
              i = "<C-x>",
            },
          },
        },
        slash_commands = {
          ["buffer"] = {
            keymaps = {
              modes = {
                i = "<C-b>",
              },
            },
          },
          ["fetch"] = {
            keymaps = {
              modes = {
                i = "<C-f>",
              },
            },
          },
          ["help"] = {
            opts = {
              max_lines = 1000,
            },
          },
          ["image"] = {
            keymaps = {
              modes = {
                i = "<C-i>",
              },
            },
            opts = {
              dirs = { "~/Pictures/Screenshots" },
            },
          },
        },
      },
      inline = {
        adapter = "anthropic",
      },
    },
    display = {
      action_palette = {
        provider = "default",
      },
      chat = {
        -- show_references = true,
        -- show_header_separator = false,
        -- show_settings = false,
      },
    },
  },
  keys = {
    {
      "<C-a>",
      "<cmd>CodeCompanionActions<CR>",
      desc = "Open the action palette",
      mode = { "n", "v" },
    },
    {
      "<Leader>a",
      "<cmd>CodeCompanionChat Toggle<CR>",
      desc = "Toggle a chat buffer",
      mode = { "n", "v" },
    },
    {
      "<LocalLeader>a",
      "<cmd>CodeCompanionChat Add<CR>",
      desc = "Add code to a chat buffer",
      mode = { "v" },
    },
  },
  init = function() vim.cmd([[cab cc CodeCompanion]]) end,
}
