local M = {}
local timers = {}

local function once(timeout, callback)
    timers[#timers + 1] = hl.timer(callback, {
        timeout = timeout,
        type = "oneshot",
    })
end

function M.restart()
    once(1000, function()
        hl.exec_cmd("killall -e xdg-desktop-portal-hyprland")
        hl.exec_cmd("killall -e xdg-desktop-portal-wlr")
        hl.exec_cmd("killall xdg-desktop-portal")
        hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")

        once(2000, function()
            hl.exec_cmd("/usr/lib/xdg-desktop-portal")
        end)
    end)
end

return M
