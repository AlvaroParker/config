-- Nocturne look for Hyprland. Colours come from lua/palette.lua, which
-- nocturne/build generates from nocturne/palette.toml.
local palette = require("lua.palette")

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
    ecosystem = {
        no_update_news = true,
    },
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        background_color = palette.rgb("ink-0"),
        focus_on_activate = false,
        on_focus_under_fullscreen = true,
        allow_session_lock_restore = true,
        enable_anr_dialog = false,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
    },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        repeat_rate = 75,
        repeat_delay = 500,
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
        },
    },
    general = {
        -- One gap everywhere: 8 px between windows (4 + 4), to the bar and to the edge.
        gaps_in = 4,
        gaps_out = 8,
        -- One edge per object: a 1 px border, the accent only on the focused window.
        border_size = 1,
        col = {
            active_border = palette.rgb("accent"),
            inactive_border = palette.rgb("line"),
        },
        layout = "dwindle",
    },
    group = {
        col = {
            border_active = palette.rgb("accent"),
            border_inactive = palette.rgb("line"),
        },
        groupbar = {
            enabled = false,
            render_titles = false,
            col = {
                active = palette.rgb("accent"),
                inactive = palette.rgb("line"),
            },
        },
    },
    decoration = {
        rounding = 10,
        -- Windows are solid. Focus is shown by the border and a slight dim on the rest.
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1.0,
        dim_inactive = true,
        dim_strength = 0.08,
        -- Backdrop behind surfaces with dim_around, such as the launcher.
        dim_around = 0.4,
        -- Blur is for surfaces that appear briefly over your work (see rules.lua).
        blur = {
            enabled = true,
            size = 8,
            passes = 2,
            popups = true,
            noise = 0.012,
            contrast = 1.0,
            brightness = 1.0,
            vibrancy = 0.1,
        },
        -- Shadows only show on floating windows; rules.lua turns them off for tiles.
        shadow = {
            enabled = true,
            range = 28,
            render_power = 3,
            offset = { 0, 8 },
            color = palette.rgba("ink-0", 0.55),
            color_inactive = palette.rgba("ink-0", 0.35),
        },
    },
    dwindle = {
        preserve_split = true,
    },
})
