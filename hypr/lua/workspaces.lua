local monitor_names = require("lua.monitor_names")

hl.workspace_rule({
    workspace = "special:pocket",
    monitor = monitor_names.external,
    default = true,
})

hl.workspace_rule({
    workspace = "special:other",
    monitor = monitor_names.external,
    default = true,
})

hl.workspace_rule({
    workspace = "special:aux",
    monitor = monitor_names.external,
    default = true,
})

hl.workspace_rule({
    workspace = "1",
    monitor = monitor_names.laptop,
    default = true,
    on_created_empty = "ghostty -e ~/.local/bin/auto_tmux",
})

hl.workspace_rule({
    workspace = "10",
    monitor = monitor_names.external,
    default = true,
    on_created_empty = "firefox",
})
