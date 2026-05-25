local M = {}

local screenshot_dir = (os.getenv("HOME") or "~") .. "/Pictures/Screenshots"

local function sh_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function screenshot_file()
    return screenshot_dir .. "/Screenshot-" .. os.date("%Y-%m-%d_%H:%M:%S") .. ".png"
end

local function notify_command(message, opts)
    opts = opts or {}

    return table.concat({
        "notify-send",
        "-i " .. sh_quote(opts.icon or "dialog-error"),
        "-a " .. sh_quote(opts.app or "grim"),
        "-u " .. sh_quote(opts.urgency or "normal"),
        sh_quote(message),
        "-t " .. tostring(opts.timeout or 2000),
    }, " ")
end

local function notify_error(message)
    hl.exec_cmd(notify_command(message))
end

local function bash(command)
    return "bash -c " .. sh_quote(command)
end

local function run_capture(capture_command, success_message, failure_message, icon)
    local file = screenshot_file()
    local command = bash(table.concat({
        "set -euo pipefail",
        "mkdir -p " .. sh_quote(screenshot_dir),
        capture_command(file),
        notify_command(success_message, { icon = icon or file, app = "wl-copy", timeout = 1000 }),
    }, "\n"))

    hl.exec_cmd(command .. " || " .. notify_command(failure_message))
end

local function option_enabled(opts, name, default)
    if type(opts) == "table" and opts[name] ~= nil then
        return opts[name]
    end

    return default
end

local function freeze_selection()
    return table.concat({
        "freeze_pid=",
        "cleanup_freeze() {",
        '    if [ -n "${freeze_pid:-}" ]; then',
        '        kill "$freeze_pid" 2>/dev/null || true',
        '        wait "$freeze_pid" 2>/dev/null || true',
        "    fi",
        "}",
        "trap cleanup_freeze EXIT INT TERM",
        "if command -v hyprpicker >/dev/null 2>&1; then",
        "    hyprpicker -r -z >/dev/null 2>&1 &",
        "    freeze_pid=$!",
        "    sleep 0.2",
        "fi",
    }, "\n")
end

function M.region(opts)
    local freeze = option_enabled(opts, "freeze", true)

    run_capture(function(file)
        local command = {
            "hyprctl keyword layerrule " .. sh_quote("noanim,selection") .. " >/dev/null 2>&1 || true",
            "geometry=$(slurp)",
            '[ -n "$geometry" ]',
            'grim -g "$geometry" - | tee ' .. sh_quote(file) .. " | wl-copy --type image/png",
        }

        if freeze then
            table.insert(command, 1, freeze_selection())
        end

        return table.concat(command, "\n")
    end, "Screenshot of the region taken", "Could not capture screenshot region")
end

function M.region_without_freeze()
    M.region({ freeze = false })
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
