// The output: a speaker by level, headphones for Bluetooth or a headset,
// faint when muted. Scroll changes it by 5%, a click opens pavucontrol, a
// right-click mutes.

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

BarText {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    // Bluetooth, a headset, or a sound card whose headphone socket is its own
    // output (its name then says Headphones).
    readonly property bool headphones: {
        const properties = sink?.properties ?? {};
        return properties["device.api"] === "bluez5"
            || /head(phone|set)/i.test((properties["device.form-factor"] ?? "") + " " + (sink?.name ?? "") + " " + (sink?.description ?? ""));
    }

    text: !sink ? ""
        : headphones ? (muted ? "󰟎" : "󰋋")
        : muted ? "󰝟"
        : volume < 1 / 3 ? "󰕿" : volume < 2 / 3 ? "󰖀" : "󰕾"
    color: muted ? Nocturne.faint : Nocturne.muted
    tooltip: sink ? (sink.description || sink.name) + " · " + Math.round(volume * 100) + "%" : ""

    onScrolled: steps => {
        if (sink?.audio)
            sink.audio.volume = Math.max(0, Math.min(1, Math.round((volume + steps * 0.05) * 20) / 20));
    }
    onClicked: Quickshell.execDetached(["pavucontrol"])
    onRightClicked: Quickshell.execDetached(["swayosd-client", "--output-volume", "mute-toggle"])
}
