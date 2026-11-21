// The moving wallpaper: the Nocturne picture with drifting mist, twinkling
// stars and glints on the lake (shaders/wallpaper.frag). It sits on the
// background layer, over hyprpaper's still copy of the same picture, which
// shows again whenever this is unloaded (on battery; shell.qml decides).
//
// It moves only while its screen shows an empty workspace. Behind windows it
// holds still: nobody sees it there, and a moving wallpaper would make
// Hyprland blur it again for every frame under every glass window.

import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: root

    required property var modelData
    required property var settings  // live.json, written by nocturne/wallpaper
    required property int painted   // changes when the picture is painted again

    screen: modelData
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "nocturne-live"
    exclusionMode: ExclusionMode.Ignore
    focusable: false
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    mask: Region {} // clicks go through to the desktop

    readonly property var workspace: Hyprland.monitorFor(modelData)?.activeWorkspace ?? null
    readonly property bool empty: workspace !== null && workspace.toplevels.values.length === 0

    // Seconds of motion so far; it only advances while moving, so the picture
    // picks up where it stopped.
    property real time: 0

    Timer {
        interval: 40 // 25 frames a second: everything here is slow
        repeat: true
        running: root.empty && frame.ready
        onTriggered: root.time += interval / 1000
    }

    // Cover the screen as hyprpaper does: fill it, crop the overflow, centred.
    Item {
        id: frame

        readonly property real aspect: root.settings.aspect
        readonly property bool ready: picture.status === Image.Ready && motion.status === Image.Ready
            && lake.status === Image.Ready

        anchors.centerIn: parent
        width: Math.max(root.width, root.height * aspect)
        height: width / aspect

        // Fades in from the still picture, so loading it never jumps.
        opacity: ready ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 600 }
        }

        Image {
            id: picture
            visible: false
            asynchronous: true
            cache: false
            source: "file://" + root.settings.image + "?" + root.painted
            sourceSize: Qt.size(Math.ceil(frame.width * Screen.devicePixelRatio), Math.ceil(frame.height * Screen.devicePixelRatio))
        }

        Image {
            id: motion
            visible: false
            asynchronous: true
            cache: false
            source: "file://" + root.settings.dir + "/motion.png?" + root.painted
        }

        Image {
            id: lake
            visible: false
            asynchronous: true
            cache: false
            source: "file://" + root.settings.dir + "/lake.png?" + root.painted
        }

        ShaderEffect {
            anchors.fill: parent
            visible: frame.ready

            property var picture: picture
            property var motion: motion
            property var lake: lake
            property real time: root.time
            property real aspect: frame.aspect
            property real wind: 1
            property real strength: 1
            property vector4d mistColor: Qt.vector4d(root.settings.mist[0], root.settings.mist[1], root.settings.mist[2], root.settings.scales.mist)
            property vector4d starColor: Qt.vector4d(root.settings.stars[0], root.settings.stars[1], root.settings.stars[2], root.settings.scales.stars)
            property vector4d glowColor: Qt.vector4d(root.settings.glow[0], root.settings.glow[1], root.settings.glow[2], root.settings.scales.glints)
            property vector4d scales: Qt.vector4d(root.settings.scales.sparkle, root.settings.scales.glow ?? 0, 0, 0)

            // Qt keeps a compiled shader for as long as Quickshell runs, keyed
            // by its path; raise the number after recompiling, so a reload
            // picks the new one up.
            fragmentShader: "shaders/wallpaper.frag.qsb?5"
        }
    }
}
