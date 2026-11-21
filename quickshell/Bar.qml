// The Nocturne bar: where you are on the left, the time in the middle, how
// the machine is on the right. Normal readings stay hidden and appear when
// something needs you: high CPU or memory, a live microphone, low battery.
// A floating island, 8 px from the screen edges like the windows below it
// (DESIGN.md). Shared readings live in BarState.qml.

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    readonly property var monitor: Hyprland.monitorFor(screen)

    WlrLayershell.namespace: "nocturne-bar"
    WlrLayershell.layer: WlrLayer.Top
    visible: BarState.shown
    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: 8
        left: 8
        right: 8
    }
    implicitHeight: 34

    Rectangle {
        anchors.fill: parent
        color: Nocturne.ink0
        border.color: Nocturne.ink2
        border.width: 1
        radius: 12

        // Where you are.
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter

            BarWorkspaces {
                monitor: bar.monitor
            }

            // A mode is a state you are in, so it is the one filled shape on
            // the bar.
            Item {
                visible: BarState.submap !== ""
                implicitWidth: visible ? submapPill.width + 6 : 0
                implicitHeight: 32

                Rectangle {
                    id: submapPill
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: submapLabel.implicitWidth + 14
                    height: 22
                    radius: 3
                    color: Nocturne.gold

                    Text {
                        id: submapLabel
                        anchors.centerIn: parent
                        text: BarState.submap
                        color: Nocturne.ink0
                        font.family: "Lilex Nerd Font"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                }
            }

            BarAppName {
                monitor: bar.monitor
            }
        }

        // The time.
        BarClock {
            anchors.centerIn: parent
        }

        // How the machine is.
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter

            // A recording is a mode you can forget is on, so gold.
            BarText {
                text: BarState.recording ? "󰑊" : ""
                color: Nocturne.gold
                tooltip: "Recording the screen. Click to stop."
                onClicked: BarState.stopRecording()
            }

            BarPrivacy {}

            BarText {
                text: BarState.keepAwake ? "󰅶" : ""
                color: Nocturne.gold
                tooltip: "Keep awake is on: the screen will not dim, lock or sleep. Click to turn it off."
                onClicked: BarState.keepAwakeOff()
            }

            // Hidden below 85%.
            BarText {
                text: BarState.cpuUsage >= 85 ? "󰍛 " + BarState.cpuUsage + "%" : ""
                color: Nocturne.gold
            }

            BarText {
                text: BarState.memoryUsage >= 85 ? "󰘚 " + BarState.memoryUsage + "%" : ""
                color: Nocturne.gold
                tooltip: BarState.memoryUsedGiB.toFixed(1) + " of " + BarState.memoryTotalGiB.toFixed(1) + " GiB in use"
            }

            BarText {
                text: BarState.updatesText
                tooltip: BarState.updatesTooltip
            }

            // A bell when notifications are waiting, a crossed bell in
            // do-not-disturb.
            BarText {
                readonly property string alt: BarState.notificationsAlt
                text: alt.startsWith("dnd") ? "󰂛" : alt.endsWith("notification") ? "󰂚" : ""
                color: alt.startsWith("dnd") ? Nocturne.faint : Nocturne.muted
                tooltip: BarState.notificationsTooltip
                onClicked: Quickshell.execDetached(["swaync-client", "--toggle-panel", "--skip-wait"])
                onRightClicked: Quickshell.execDetached(["swaync-client", "--toggle-dnd", "--skip-wait"])
            }

            BarTray {
                window: bar
            }

            BarNetwork {}

            BarVolume {}

            BarBattery {}
        }
    }
}
