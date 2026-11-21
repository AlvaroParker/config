-- Key bindings. Every binding carries a description, so SUPER + / can list
-- them all in the launcher.
local default_apps = require("lua.default_apps")
local groups = require("lua.groups")

local SUPER = "SUPER + "
local terminal = "ghostty"
local launcher = "~/.config/rofi/launcher"
local scripts = "~/.config/hypr/scripts/"

local function bind(keys, description, dispatcher, opts)
    opts = opts or {}
    opts.description = description
    return hl.bind(keys, dispatcher, opts)
end

local function exec(command)
    return hl.dsp.exec_cmd(command)
end

-- Windows -----------------------------------------------------------------
bind(SUPER .. "SHIFT + Q", "Close window", hl.dsp.window.close())
bind(SUPER .. "SHIFT + space", "Float or tile window", hl.dsp.window.float({ action = "toggle" }))
bind(SUPER .. "P", "Pseudo-tile window", hl.dsp.window.pseudo())
bind(SUPER .. "F", "Fullscreen", hl.dsp.window.fullscreen())
bind(SUPER .. "SHIFT + F", "Fullscreen inside the tile",
    hl.dsp.window.fullscreen_state({ internal = 2, client = 0, action = "toggle" }))
bind(SUPER .. "U", "Focus urgent or last window", exec("hyprctl dispatch focusurgentorlast"))

bind(SUPER .. "H", "Focus left", hl.dsp.focus({ direction = "l" }))
bind(SUPER .. "L", "Focus right", hl.dsp.focus({ direction = "r" }))
bind(SUPER .. "K", "Focus up", hl.dsp.focus({ direction = "u" }))
bind(SUPER .. "J", "Focus down", hl.dsp.focus({ direction = "d" }))

bind(SUPER .. "SHIFT + H", "Move window left", hl.dsp.window.move({ direction = "l" }))
bind(SUPER .. "SHIFT + L", "Move window right", hl.dsp.window.move({ direction = "r" }))
bind(SUPER .. "SHIFT + K", "Move window up", hl.dsp.window.move({ direction = "u" }))
bind(SUPER .. "SHIFT + J", "Move window down", hl.dsp.window.move({ direction = "d" }))

bind(SUPER .. "X", "Group or ungroup windows", hl.dsp.group.toggle())
bind(SUPER .. "CTRL + H", "Previous window in group", hl.dsp.group.prev())
bind(SUPER .. "CTRL + L", "Next window in group", hl.dsp.group.next())

bind(SUPER .. "mouse:272", "Move window", hl.dsp.window.drag(), { mouse = true })
bind(SUPER .. "mouse:273", "Resize window", hl.dsp.window.resize(), { mouse = true })

-- Resize mode: the bar shows RESIZE while it is active.
bind(SUPER .. "SHIFT + R", "Resize mode", hl.dsp.submap("RESIZE"))
hl.define_submap("RESIZE", function()
    local step = 40
    bind("L", "Wider", hl.dsp.window.resize({ x = step, y = 0, relative = true }), { repeating = true })
    bind("H", "Narrower", hl.dsp.window.resize({ x = -step, y = 0, relative = true }), { repeating = true })
    bind("K", "Shorter", hl.dsp.window.resize({ x = 0, y = -step, relative = true }), { repeating = true })
    bind("J", "Taller", hl.dsp.window.resize({ x = 0, y = step, relative = true }), { repeating = true })
    bind("escape", "Leave resize mode", hl.dsp.submap("reset"))
    bind("return", "Leave resize mode", hl.dsp.submap("reset"))
end)

-- Workspaces, in groups of ten (lua/groups.lua) ---------------------------
for slot = 1, groups.size do
    local key = tostring(slot % 10)
    bind(SUPER .. key, "Go to workspace " .. slot .. " of this group", function()
        groups.focus_slot(slot)
    end)
    bind(SUPER .. "SHIFT + " .. key, "Move window to workspace " .. slot .. " of this group", function()
        groups.move_to_slot(slot)
    end)
end

for group = 1, groups.count do
    bind(SUPER .. "CTRL + " .. group, "Switch to workspace group " .. group, function()
        groups.switch_group(group)
    end)
    bind(SUPER .. "CTRL + SHIFT + " .. group, "Send window to workspace group " .. group, function()
        groups.move_to_group(group)
    end)
end

bind(SUPER .. "CTRL + mouse_down", "Next workspace group", function()
    groups.step_group(1)
end)
bind(SUPER .. "CTRL + mouse_up", "Previous workspace group", function()
    groups.step_group(-1)
end)

bind(SUPER .. "Tab", "Next workspace in this group on this monitor", function()
    groups.step(1, true)
end, { repeating = true })
bind(SUPER .. "SHIFT + Tab", "Previous workspace in this group on this monitor", function()
    groups.step(-1, true)
end, { repeating = true })
bind(SUPER .. "mouse_down", "Next workspace in this group", function()
    groups.step(1)
end)
bind(SUPER .. "mouse_up", "Previous workspace in this group", function()
    groups.step(-1)
end)

bind(SUPER .. "C", "Show or hide the pocket scratchpad", hl.dsp.workspace.toggle_special("pocket"))
bind(SUPER .. "SHIFT + C", "Move window to the pocket scratchpad", hl.dsp.window.move({ workspace = "special:pocket" }))
bind(SUPER .. "O", "Show or hide the other scratchpad", hl.dsp.workspace.toggle_special("other"))
bind(SUPER .. "SHIFT + O", "Move window to the other scratchpad", hl.dsp.window.move({ workspace = "special:other" }))
-- code:21 is the = key.
bind(SUPER .. "code:21", "Show or hide the aux scratchpad", hl.dsp.workspace.toggle_special("aux"))
bind(SUPER .. "SHIFT + code:21", "Move window to the aux scratchpad", hl.dsp.window.move({ workspace = "special:aux" }))

-- Touchpad: three fingers sideways move between workspaces of this group
-- (fingers left is the next one, as the content follows them), up and down
-- between groups (up is the next group, sliding in from below).
hl.gesture({ fingers = 3, direction = "left", action = function()
    groups.swipe(1)
end })
hl.gesture({ fingers = 3, direction = "right", action = function()
    groups.swipe(-1)
end })
hl.gesture({ fingers = 3, direction = "up", action = function()
    groups.step_group(1)
end })
hl.gesture({ fingers = 3, direction = "down", action = function()
    groups.step_group(-1)
end })

-- Apps and the launcher ---------------------------------------------------
bind(SUPER .. "return", "Terminal", exec(terminal))
bind(SUPER .. "SHIFT + return", "Terminal in tmux", exec(terminal .. " -e ~/.local/bin/auto_tmux"))
bind(SUPER .. "ALT + return", "Terminal in herdr", exec(terminal .. " -e ~/.local/bin/herdr"))
bind(SUPER .. "E", "Files", exec("nautilus"))
bind(SUPER .. "I", "Browser", exec(default_apps.browser))

bind(SUPER .. "D", "Launcher", exec(launcher))
bind(SUPER .. "V", "Clipboard history", exec(launcher .. " clipboard"))
bind(SUPER .. "SHIFT + E", "Power: lock, sleep, log out, shut down", exec(launcher .. " power"))
bind(SUPER .. "ALT + W", "Wallpapers", exec(launcher .. " wallpapers"))
bind(SUPER .. "ALT + A", "Accent colour", exec(launcher .. " accent"))
bind(SUPER .. "slash", "Key bindings", exec(launcher .. " bindings"))

bind(SUPER .. "N", "Notifications and controls", exec("swaync-client --toggle-panel"))
bind(SUPER .. "SHIFT + B", "Show or hide the bar", exec("qs ipc call bar toggle"))

-- Session -----------------------------------------------------------------
bind(SUPER .. "SHIFT + W", "Lock screen", exec("loginctl lock-session"))
bind(SUPER .. "F12", "Turn displays off", function()
    hl.timer(function()
        hl.dispatch(hl.dsp.dpms({ action = "disable" }))
    end, {
        timeout = 500,
        type = "oneshot",
    })
end)

-- Night light: on a schedule in hyprsunset.conf, by hand here.
bind(SUPER .. "SHIFT + N", "Night light on or off", exec(scripts .. "nightlight toggle"))
bind(SUPER .. "SHIFT + M", "Night light off", exec(scripts .. "nightlight off"))
bind(SUPER .. "up", "Cooler screen", exec("hyprctl hyprsunset temperature +10"), { repeating = true })
bind(SUPER .. "down", "Warmer screen", exec("hyprctl hyprsunset temperature -10"), { repeating = true })

-- Hardware keys. These also work on the lock screen.
bind("XF86MonBrightnessUp", "Brighter", exec("swayosd-client --brightness=raise"), { locked = true, repeating = true })
bind("XF86MonBrightnessDown", "Dimmer", exec("swayosd-client --brightness=lower"), { locked = true, repeating = true })
bind(SUPER .. "XF86MonBrightnessUp", "Full brightness", exec("brightnessctl set 100%"))
bind(SUPER .. "XF86MonBrightnessDown", "Lowest brightness", exec("brightnessctl set 0%"))

bind("XF86AudioRaiseVolume", "Louder", exec("swayosd-client --output-volume raise"), { locked = true, repeating = true })
bind("XF86AudioLowerVolume", "Quieter", exec("swayosd-client --output-volume lower"), { locked = true, repeating = true })
bind("XF86AudioMute", "Mute", exec("swayosd-client --output-volume mute-toggle"), { locked = true })
bind("XF86AudioMicMute", "Mute microphone", exec("swayosd-client --input-volume mute-toggle"), { locked = true })
bind(SUPER .. "CTRL + M", "Mute microphone", exec("swayosd-client --input-volume mute-toggle"), { locked = true })

bind("XF86AudioPlay", "Play or pause", exec("playerctl play-pause"), { locked = true })
bind("XF86AudioPrev", "Previous track", exec("playerctl previous"), { locked = true })
bind("XF86AudioNext", "Next track", exec("playerctl next"), { locked = true })

bind("Caps_Lock", "Show Caps Lock state", exec("sleep 0.1 && swayosd-client --caps-lock"))

-- Screenshots -------------------------------------------------------------
-- All go through scripts/screenshot, which saves to ~/Pictures/Screenshots
-- and copies to the clipboard.
bind(SUPER .. "SHIFT + S", "Screenshot or recording: pick what to capture", exec(launcher .. " screenshot"))
bind(SUPER .. "ALT + R", "Stop the screen recording, or start one", exec(scripts .. "record toggle"))
bind(SUPER .. "SHIFT + D", "Screenshot of this display", exec(scripts .. "screenshot display"))
bind("Print", "Screenshot of this display", exec(scripts .. "screenshot display"))
bind("XF86SelectiveScreenshot", "Screenshot of a region", exec(scripts .. "screenshot region"))
bind(SUPER .. "SHIFT + T", "Copy text or a QR code from a region", exec(scripts .. "screen-text"))
