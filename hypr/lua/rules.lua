hl.window_rule({
    name = "rofi-window",
    match = {
        class = "^(rofi)$",
    },
    no_anim = true,
})

hl.layer_rule({
    name = "rofi-layer",
    match = {
        namespace = "rofi",
    },
    no_anim = true,
})

hl.window_rule({
    name = "center-floating",
    match = {
        float = true,
    },
    center = true,
})

hl.window_rule({
    name = "clipse-clipboard",
    match = {
        class = "clipse",
    },
    float = true,
    size = { 622, 652 },
})
