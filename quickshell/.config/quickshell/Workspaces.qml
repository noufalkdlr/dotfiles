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
                font.family: Theme.fontFamily
                font.pixelSize: 14
                color: modelData.active ? "#ffffff" : "#333333"
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: 14
                height: 2
                radius: 1
                color: "#ffffff"
                visible: modelData.active
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: modelData.activate()
            }
        }
    }
}
