hl.curve("parnim", {
    type = "bezier",
    points = {
        { 0.56, 0.34 },
        { 0.03, 0.99 },
    },
})

hl.curve("bounce", {
    type = "bezier",
    points = {
        { 0.175, 0.885 },
        { 0.32, 1.15 },
    },
})

hl.config({
    animations = {
        enabled = true,
    },
})

hl.animation({ leaf = "border", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "default", style = "slidevert" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 7, bezier = "parnim", style = "popin" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "parnim", style = "popin" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 7, bezier = "bounce", style = "slide" })
