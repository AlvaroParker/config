local function active_gradient()
    return {
        colors = {
            "rgba(89b4faFF)",
            "rgba(b4befeFF)",
            "rgba(cba6f7FF)",
        },
        angle = 45,
    }
end

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
    ecosystem = {
        no_update_news = true,
    },
    misc = {
        disable_hyprland_logo = true,
        focus_on_activate = false,
        on_focus_under_fullscreen = true,
        splash_font_family = "Inter V",
        allow_session_lock_restore = true,
        enable_anr_dialog = false,
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
        -- Lua validates gaps as integers; the legacy config used 2.5.
        gaps_in = 3,
        gaps_out = 5,
        border_size = 2,
        col = {
            active_border = active_gradient(),
            inactive_border = "rgba(45475a99)",
        },
        layout = "dwindle",
    },
    group = {
        col = {
            border_active = active_gradient(),
            border_inactive = "rgba(45475a99)",
        },
        groupbar = {
            gradients = true,
            render_titles = false,
            enabled = false,
            col = {
                inactive = "rgba(45475a99)",
                active = active_gradient(),
            },
        },
    },
    decoration = {
        rounding = 8,
        active_opacity = 1.0,
        inactive_opacity = 0.98,
        fullscreen_opacity = 1.0,
        blur = {
            enabled = true,
            popups = true,
            size = 3,
            passes = 4,
            ignore_opacity = true,
            brightness = 1.0,
            contrast = 1.05,
            noise = 0.01,
        },
        shadow = {
            enabled = false,
            range = 12,
            render_power = 2,
            color = "rgba(89b4fa66)",
            color_inactive = "rgba(1e1e2e66)",
        },
    },
    dwindle = {
        preserve_split = true,
    },
})
