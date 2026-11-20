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

function M.switch_group(group)
    local focused = hl.get_active_monitor()
    for _, monitor in ipairs(hl.get_monitors()) do
        local target = M.id(group, current_slot(monitor.active_workspace))
        hl.dispatch(hl.dsp.focus({ monitor = monitor.name }))
        hl.dispatch(hl.dsp.focus({ workspace = target }))
    end
    -- End on the monitor you started on.
    if focused then
        hl.dispatch(hl.dsp.focus({ monitor = focused.name }))
    end
end

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

-- Every group keeps the laptop on its first workspace and the external
-- monitor on its tenth, as group 1 does (workspaces.lua).
for group = 2, M.count do
    hl.workspace_rule({ workspace = tostring(M.id(group, 1)), monitor = monitor_names.laptop })
    hl.workspace_rule({ workspace = tostring(M.id(group, M.size)), monitor = monitor_names.external })
end

workspace_groups = M

return M
