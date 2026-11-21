//@ pragma UseQApplication
// Nocturne shell: the bar, the desktop panel and the moving wallpaper, one
// of each per screen. Started by hypr/lua/autostart.lua. Quickshell reloads
// this folder on save.
//
// The pragma above is what lets tray menus open: they are Qt's own menus,
// themed by qt6ct with the Nocturne palette. It only takes effect when
// Quickshell starts, not on a reload.

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

ShellRoot {
    id: shell

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

    // ---- The moving wallpaper ------------------------------------------
    // Shown on AC power while the Nocturne picture is the wallpaper on
    // screen; otherwise hyprpaper's still copy shows. nocturne/wallpaper
    // writes live/ when it paints tonight's moon; hypr/scripts/wallpaper
    // writes `shown` whenever the wallpaper changes.
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/nocturne"
    property var live: null
    property string shown: ""
    property int painted: 0
    readonly property bool liveOn: live !== null && shown === live.image && !UPower.onBattery

    // A FileView only watches a file that exists. At login these files may
    // be written a moment after Quickshell starts, so look again until both
    // have been read.
    Timer {
        interval: 5000
        repeat: true
        running: shell.live === null || shell.shown === ""
        onTriggered: {
            liveFile.reload();
            shownFile.reload();
        }
    }

    FileView {
        id: liveFile
        path: shell.stateDir + "/live/live.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            try {
                const settings = JSON.parse(text());
                settings.dir = shell.stateDir + "/live";
                shell.live = settings;
                shell.painted++;
            } catch (e) {
                shell.live = null;
            }
        }
        onLoadFailed: shell.live = null
    }

    FileView {
        id: shownFile
        path: shell.stateDir + "/shown"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: shell.shown = text().trim()
        onLoadFailed: shell.shown = ""
    }

    Variants {
        model: Quickshell.screens

        LazyLoader {
            id: loader

            required property var modelData
            active: shell.liveOn

            LiveWallpaper {
                modelData: loader.modelData
                settings: shell.live
                painted: shell.painted
            }
        }
    }
}
