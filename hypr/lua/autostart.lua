local portals = require("lua.portals")

local scripts = "~/.config/hypr/scripts/"

local startup_commands = {
    -- As its systemd unit, not a bare `swaync`: Waybar's swaync-client makes
    -- D-Bus start swaync.service as well, and the two used to race, leaving
    -- the unit failing at every login.
    "systemctl --user start swaync",
    "hyprsunset", -- schedule in hypr/hyprsunset.conf
    "waybar",
    "qs", -- desktop panel: clock, weather, now playing (quickshell/)
    "blueman-applet",
    "swayosd-server",
    -- No nm-applet: the bar shows the network, and the launcher's Wi-Fi section
    -- connects. Run nm-applet by hand if a VPN or enterprise login needs it.
    "systemctl --user start hyprpolkitagent",
    scripts .. "wallpaper start", -- remembers the last wallpaper, outside the repo
    "hyprctl setcursor Bibata-Modern-Classic 20",
    "hypridle",
    "wl-paste --watch cliphist store",
    scripts .. "battery-notify",
}

hl.on("hyprland.start", function()
    for _, command in ipairs(startup_commands) do
        hl.exec_cmd(command)
    end

    portals.restart()
end)
