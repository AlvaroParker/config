// A quiet text button for the corners: Sleep, Restart, Shut down, and the
// session. Hover and press lighten the fill; the keyboard focus draws one
// hairline in the accent. Tab reaches it, Enter or Space presses it.

import QtQuick

Rectangle {
    id: root

    required property real u
    required property real hairline
    required property int fast
    required property var curve
    required property string label
    // A faint word before the label, saying what the label is.
    property string hint: ""
    property color textColor: Nocturne.text
    property string description: label

    signal activated

    implicitWidth: row.implicitWidth + 24 * u
    implicitHeight: 32 * u
    radius: 6 * u
    color: mouse.pressed ? Qt.alpha(Nocturne.ink3, 0.9) : mouse.containsMouse ? Qt.alpha(Nocturne.ink3, 0.6) : Qt.alpha(Nocturne.ink3, 0)
    border.width: activeFocus ? hairline : 0
    border.color: Nocturne.accent

    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: description
    Accessible.onPressAction: activated()
    Keys.onReturnPressed: activated()
    Keys.onEnterPressed: activated()
    Keys.onSpacePressed: activated()

    Behavior on color {
        ColorAnimation {
            duration: root.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.curve
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6 * root.u

        Text {
            visible: root.hint !== ""
            text: root.hint
            color: Nocturne.muted
            font.family: "IBM Plex Sans"
            font.pixelSize: 13 * root.u
        }

        Text {
            text: root.label
            color: root.textColor
            font.family: "IBM Plex Sans"
            font.pixelSize: 13 * root.u

            Behavior on color {
                ColorAnimation {
                    duration: root.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.curve
                }
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
