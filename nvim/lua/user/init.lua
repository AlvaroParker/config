return {
  colorscheme = "tokyonight-night",
  lsp = {
    -- skip_setup = { "rust_analyzer" }, -- rust-tools will handle setting up the LSP
  },
  -- maps.n["]b"] = { function() require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end, desc = "Next buffer" },

  plugins = {
    {
      "folke/tokyonight.nvim",
      name = "tokyonight"
    }, 
  -- Add the community repository of plugin specifications
  "AstroNvim/astrocommunity",
  -- Add gigachad RUST tools
  { import = "astrocommunity.pack.rust", enabled = true },
  { "rust-tools.nvim", opts = {
      tools = { -- rust-tools options
      reload_workspace_from_cargo_toml = true,
      inlay_hints = {
        auto = true,
        only_current_line = false,
        show_parameter_hints = true,
      },
      hover_actions = {
        border = {
          { "╒", "FloatBorder" },
          { "═", "FloatBorder" },
          { "╕", "FloatBorder" },
          { "│", "FloatBorder" },
          { "╛", "FloatBorder" },
          { "─", "FloatBorder" },
          { "╘", "FloatBorder" },
          { "│", "FloatBorder" },
        },
        auto_focus = true,
      },
    },
    }
  },
  },
  polish = function()
    vim.cmd(":set mouse = ")
  end,
}
