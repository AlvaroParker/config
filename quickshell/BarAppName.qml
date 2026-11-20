// The app on this monitor, by a readable name. Unknown apps show their class.
// On a monitor without the focus it is the window last focused there, as
// Waybar's separate-outputs did.

import QtQuick
import Quickshell.Hyprland

BarText {
    id: root

    required property var monitor // HyprlandMonitor

    // [pattern, name]: the first match wins.
    readonly property var names: [
        [/^com\.mitchellh\.ghostty$/, "Ghostty"],
        [/^dev\.zed\./, "Zed"],
        [/^app\.zen_browser\.zen$|^zen/, "Zen"],
        [/^firefox/, "Firefox"],
        [/^org\.pwmt\.zathura$/, "Zathura"],
        [/^org\.gnome\.Nautilus$/, "Files"],
        [/^org\.gnome\.Settings$/, "Settings"],
        [/^org\.pulseaudio\.pavucontrol$|^pavucontrol$/, "Volume"],
        [/^blueman-manager$|^\.blueman-manager-wrapped$/, "Bluetooth"],
        [/^nm-connection-editor$/, "Network"],
        [/^[Oo]bsidian$|^md\.obsidian\.Obsidian$/, "Obsidian"],
        [/^[Dd]iscord$|^vesktop$/, "Discord"],
        [/^[Cc]ode$|^code-oss$|^code-url-handler$|^com\.microsoft\.VSCode$/, "VS Code"],
        [/^[Ss]potify$/, "Spotify"],
        [/^thunderbird$|^org\.mozilla\.Thunderbird$/, "Thunderbird"],
        [/^google-chrome$/, "Chrome"],
        [/^virt-manager$/, "Virtual machines"],
        [/^[Cc]hat[Gg][Pp][Tt]$|^chatgpt$/, "ChatGPT"],
        [/^com\.anthropic\.Claude$/, "Claude"],
        [/^[Aa]lacritty$/, "Alacritty"]
    ]

    readonly property var workspace: monitor?.activeWorkspace ?? null
    property var lastHere: null // the window last focused on this monitor

    Connections {
        target: Hyprland
        function onActiveToplevelChanged() {
            const toplevel = Hyprland.activeToplevel;
            if (toplevel && toplevel.monitor === root.monitor)
                root.lastHere = toplevel;
        }
    }

    readonly property var toplevel: {
        const windows = workspace?.toplevels?.values ?? [];
        if (windows.length === 0)
            return null;
        const active = Hyprland.activeToplevel;
        if (active && windows.includes(active))
            return active;
        if (lastHere && windows.includes(lastHere))
            return lastHere;
        return windows[0];
    }

    readonly property string appClass: toplevel?.wayland?.appId ?? toplevel?.lastIpcObject?.class ?? ""

    function readable(appClass) {
        for (const [pattern, name] of names)
            if (pattern.test(appClass))
                return name;
        return appClass;
    }

    text: readable(appClass)
    color: Nocturne.text
}
