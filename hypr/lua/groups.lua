-- Workspace groups: sets of ten workspaces, so a new task can start on a clean
-- desktop while the old one waits. Group 1 is workspaces 1-10, group 2 is
-- 11-20, and so on; the group is never stored, it is read from the workspace
-- you are on.
--
--   SUPER + 1-0                 go to that workspace in the current group
--   SUPER + CTRL + 1-9          switch every monitor to that group
--   SUPER + CTRL + SHIFT + 1-9  send the window to that group, and stay
--   SUPER + CTRL + scroll       the next or previous group
--
-- Each monitor keeps its place when the group changes: if the laptop shows
-- the group's 1 and the external its 10, they show 1 and 10 of the new group.
-- The bar (quickshell/Bar.qml) calls these through hyprctl, so it is global
-- as `workspace_groups`.

local monitor_names = require("lua.monitor_names")
local animations = require("lua.animations")

local M = {}

M.size = 10
M.count = 9 -- groups reachable from the keyboard

function M.group_of(id)
    return math.floor((id - 1) / M.size) + 1
end

function M.slot_of(id)
    return (id - 1) % M.size + 1
end

function M.id(group, slot)
    return (group - 1) * M.size + slot
end

-- Numbered workspaces only; special ones (scratchpads) have no group.
local function numbered(workspace)
    if workspace and workspace.id and workspace.id > 0 then
        return workspace
    end
end

function M.current_group()
    local workspace = numbered(hl.get_active_workspace())
    return workspace and M.group_of(workspace.id) or 1
end

local function current_slot(workspace)
    workspace = numbered(workspace)
    return workspace and M.slot_of(workspace.id) or 1
end

function M.focus_slot(slot)
    hl.dispatch(hl.dsp.focus({ workspace = M.id(M.current_group(), slot) }))
end

function M.move_to_slot(slot)
    hl.dispatch(hl.dsp.window.move({ workspace = M.id(M.current_group(), slot) }))
end

-- Counts group switches, so only the latest one puts the sideways slide back.
local switches = 0
-- True while this module moves monitors, so following focus (below) does
-- not answer its own moves.
local moving = false

-- A group change slides vertically; sideways again once it has played.
local function slide_vertically()
    switches = switches + 1
    local this_switch = switches
    animations.workspace_slide("slidevert")
    hl.timer(function()
        if this_switch == switches then
            animations.workspace_slide("slide")
        end
    end, { timeout = animations.workspace_slide_ms + 120, type = "oneshot" })
end

-- Put every monitor not already in `group` on its own slot there, then give
-- the focus back to the monitor that had it.
local function bring_monitors(group)
    local focused = hl.get_active_monitor()
    moving = true
    for _, monitor in ipairs(hl.get_monitors()) do
        local workspace = numbered(monitor.active_workspace)
        if not workspace or M.group_of(workspace.id) ~= group then
            hl.dispatch(hl.dsp.focus({ monitor = monitor.name }))
            hl.dispatch(hl.dsp.focus({ workspace = M.id(group, current_slot(workspace)) }))
        end
    end
    if focused then
        hl.dispatch(hl.dsp.focus({ monitor = focused.name }))
    end
    moving = false
end

-- Some apps ask for the focus as soon as they are hidden; the Claude desktop
-- app does, and Hyprland grants it when the app was just in use. Right after
-- you switch groups, that would take you straight back. So for a moment after
-- a switch, focus pulled into another group is put back instead of followed.
M.hold_ms = 3000
local held -- the group just switched to, while the moment lasts
local holds = 0

local function hold(group)
    holds = holds + 1
    local this_hold = holds
    held = group
    hl.timer(function()
        if this_hold == holds then
            held = nil
        end
    end, { timeout = M.hold_ms, type = "oneshot" })
end

function M.switch_group(group)
    slide_vertically()
    bring_monitors(group)
    hold(group)
end

-- Focus can reach another group without these keys: a notification you
-- click, the launcher's window list, SUPER + U. The other monitors then follow
-- to their own place in that group, so the screens never show two groups.
hl.on("workspace.active", function()
    if moving then
        return
    end
    local workspace = numbered(hl.get_active_workspace())
    if not workspace then
        return
    end
    local group = M.group_of(workspace.id)
    if held and group ~= held then
        bring_monitors(held)
        return
    end
    for _, monitor in ipairs(hl.get_monitors()) do
        local other = numbered(monitor.active_workspace)
        if other and M.group_of(other.id) ~= group then
            slide_vertically()
            bring_monitors(group)
            return
        end
    end
end)

-- The next or previous group. It stops at the first and the last rather than
-- wrapping, so a quick scroll cannot jump from group 1 to group 9.
function M.step_group(direction)
    local group = math.max(1, math.min(M.count, M.current_group() + direction))
    if group ~= M.current_group() then
        M.switch_group(group)
    end
end

function M.move_to_group(group)
    local target = M.id(group, current_slot(hl.get_active_workspace()))
    hl.dispatch(hl.dsp.window.move({ workspace = target, follow = false }))
end

-- The next or previous workspace that exists in the current group, wrapping
-- around; on this monitor only, or on any.
function M.step(direction, this_monitor_only)
    local active = numbered(hl.get_active_workspace())
    if not active then
        return
    end
    local group = M.group_of(active.id)
    local monitor = active.monitor and active.monitor.name
    local ids = {}
    for _, workspace in ipairs(hl.get_workspaces()) do
        local ours = numbered(workspace) and M.group_of(workspace.id) == group
        local here = not this_monitor_only or (workspace.monitor and workspace.monitor.name == monitor)
        if ours and here then
            table.insert(ids, workspace.id)
        end
    end
    table.sort(ids)
    for index, id in ipairs(ids) do
        if id == active.id then
            local next_id = ids[(index - 1 + direction) % #ids + 1]
            hl.dispatch(hl.dsp.focus({ workspace = next_id }))
            return
        end
    end
end

-- A three-finger swipe sideways: the next or previous workspace on this
-- monitor, within the group. It stops at the ends rather than wrapping, like
-- Hyprland's own swipe, and past the last one it opens the group's next empty
-- workspace. Hyprland's swipe knows nothing of groups and walks into the next
-- one, which is why this replaces it.
function M.swipe(direction)
    local active = numbered(hl.get_active_workspace())
    if not active then
        return
    end
    local group = M.group_of(active.id)
    local monitor = active.monitor and active.monitor.name
    local taken = {}
    local target
    for _, workspace in ipairs(hl.get_workspaces()) do
        if numbered(workspace) then
            taken[workspace.id] = true
            local here = workspace.monitor and workspace.monitor.name == monitor
            local ahead = (workspace.id - active.id) * direction > 0
            if here and ahead and M.group_of(workspace.id) == group then
                if not target or math.abs(workspace.id - active.id) < math.abs(target - active.id) then
                    target = workspace.id
                end
            end
        end
    end
    if not target and direction > 0 then
        for slot = M.slot_of(active.id) + 1, M.size do
            if not taken[M.id(group, slot)] then
                target = M.id(group, slot)
                break
            end
        end
    end
    if target then
        hl.dispatch(hl.dsp.focus({ workspace = target }))
    end
end

-- Every group keeps the laptop on its first workspace and the external
-- monitor on its tenth, as group 1 does (workspaces.lua).
for group = 2, M.count do
    hl.workspace_rule({ workspace = tostring(M.id(group, 1)), monitor = monitor_names.laptop })
    hl.workspace_rule({ workspace = tostring(M.id(group, M.size)), monitor = monitor_names.external })
end

workspace_groups = M

return M
