local default_apps = require("lua.default_apps")
local screenshots = require("lua.screenshots")

local main_mod = "SUPER"


local alacritty = {
    terminal = "alacritty",
    clipboard = "alacritty --class app.clipse -e 'clipse'"
}

local ghostty = {
    terminal = "ghostty",
    clipboard = "ghostty --class=app.clipse -e 'clipse'"
}

local default_terminal = ghostty

local function bind(keys, dispatcher, opts)
    return hl.bind(keys, dispatcher, opts)
end

local function exec(command)
    return hl.dsp.exec_cmd(command)
end

bind(main_mod .. " + SHIFT + Q", hl.dsp.window.close())
bind(main_mod .. " + SHIFT + E", hl.dsp.exit())
bind(main_mod .. " + SHIFT + space", hl.dsp.window.float({ action = "toggle" }))
bind(main_mod .. " + P", hl.dsp.window.pseudo())

bind(main_mod .. " + H", hl.dsp.focus({ direction = "l" }))
bind(main_mod .. " + L", hl.dsp.focus({ direction = "r" }))
bind(main_mod .. " + K", hl.dsp.focus({ direction = "u" }))
bind(main_mod .. " + J", hl.dsp.focus({ direction = "d" }))
bind(main_mod .. " + U", exec("hyprctl dispatch focusurgentorlast"))

bind(main_mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
bind(main_mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
bind(main_mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
bind(main_mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))

bind(main_mod .. " + F", hl.dsp.window.fullscreen())
bind(main_mod .. " + SHIFT + F", hl.dsp.window.fullscreen_state({ internal = 2, client = 0, action = "toggle" }))

bind(main_mod .. " + X", hl.dsp.group.toggle())
bind(main_mod .. " + CTRL + H", hl.dsp.group.prev())
bind(main_mod .. " + CTRL + L", hl.dsp.group.next())

for workspace = 1, 10 do
    local key = tostring(workspace % 10)
    bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
    bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

bind(main_mod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "m-1" }), { repeating = true })
bind(main_mod .. " + Tab", hl.dsp.focus({ workspace = "m+1" }), { repeating = true })

bind(main_mod .. " + SHIFT + C", hl.dsp.window.move({ workspace = "special:pocket" }))
bind(main_mod .. " + C", hl.dsp.workspace.toggle_special("pocket"))

bind(main_mod .. " + SHIFT + O", hl.dsp.window.move({ workspace = "special:other" }))
bind(main_mod .. " + O", hl.dsp.workspace.toggle_special("other"))

-- code:21 = `=` key
bind(main_mod .. " + SHIFT + code:21", hl.dsp.window.move({ workspace = "special:aux" }))
bind(main_mod .. " + code:21", hl.dsp.workspace.toggle_special("aux"))

bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

bind(main_mod .. " + SHIFT + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    bind("L", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
    bind("H", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
    bind("K", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
    bind("J", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
    bind("escape", hl.dsp.submap("reset"))
end)

bind(main_mod .. " + return", exec(default_terminal.terminal))
bind(main_mod .. " + SHIFT + return", exec(default_terminal.terminal .. " -e ~/.local/bin/auto_tmux"))
bind(main_mod .. " + E", exec("nautilus"))
bind(main_mod .. " + D", exec("rofi -show drun"))
bind(main_mod .. " + I", exec(default_apps.browser))
bind(main_mod .. " + T", exec("/opt/teams-for-linux/teams-for-linux --ozone-platform=x11"))

bind(main_mod .. " + SHIFT + N", exec("hyprctl hyprsunset temperature 3500"))
bind(main_mod .. " + SHIFT + M", exec("hyprctl hyprsunset identity"))
bind(main_mod .. " + up", exec("hyprctl hyprsunset temperature +10"), { repeating = true })
bind(main_mod .. " + down", exec("hyprctl hyprsunset temperature -10"), { repeating = true })
bind(main_mod .. " + SHIFT + I", exec("busctl --user call rs.wl-gammarelay / rs.wl.gammarelay ToggleInverted"),
    { repeating = true })

bind(main_mod .. " + SHIFT + W", exec("hyprlock"))
bind(main_mod .. " + N", exec("swaync-client --toggle-panel"))

bind("XF86MonBrightnessUp", exec("swayosd-client --brightness=raise"), { locked = true, repeating = true })
bind("XF86MonBrightnessDown", exec("swayosd-client --brightness=lower"), { locked = true, repeating = true })
bind(main_mod .. " + XF86MonBrightnessUp", exec("light -S 100"))
bind(main_mod .. " + XF86MonBrightnessDown", exec("light -S 0"))

bind("XF86AudioRaiseVolume", exec("swayosd-client --output-volume raise"), { repeating = true })
bind("XF86AudioLowerVolume", exec("swayosd-client --output-volume lower"), { repeating = true })
bind("XF86AudioMute", exec("swayosd-client --output-volume mute-toggle"))
bind("XF86AudioMicMute", exec("swayosd-client --input-volume mute-toggle"))
bind(main_mod .. " + CTRL + M", exec("swayosd-client --input-volume mute-toggle"))

bind("XF86AudioPlay", exec("playerctl play-pause"))
bind("XF86AudioPrev", exec("playerctl previous"))
bind("XF86AudioNext", exec("playerctl next"))

bind("Caps_Lock", exec("sleep 0.1 && swayosd-client --caps-lock"))

bind(main_mod .. " + SHIFT + S", screenshots.region)
bind(main_mod .. " + SHIFT + D", screenshots.current_monitor)
bind("Print", screenshots.current_monitor)
bind("XF86SelectiveScreenshot", screenshots.region)

bind(main_mod .. " + SHIFT + B", exec("killall -SIGUSR1 waybar"))
bind(main_mod .. " + V", exec(default_terminal.clipboard))

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
