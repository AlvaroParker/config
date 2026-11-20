// What every bar shares: readings that are polled or streamed once, not once
// per screen. The bars (Bar.qml) only draw them.
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: state

    // SUPER + SHIFT + B, through `qs ipc call bar toggle`.
    property bool shown: true

    // The active Hyprland submap (a mode, such as RESIZE), or "".
    property string submap: ""

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "submap")
                state.submap = event.data === "reset" ? "" : (event.data ?? "");
        }
    }

    // ---- Keep awake (hypr/scripts/keep-awake) ---------------------------
    property bool keepAwake: false

    Process {
        id: keepAwakeCheck
        command: [Quickshell.env("HOME") + "/.config/hypr/scripts/keep-awake", "status"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: state.keepAwake = this.text.trim() === "true"
        }
    }

    function keepAwakeOff() {
        Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr/scripts/keep-awake", "off"]);
    }

    // ---- Pending updates (scripts/updates), hourly ----------------------
    property string updatesText: ""
    property string updatesTooltip: ""

    Process {
        id: updatesCheck
        command: [Quickshell.shellPath("scripts/updates")]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const line = this.text.trim();
                if (line === "") {
                    state.updatesText = "";
                    state.updatesTooltip = "";
                    return;
                }
                try {
                    const parsed = JSON.parse(line);
                    state.updatesText = parsed.text ?? "";
                    state.updatesTooltip = parsed.tooltip ?? "";
                } catch (e) {
                    state.updatesText = "";
                }
            }
        }
    }

    Timer {
        interval: 60 * 60 * 1000
        running: true
        repeat: true
        onTriggered: updatesCheck.running = true
    }

    // ---- Notifications (swaync), streamed ------------------------------
    // swaync-client prints a line of JSON whenever the count or the
    // do-not-disturb state changes: { text, alt, tooltip, class }.
    property string notificationsAlt: "none"
    property string notificationsTooltip: ""

    Process {
        id: notifications
        command: ["swaync-client", "--subscribe-waybar"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                try {
                    const parsed = JSON.parse(line);
                    state.notificationsAlt = parsed.alt ?? "none";
                    state.notificationsTooltip = parsed.tooltip ?? "";
                } catch (e) {}
            }
        }
        // swaync restarts with its unit; follow it.
        onExited: restartNotifications.start()
    }

    Timer {
        id: restartNotifications
        interval: 2000
        onTriggered: notifications.running = true
    }

    // ---- CPU (/proc/stat), every 5 seconds ------------------------------
    property int cpuUsage: 0
    property var cpuLast: null

    FileView {
        id: stat
        path: "/proc/stat"
        blockLoading: true
    }

    // ---- Memory (/proc/meminfo), every 15 seconds -----------------------
    property int memoryUsage: 0
    property real memoryUsedGiB: 0
    property real memoryTotalGiB: 0

    FileView {
        id: meminfo
        path: "/proc/meminfo"
        blockLoading: true
    }

    function readCpu() {
        stat.reload();
        const fields = stat.text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
        const idle = fields[3] + fields[4];
        const total = fields.reduce((sum, value) => sum + value, 0);
        if (cpuLast !== null && total > cpuLast.total)
            cpuUsage = Math.round(100 * (1 - (idle - cpuLast.idle) / (total - cpuLast.total)));
        cpuLast = { idle: idle, total: total };
    }

    function readMemory() {
        meminfo.reload();
        const values = {};
        for (const line of meminfo.text().split("\n")) {
            const match = line.match(/^(\w+):\s+(\d+)/);
            if (match)
                values[match[1]] = Number(match[2]);
        }
        if (!values.MemTotal)
            return;
        const used = values.MemTotal - values.MemAvailable;
        memoryUsage = Math.round(100 * used / values.MemTotal);
        memoryUsedGiB = used / 1048576;
        memoryTotalGiB = values.MemTotal / 1048576;
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: state.readCpu()
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: state.readMemory()
    }

    // ---- Calls from scripts and key bindings ----------------------------
    IpcHandler {
        target: "bar"

        function toggle(): void {
            state.shown = !state.shown;
        }

        // keep-awake calls this when it changes; anything else may too.
        function refresh(): void {
            keepAwakeCheck.running = true;
            updatesCheck.running = true;
        }
    }
}
