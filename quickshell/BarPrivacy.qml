// Gold while an app records the microphone or the screen is shared; hover
// names the apps. Screen sharing goes through Hyprland's portal, whose
// PipeWire streams are named xdph-streaming-*.

import QtQuick
import Quickshell.Services.Pipewire

BarText {
    id: root

    readonly property var recording: Pipewire.nodes.values.filter(node => node.type === PwNodeType.AudioInStream)
    readonly property var sharing: Pipewire.nodes.values.filter(node => (node.name ?? "").startsWith("xdph-streaming"))

    // Properties such as the app's name are only filled in for tracked nodes.
    PwObjectTracker {
        objects: root.recording.concat(root.sharing)
    }

    function appName(node) {
        return node.properties?.["application.name"] || node.description || node.name || "An app";
    }

    text: (sharing.length > 0 ? "󰹑" : "") + (sharing.length > 0 && recording.length > 0 ? "  " : "") + (recording.length > 0 ? "󰍬" : "")
    color: Nocturne.gold
    tooltip: [
        ...sharing.map(node => "Sharing the screen: " + appName(node)),
        ...recording.map(node => "Using the microphone: " + appName(node))
    ].join("\n")
}
