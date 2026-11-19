// Nocturne desktop: one panel per screen. Started by hypr/lua/autostart.lua.
// Quickshell reloads this folder on save.

import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens

        Desktop {
            required property var modelData
            screen: modelData
        }
    }
}
