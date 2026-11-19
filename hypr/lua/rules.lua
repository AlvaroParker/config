-- Window and layer rules.

-- Floating windows open centred.
hl.window_rule({
    name = "center-floating",
    match = {
        float = true,
    },
    center = true,
})

-- Shadows only where a window really sits above the others.
hl.window_rule({
    name = "tiled-no-shadow",
    match = {
        float = false,
    },
    no_shadow = true,
})

-- Glass is for surfaces that appear briefly over your work. They are drawn
-- translucent in their own CSS; these rules blur what is behind them.
-- ignore_alpha keeps the blur off their transparent margins.
local glass_layers = {
    "rofi",
    "swaync-control-center",
    "swaync-notification-window",
    "swayosd",
}

for _, namespace in ipairs(glass_layers) do
    hl.layer_rule({
        name = "glass-" .. namespace,
        match = {
            namespace = namespace,
        },
        blur = true,
        ignore_alpha = 0.3,
    })
end

-- The launcher dims everything behind it and fades in and out.
hl.layer_rule({
    name = "launcher-backdrop",
    match = {
        namespace = "rofi",
    },
    dim_around = true,
    animation = "fade",
})
