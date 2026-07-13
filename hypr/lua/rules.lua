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
    name = "cliphist-clipboard",
    match = {
        class = "app.cliphist",
    },
    float = true,
    size = { 622, 652 },
})
