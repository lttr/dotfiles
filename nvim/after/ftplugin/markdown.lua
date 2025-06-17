-- require("my.keybindings").markdown_keybindings()

-- This does not work, because when you are on multi line
-- bullet in a bullet-list and hit <CR> it will add indentation but not the comment string, which is more annoying then not having support at all
-- It also join lines unexpectadly after gwap combo
--
-- vim.opt.formatoptions:append("r")
-- vim.opt.comments = "b:*,b:-,b:+,bn:>"
