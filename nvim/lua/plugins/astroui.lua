---@type LazySpec
return {
  ---@type AstroUIOpts
  "AstroNvim/astroui",
  opts = {
    colorscheme = "catppuccin-mocha",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = {
        -- set the transparency for all of these highlight groups
        --
        -- TabLineFill = { bg = "#1e1e2e", ctermbg = "NONE" },
      },
      astrotheme = { -- a table of overrides/changes when applying the astrotheme theme
        TabLineFill = { bg = "#1e1e2e", ctermbg = "NONE" },
        -- Normal = { bg = "#000000" },
      },
    },
    icons = {
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
