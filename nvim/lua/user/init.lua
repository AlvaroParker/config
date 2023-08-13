return {
  colorscheme = "tokyonight",
  -- the init key will apply to all colorschemes, this sets transparency
  highlights = {
    -- apply highlight group to all colorschemes (include the default_theme)
    init = {
      -- set the transparency for all of these highlight groups
      Normal = { bg = "NONE", ctermbg = "NONE" },
      NormalNC = { bg = "NONE", ctermbg = "NONE" },
      CursorColumn = { cterm = {}, ctermbg = "NONE", ctermfg = "NONE" },
      CursorLine = { cterm = {}, ctermbg = "NONE", ctermfg = "NONE" },
      CursorLineNr = { cterm = {}, ctermbg = "NONE", ctermfg = "NONE" },
      LineNr = {},
      SignColumn = {},
      StatusLine = {},
      NeoTreeNormal = { bg = "NONE", ctermbg = "NONE" },
      NeoTreeNormalNC = { bg = "NONE", ctermbg = "NONE" },
    },
  },


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
    { import = "astrocommunity.pack.go" },
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
  -- vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
  -- vim.cmd("hi CursorColumn cterm=NONE ctermbg=NONE ctermfg=NONE")
  -- vim.cmd("hi CursorLine cterm=NONE ctermbg=NONE ctermfg=NONE")
  -- vim.cmd("hi CursorLineNr cterm=NONE ctermbg=NONE ctermbg=NONE")
  -- vim.cmd("hi clear LineNr")
  -- vim.cmd("hi clear SignColumn")
  -- vim.cmd("hi clear StatusLine")
  end,
}
