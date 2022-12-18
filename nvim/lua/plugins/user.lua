-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      -- https://manytools.org/hacker-tools/ascii-banner/ for ascii art using ANSI Shadow
      opts.section.header.val = {
        "██████╗  █████╗ ██████╗ ██╗  ██╗███████╗██████╗ ",
        "██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██╔════╝██╔══██╗",
        "██████╔╝███████║██████╔╝█████╔╝ █████╗  ██████╔╝",
        "██╔═══╝ ██╔══██║██╔══██╗██╔═██╗ ██╔══╝  ██╔══██╗",
        "██║     ██║  ██║██║  ██║██║  ██╗███████╗██║  ██║",
        "╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝",
        "                                                ",
        "        ███╗   ██╗██╗   ██╗██╗███╗   ███╗       ",
        "        ████╗  ██║██║   ██║██║████╗ ████║       ",
        "        ██╔██╗ ██║██║   ██║██║██╔████╔██║       ",
        "        ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║       ",
        "        ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║       ",
        "        ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝       ",
      }
      return opts
    end,
  },
  {
    "rcarriga/nvim-notify",
    opts = function(_, opts)
      opts.setup = {
        background_color = "#000000",
      }
    end,
  }
}
