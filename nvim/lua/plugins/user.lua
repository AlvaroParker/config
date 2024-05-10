
-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {
  colorscheme = "catppuccin-mocha",

  -- == Examples of Adding Plugins ==
  "catppuccin/nvim",
  {
    "catppuccin/nvim",
    lazy = false,
    priority = 1000,
  },
}
