// The one number on the right, padded so the bar never shifts. Gold at 20%
// and red at 10% while running on battery; hover says how long is left.

import QtQuick
import Quickshell.Services.UPower

BarText {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property bool present: battery !== null && battery.ready && battery.isLaptopBattery
    readonly property int percent: present ? Math.round(battery.percentage * 100) : 0
    readonly property bool charging: present && battery.state === UPowerDeviceState.Charging
    readonly property bool plugged: present && (battery.state === UPowerDeviceState.FullyCharged || battery.state === UPowerDeviceState.PendingCharge)
    readonly property bool discharging: present && !charging && !plugged

    readonly property var icons: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

    function duration(seconds) {
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.round(seconds % 3600 / 60);
        return hours > 0 ? hours + " h " + minutes + " min" : minutes + " min";
    }

    text: !present ? ""
        : (charging ? "󰂄" : plugged ? "󰚥" : icons[Math.min(10, Math.round(percent / 10))])
            + String(percent).padStart(4, " ") + "%"
    color: discharging && percent <= 10 ? Nocturne.red
        : discharging && percent <= 20 ? Nocturne.gold
        : Nocturne.muted
    tooltip: !present ? ""
        : charging && battery.timeToFull > 0 ? duration(battery.timeToFull) + " until full"
        : discharging && battery.timeToEmpty > 0 ? duration(battery.timeToEmpty) + " left"
        : plugged ? "Plugged in"
        : ""
}
