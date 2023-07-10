return {
  colorscheme = "tokyonight",
  plugins = {
    "AstroNvim/astrocommunity",
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = {
        style = "night",
        comments = { italic = true },
        keywords = { italic = true },
      },
    },
    { import = "astrocommunity.pack.rust" },
    { import = "astrocommunity.completion.copilot-lua" },
    { import = "astrocommunity.pack.python" },
    { import = "astrocommunity.pack.cpp" },
  },
  lsp = {
    config = {
      clangd = {
        capabilities = {
          offsetEncoding = "utf-8",
        }
      }
    },
  },
  polish = function()
  end,
}
