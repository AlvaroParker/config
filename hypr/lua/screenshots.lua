local M = {}

local screenshot_dir = (os.getenv("HOME") or "~") .. "/Pictures/Screenshots"

local function sh_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function screenshot_file()
    return screenshot_dir .. "/Screenshot-" .. os.date("%Y-%m-%d_%H:%M:%S") .. ".png"
end

local function notify_error(message)
    hl.exec_cmd(
        "notify-send -i dialog-error -a grim -u normal "
            .. sh_quote(message)
            .. " -t 2000"
    )
end

local function run_capture(capture_command, success_message, failure_message, icon)
    local file = screenshot_file()
    local command = table.concat({
        "mkdir -p " .. sh_quote(screenshot_dir),
        capture_command(file),
        "notify-send -i " .. sh_quote(icon or file) .. " -a wl-copy -u normal " .. sh_quote(success_message) .. " -t 1000",
    }, " && ")

    hl.exec_cmd(command .. " || notify-send -i dialog-error -a grim -u normal " .. sh_quote(failure_message) .. " -t 2000")
end

function M.region()
    run_capture(function(file)
        return "grim -g \"$(slurp)\" - | tee " .. sh_quote(file) .. " | wl-copy --type image/png"
    end, "Screenshot of the region taken", "Could not capture screenshot region")
end

function M.current_monitor()
    local monitor = hl.get_monitor_at_cursor()

    if not monitor then
        notify_error("Could not find a Hyprland monitor under the cursor")
        return
    end

    run_capture(function(file)
        return "grim -o " .. sh_quote(monitor.name) .. " - | tee " .. sh_quote(file) .. " | wl-copy --type image/png"
    end, "Screenshot of " .. monitor.name .. " taken", "Could not capture screenshot on " .. monitor.name)
end

return M
