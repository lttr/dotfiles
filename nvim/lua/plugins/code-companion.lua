-- https://codecompanion.olimorris.dev

return {
  "olimorris/codecompanion.nvim",
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
  dependencies = {
    "ravitemer/codecompanion-history.nvim", -- Save and load conversation history
    {
      "ravitemer/mcphub.nvim", -- Manage MCP servers
      cmd = "MCPHub",
      config = true,
    },
  },
  opts = {
    extensions = {
      history = {
        opts = {
          picker = "snacks",
        },
      },
      mcphub = {
        callback = "mcphub.extensions.codecompanion",
        opts = {
          make_vars = true,
          make_slash_commands = true,
          show_result_in_chat = true,
        },
      },
    },
    prompt_library = {
      ["Test workflow"] = {
        strategy = "workflow",
        description = "Use a workflow to test the plugin",
        opts = {
          index = 4,
        },
        prompts = {
          {
            {
              role = "user",
              content = "Generate a Python class for managing a book library with methods for adding, removing, and searching books",
              opts = {
                auto_submit = false,
              },
            },
          },
          {
            {
              role = "user",
              content = "Write unit tests for the library class you just created",
              opts = {
                auto_submit = true,
              },
            },
          },
          {
            {
              role = "user",
              content = "Create a TypeScript interface for a complex e-commerce shopping cart system",
              opts = {
                auto_submit = true,
              },
            },
          },
          {
            {
              role = "user",
              content = "Write a recursive algorithm to balance a binary search tree in Java",
              opts = {
                auto_submit = true,
              },
            },
          },
          {
            {
              role = "user",
              content = "Generate a comprehensive regex pattern to validate email addresses with explanations",
              opts = {
                auto_submit = true,
              },
            },
          },
          {
            {
              role = "user",
              content = "Create a Rust struct and implementation for a thread-safe message queue",
              opts = {
                auto_submit = true,
              },
            },
          },
          {
            {
              role = "user",
              content = "Write a GitHub Actions workflow file for CI/CD with multiple stages",
              opts = {
                auto_submit = true,
              },
            },
          },
          {
            {
              role = "user",
              content = "Create SQL queries for a complex database schema with joins across 4 tables",
              opts = {
                auto_submit = true,
              },
            },
          },
          {
            {
              role = "user",
              content = "Write a Lua configuration for Neovim with custom keybindings and plugins",
              opts = {
                auto_submit = true,
              },
            },
          },
          {
            {
              role = "user",
              content = "Generate documentation in JSDoc format for a complex JavaScript API client",
              opts = {
                auto_submit = true,
              },
            },
          },
        },
      },
    },
    adapters = {
      anthropic = function()
        return require("codecompanion.adapters").extend("anthropic", {
          env = {
            api_key = "ANTHROPIC_API_KEY_FOR_CODECOMPANION",
          },
          schema = {
            extended_thinking = {
              default = false,
            },
          },
        })
      end,
    },
    strategies = {
      chat = {
        adapter = {
          name = "anthropic",
          model = "claude-sonnet-4-20250514",
        },
        roles = {
          user = "lttr",
        },
        variables = {
          ["buffer"] = {
            opts = {
              default_params = "watch",
            },
          },
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
              provider = "snacks",
              dirs = { "~/Pictures/Screenshots" },
            },
          },
        },
      },
      inline = {
        adapter = {
          name = "anthropic",
          model = "claude-sonnet-4-20250514",
        },
      },
      cmd = {
        adapter = {
          name = "anthropic",
          model = "claude-sonnet-4-20250514",
        },
      },
    },
    display = {
      action_palette = {
        provider = "default", -- displays the actions palette in a picker window in the middle of the screen
      },
      chat = {
        -- show_references = true,
        -- show_header_separator = false,
        -- show_settings = false,
      },
    },
    diff = {},
  },
  keys = {
    {
      "<Leader>A",
      "<cmd>CodeCompanionActions<CR>",
      desc = "Open the action palette",
      mode = { "n", "v" },
    },
    {
      "<Leader>a",
      "<cmd>CodeCompanionChat Toggle<CR>",
      desc = "Toggle a chat buffer",
      mode = { "n" },
    },
    {
      "<Leader>a",
      "<cmd>CodeCompanion<CR>",
      desc = "Open CodeCompanion inline edit",
      mode = { "v" },
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
