import QtQuick
import Quickshell
import Quickshell.Hyprland

Row {
    id: root
    spacing: 6
    height: 20

    Repeater {
        model: Hyprland.workspaces

        delegate: Item {
            required property HyprlandWorkspace modelData

            width: 20
            height: 20

            Text {
                anchors.centerIn: parent
                text: modelData.id
                font.family: Theme.textFontFamily
                font.weight: Theme.textFontWeight
                font.pixelSize: 14
                color: modelData.active ? "#ffffff" : "#333333"
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: modelData.activate()
            }
        }
    }
}
