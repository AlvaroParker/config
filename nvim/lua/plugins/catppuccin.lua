return {
  "catppuccin/nvim",
  opts = {
    transparent_background = true, -- catppuccin has this option built-in
    integrations = {
      -- enable integrations as you like
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd("colorscheme catppuccin")
  end,
}
