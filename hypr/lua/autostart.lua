local portals = require("lua.portals")

local startup_commands = {
    "swaync",
    "hyprsunset",
    "waybar",
    "blueman-applet",
    "swayosd-server",
    "nm-applet",
    "systemctl --user start hyprpolkitagent",
    "hyprpaper",
    "hyprctl setcursor Bibata-Modern-Classic 20",
    "hypridle",
    "clipse -listen",
}

hl.on("hyprland.start", function()
    for _, command in ipairs(startup_commands) do
        hl.exec_cmd(command)
    end

    portals.restart()
end)
