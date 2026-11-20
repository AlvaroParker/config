// One bar item: a word or an icon, 7 px either side, with an optional
// tooltip. Hidden while it has nothing to say.

import QtQuick

Item {
    id: item

    property string text: ""
    property color color: Nocturne.muted
    property string tooltip: ""
    property bool tooltipRich: false

    signal clicked
    signal rightClicked
    signal scrolled(int steps)

    visible: text !== ""
    implicitWidth: visible ? label.implicitWidth + 14 : 0
    implicitHeight: 32

    Text {
        id: label
        anchors.centerIn: parent
        text: item.text
        color: item.color
        font.family: "Lilex Nerd Font"
        font.pixelSize: 13
        font.weight: Font.Medium

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => event.button === Qt.RightButton ? item.rightClicked() : item.clicked()
        onWheel: event => item.scrolled(event.angleDelta.y > 0 ? 1 : -1)
    }

    BarTooltip {
        target: item
        text: item.tooltip
        rich: item.tooltipRich
        hovered: mouse.containsMouse
    }
}
