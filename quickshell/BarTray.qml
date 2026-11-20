// Tray icons at 15 px, 10 px apart. Passive items stay hidden, as on Waybar.
// A click activates the item (or opens its menu, if that is all it has); a
// right-click opens the menu; scrolling is passed on.

import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

Row {
    id: root

    required property var window // the bar, for placing menus

    spacing: 10
    leftPadding: visible ? 7 : 0
    rightPadding: visible ? 7 : 0
    visible: items.length > 0

    readonly property var items: SystemTray.items.values.filter(item => item.status !== Status.Passive)

    Repeater {
        model: root.items

        Item {
            id: slot

            required property var modelData

            implicitWidth: 15
            implicitHeight: 32

            IconImage {
                anchors.centerIn: parent
                implicitSize: 15
                source: slot.modelData.icon
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                function openMenu() {
                    const point = slot.mapToItem(null, 0, slot.height + 6);
                    slot.modelData.display(root.window, point.x, point.y);
                }

                onClicked: event => {
                    if (event.button === Qt.RightButton || (event.button === Qt.LeftButton && slot.modelData.onlyMenu))
                        openMenu();
                    else if (event.button === Qt.MiddleButton)
                        slot.modelData.secondaryActivate();
                    else
                        slot.modelData.activate();
                }
                onWheel: event => slot.modelData.scroll(event.angleDelta.y, false)
            }

            BarTooltip {
                target: slot
                text: slot.modelData.tooltipTitle || slot.modelData.title || ""
                hovered: mouse.containsMouse
            }
        }
    }
}
