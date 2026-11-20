// The time, with the date softer before it. Hover shows the month, today in
// bold and underlined; a click opens the notifications and controls.

import QtQuick
import Quickshell

BarText {
    id: root

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // Rich text so the date can be dimmer than the time, as on Waybar.
    tooltipRich: true
    text: ""
    color: Nocturne.bright

    // BarText draws plain text; the two-tone label is drawn here instead.
    implicitWidth: label.implicitWidth + 14
    visible: true

    Text {
        id: label
        anchors.centerIn: parent
        textFormat: Text.StyledText
        text: "<font color='" + Qt.alpha(Nocturne.bright, 0.68) + "'>" + Qt.formatDateTime(clock.date, "ddd dd MMM") + "</font>&nbsp;&nbsp;" + Qt.formatDateTime(clock.date, "HH:mm")
        color: Nocturne.bright
        font.family: "Lilex Nerd Font"
        font.pixelSize: 13
        font.weight: Font.Medium
    }

    // A month calendar, Monday first, in the bar's monospace font.
    function calendar(date) {
        const year = date.getFullYear();
        const month = date.getMonth();
        const today = date.getDate();
        const days = new Date(year, month + 1, 0).getDate();
        const offset = (new Date(year, month, 1).getDay() + 6) % 7;
        const title = Qt.formatDate(date, "MMMM yyyy");
        const width = 20;
        const pad = Math.max(0, Math.floor((width - title.length) / 2));
        const lines = ["&nbsp;".repeat(pad) + title, "Mo Tu We Th Fr Sa Su"];
        let cells = [];
        for (let i = 0; i < offset; i++)
            cells.push("&nbsp;&nbsp;");
        for (let day = 1; day <= days; day++) {
            const text = (day < 10 ? "&nbsp;" : "") + day;
            cells.push(day === today ? "<b><u>" + text + "</u></b>" : text);
            if (cells.length === 7) {
                lines.push(cells.join("&nbsp;"));
                cells = [];
            }
        }
        if (cells.length > 0)
            lines.push(cells.join("&nbsp;"));
        return "<tt>" + lines.join("<br>") + "</tt>";
    }

    tooltip: calendar(clock.date)
    onClicked: Quickshell.execDetached(["swaync-client", "--toggle-panel", "--skip-wait"])
}
