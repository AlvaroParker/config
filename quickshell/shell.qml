//@ pragma UseQApplication
// Nocturne shell: the bar and the desktop panel, one of each per screen.
// Started by hypr/lua/autostart.lua. Quickshell reloads this folder on save.
//
// The pragma above is what lets tray menus open: they are Qt's own menus,
// themed by qt6ct with the Nocturne palette. It only takes effect when
// Quickshell starts, not on a reload.

import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }

    Variants {
        model: Quickshell.screens

        Desktop {
            required property var modelData
            screen: modelData
        }
    }
}
