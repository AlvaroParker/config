// A tooltip under a bar item: ink-2 with one hairline, as Waybar's was.
// It appears after a short pause on hover and hides as soon as the pointer
// leaves.

import QtQuick
import Quickshell

PopupWindow {
    id: tip

    required property Item target
    property string text: ""
    property bool rich: false
    property bool hovered: false

    anchor.item: target
    anchor.rect.x: target.width / 2
    // Below the bar's bottom edge, with a little room.
    anchor.rect.y: target.height + 6
    anchor.gravity: Edges.Bottom
    anchor.edges: Edges.Top

    visible: shown && text !== ""
    property bool shown: false
    implicitWidth: label.implicitWidth + 12
    implicitHeight: label.implicitHeight + 8
    color: "transparent"

    Timer {
        interval: 400
        running: tip.hovered
        onTriggered: tip.shown = true
    }
    onHoveredChanged: if (!hovered) shown = false

    Rectangle {
        anchors.fill: parent
        color: Nocturne.ink2
        border.color: Nocturne.line
        border.width: 1
        radius: 6

        Text {
            id: label
            anchors.centerIn: parent
            text: tip.text
            textFormat: tip.rich ? Text.RichText : Text.PlainText
            color: Nocturne.text
            font.family: "Lilex Nerd Font"
            font.pixelSize: 13
            font.weight: Font.Medium
        }
    }
}
