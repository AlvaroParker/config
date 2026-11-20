// The desktop panel: date, a large clock, weather, and now playing.
// It sits on the bottom layer, above the wallpaper and below every window, so
// it shows on empty workspaces only. Text only, left-aligned in the empty sky,
// leaving the moon on the right as the one warm light.

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris

PanelWindow {
    id: panel

    aboveWindows: false
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "nocturne-desktop"
    focusable: false
    color: "transparent"

    anchors {
        top: true
        left: true
    }
    margins {
        top: 128
        left: 72
    }
    implicitWidth: 560
    implicitHeight: 460

    // Only the music controls take clicks; everything else passes through.
    mask: Region {
        item: music.visible ? music : null
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // The player to show: one that is playing, otherwise one that is paused.
    readonly property MprisPlayer player: {
        const players = Mpris.players.values;
        return players.find(p => p.isPlaying)
            ?? players.find(p => p.playbackState === MprisPlaybackState.Paused)
            ?? null;
    }

    function duration(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    Column {
        width: parent.width

        Text {
            text: Qt.formatDateTime(clock.date, "dddd d MMMM").toUpperCase()
            color: Nocturne.muted
            font.family: "Lilex Nerd Font"
            font.weight: Font.Medium
            font.pixelSize: 13
            font.letterSpacing: 2.5
        }

        Text {
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Nocturne.bright
            // The Light face is registered as its own family; asking for
            // "IBM Plex Sans" at weight Light picks the regular face instead.
            font.family: "IBM Plex Sans Light"
            font.pixelSize: 132
            renderType: Text.NativeRendering
            // Pull the light digits up to the date and in to its left edge.
            topPadding: -18
            bottomPadding: -22
            leftPadding: -6
        }

        // Always present, so the music block never jumps when weather arrives.
        // The width matters: a Column skips items that are zero wide, and an
        // empty Text is.
        Text {
            width: parent.width
            height: 30
            text: Weather.summary
            color: Nocturne.muted
            font.family: "IBM Plex Sans"
            font.pixelSize: 17
            verticalAlignment: Text.AlignVCenter
        }

        Item {
            width: 1
            height: 38
        }

        // Now playing: shown only while a player is playing or paused.
        Item {
            id: music
            visible: panel.player !== null && panel.player.trackTitle !== ""
            width: 330
            height: 84

            Text {
                id: icon
                text: panel.player?.isPlaying ? "󰏤" : "󰐊"
                color: Nocturne.muted
                font.family: "Lilex Nerd Font"
                font.pixelSize: 17
                y: 2
            }

            Column {
                x: 30
                width: parent.width - 30
                spacing: 4

                Text {
                    width: parent.width
                    text: panel.player?.trackTitle ?? ""
                    color: Nocturne.text
                    font.family: "IBM Plex Sans"
                    font.weight: Font.Medium
                    font.pixelSize: 17
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: panel.player?.trackArtist ?? ""
                    color: Nocturne.muted
                    font.family: "IBM Plex Sans"
                    font.pixelSize: 15
                    elide: Text.ElideRight
                }

                Item {
                    width: 1
                    height: 6
                }

                // A thin progress line, like the volume sliders.
                Rectangle {
                    visible: panel.player?.lengthSupported ?? false
                    width: 260
                    height: 2
                    radius: 1
                    color: Nocturne.line

                    Rectangle {
                        width: panel.player && panel.player.length > 0
                            ? parent.width * Math.min(1, panel.player.position / panel.player.length) : 0
                        height: parent.height
                        radius: 1
                        color: Nocturne.text
                    }
                }

                Text {
                    visible: panel.player?.lengthSupported ?? false
                    text: panel.player ? panel.duration(panel.player.position) + " / " + panel.duration(panel.player.length) : ""
                    color: Nocturne.faint
                    font.family: "Lilex Nerd Font"
                    font.pixelSize: 12
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (panel.player?.canTogglePlaying)
                        panel.player.togglePlaying();
                }
            }
        }
    }

    // MPRIS does not push position updates, so ask once a second while playing.
    Timer {
        interval: 1000
        repeat: true
        running: panel.player?.isPlaying ?? false
        onTriggered: panel.player.positionChanged()
    }
}
