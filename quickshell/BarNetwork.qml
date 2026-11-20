// The connection: Wi-Fi bars by signal, a plug for a cable, and "offline" in
// red when there is neither. Hover gives the network and address; a click
// opens the launcher's Wi-Fi section, a right-click NetworkManager's editor.

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

BarText {
    id: root

    readonly property var devices: Networking.devices.values
    readonly property var wifi: devices.find(device => device.type === DeviceType.Wifi && device.connected) ?? null
    readonly property var wired: devices.find(device => device.type === DeviceType.Wired && device.connected) ?? null
    readonly property var network: wifi?.networks.values.find(network => network.connected) ?? null

    // Some backends give 0-100, others 0-1.
    readonly property real strength: {
        const value = network?.signalStrength ?? 0;
        return value > 1 ? value / 100 : value;
    }

    readonly property var icons: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]

    text: !Networking.wifiEnabled && !wired ? "󰤭 off"
        : wired ? "󰈀"
        : wifi ? icons[Math.min(icons.length - 1, Math.floor(strength * icons.length))]
        : "󰤮 offline"
    color: wired || wifi ? Nocturne.muted : Nocturne.red

    // The address is looked up when the tooltip is wanted.
    property string address: ""
    Process {
        id: lookup
        command: ["ip", "-4", "-brief", "address", "show", "dev", (root.wired ?? root.wifi)?.name ?? "lo"]
        stdout: StdioCollector {
            onStreamFinished: root.address = (this.text.trim().split(/\s+/)[2] ?? "").split("/")[0]
        }
    }
    onWifiChanged: lookup.running = true
    onWiredChanged: lookup.running = true
    Component.onCompleted: lookup.running = true

    tooltip: wired ? "Wired · " + wired.name + (address ? "\n" + address : "")
        : network ? network.name + " · " + Math.round(strength * 100) + "%" + (address ? "\n" + address : "")
        : "Offline"

    onClicked: Quickshell.execDetached([Quickshell.env("HOME") + "/.config/rofi/launcher", "wifi"])
    onRightClicked: Quickshell.execDetached(["nm-connection-editor"])
}
