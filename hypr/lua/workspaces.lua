hl.workspace_rule({
    workspace = "special:pocket",
    monitor = "HDMI-A-1",
    default = true,
})

hl.workspace_rule({
    workspace = "special:other",
    monitor = "HDMI-A-1",
    default = true,
})

hl.workspace_rule({
    workspace = "special:aux",
    monitor = "HDMI-A-1",
    default = true,
})

hl.workspace_rule({
    workspace = "1",
    monitor = "eDP-1",
    default = true,
    on_created_empty = "ghostty -e ~/.local/bin/auto_tmux",
})

hl.workspace_rule({
    workspace = "10",
    monitor = "HDMI-A-1",
    default = true,
    on_created_empty = "firefox",
})

-- hl.workspace_rule({
--     workspace = "9",
--     monitor = "HDMI-A-1",
--     default = false,
--     on_created_empty = "flatpak run md.obsidian.Obsidian",
-- })
