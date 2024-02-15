-- https://github.com/johmsalas/text-case.nvim

require('textcase').setup {
  -- Set `default_keymappings_enabled` to false if you don't want automatic keymappings to be registered.
  default_keymappings_enabled = true,
  -- `prefix` is only considered if `default_keymappings_enabled` is true. It configures the prefix
  -- of the keymappings, e.g. `gau ` executes the `current_word` method with `to_upper_case`
  -- and `gaou` executes the `operator` method with `to_upper_case`.
  prefix = "gt",
  -- If `substitude_command_name` is not nil, an additional command with the passed in name
  -- will be created that does the same thing as "Subs" does.
  substitude_command_name = "S",
  enabled_methods = {
    "to_upper_case",
    "to_lower_case",
    "to_snake_case",
    "to_dash_case",
    "to_title_dash_case",
    "to_constant_case",
    "to_dot_case",
    "to_phrase_case",
    "to_camel_case",
    "to_pascal_case",
    "to_title_case",
    "to_path_case",
    "to_upper_phrase_case",
    "to_lower_phrase_case",
  },
}
