// The workspaces of the current group, as 1-10 (hypr/lua/groups.lua). The
// group is the one this monitor is on. Outside group 1 its number shows first
// in gold: a context you could forget you are in.
//
// The focused workspace is bright and underlined in the accent, on every bar:
// the one warm light marks where you are. Workspaces showing on a monitor are
// in `text`; the rest are faint, and urgent ones red, as on Waybar.

import QtQuick
import Quickshell
import Quickshell.Hyprland

Row {
    id: root

    required property var monitor // HyprlandMonitor
    readonly property int size: 10

    readonly property var active: monitor?.activeWorkspace ?? null
    readonly property int group: active && active.id > 0 ? Math.floor((active.id - 1) / size) + 1 : 1

    readonly property var shown: Hyprland.workspaces.values
        .filter(workspace => workspace.id > 0 && Math.floor((workspace.id - 1) / size) + 1 === group)
        .sort((a, b) => a.id - b.id)

    function dispatch(lua) {
        Quickshell.execDetached(["hyprctl", "dispatch", lua]);
    }

    BarText {
        visible: root.group > 1
        text: "Group " + root.group
        color: Nocturne.gold
    }

    Repeater {
        model: root.shown

        Item {
            id: button

            required property var modelData
            readonly property bool here: modelData === Hyprland.focusedWorkspace
            readonly property bool elsewhere: !here && Hyprland.monitors.values.some(m => m.activeWorkspace === modelData)

            implicitWidth: Math.max(24, label.implicitWidth + 8)
            implicitHeight: 32

            Text {
                id: label
                anchors.centerIn: parent
                text: (button.modelData.id - 1) % root.size + 1
                color: button.modelData.urgent ? Nocturne.red
                    : button.here ? Nocturne.bright
                    : (button.elsewhere || mouse.containsMouse) ? Nocturne.text
                    : Nocturne.faint
                font.family: "Lilex Nerd Font"
                font.pixelSize: 13
                font.weight: Font.Medium

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: 2
                color: button.here ? Nocturne.accent : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.dispatch("hl.dsp.focus({ workspace = " + button.modelData.id + " })")
            }
        }
    }

    // Scrolling steps through this group only, like SUPER + scroll.
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => root.dispatch("function() workspace_groups.step(" + (event.angleDelta.y > 0 ? 1 : -1) + ") end")
    }
}
