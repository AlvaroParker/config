-- Motion: three durations and one curve. Nothing overshoots.
-- Hyprland speed is in tenths of a second: 1.2 = 120 ms, 2 = 200 ms, 2.8 = 280 ms.
-- Closing takes about three quarters of opening.

-- Fast start, gentle stop (ease-out). Used for anything appearing or moving.
hl.curve("settle", {
    type = "bezier",
    points = {
        { 0.16, 1.0 },
        { 0.3, 1.0 },
    },
})

-- Gentle start, quick finish (ease-in). Used for things leaving.
hl.curve("leave", {
    type = "bezier",
    points = {
        { 0.4, 0.0 },
        { 1.0, 1.0 },
    },
})

hl.config({
    animations = {
        enabled = true,
    },
})

hl.animation({ leaf = "global", enabled = true, speed = 2, bezier = "settle" })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 2, bezier = "settle", style = "popin 94%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.5, bezier = "leave", style = "popin 94%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2, bezier = "settle", style = "slide" })

hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.2, bezier = "settle" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.2, bezier = "leave" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 1.2, bezier = "settle" })
hl.animation({ leaf = "border", enabled = true, speed = 1.2, bezier = "settle" })

hl.animation({ leaf = "layersIn", enabled = true, speed = 1.2, bezier = "settle", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 0.9, bezier = "leave", style = "fade" })

-- Workspaces slide sideways; changing workspace group slides them up or down
-- instead, as if the groups were floors (lua/groups.lua switches the style
-- for the length of one slide).
local M = {}

M.workspace_slide_ms = 280

function M.workspace_slide(style)
    hl.animation({ leaf = "workspaces", enabled = true, speed = M.workspace_slide_ms / 100, bezier = "settle", style = style })
end

M.workspace_slide("slide")
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.8, bezier = "settle", style = "slidevert" })

return M
