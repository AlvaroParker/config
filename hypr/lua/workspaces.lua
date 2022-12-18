local default_apps = require("lua.default_apps")
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
})

hl.workspace_rule({
    workspace = "10",
    monitor = monitor_names.external,
    default = true,
})

local workspace_apps = {
    ["1"] = "ghostty -e ~/.local/bin/auto_tmux",
    ["10"] = default_apps.browser,
}

hl.on("workspace.created", function(workspace)
    if not workspace.is_empty then
        return
    end

    local command = workspace_apps[workspace.name]
    if command then
        hl.exec_cmd(command, { workspace = workspace.name .. " silent" })
    end
end)
