import QtQuick
import Quickshell
import Quickshell.Hyprland

Row {
    id: root
    spacing: 4
    height: 22

    Repeater {
        model: Hyprland.workspaces

        delegate: Item {
            required property HyprlandWorkspace modelData

            width: 26
            height: 22

            // capsule highlight: active = brighter, hover = subtle
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: modelData.active
                    ? Qt.rgba(1, 1, 1, 0.20)
                    : (wsHover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")
            }

            Text {
                anchors.centerIn: parent
                text: modelData.id
                font.family: Theme.textFontFamily
                font.weight: Theme.textFontWeight
                font.pixelSize: 14
                color: modelData.active ? "#ffffff" : Qt.rgba(1, 1, 1, 0.55)
            }

            MouseArea {
                id: wsHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: modelData.activate()
            }
        }
    }
}
