import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Item {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volumeLevel: (sink?.audio?.volumes.length ?? 0) > 0 ? sink.audio.volumes[0] : 0

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    width: icon.width
    height: icon.height

    Text {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        text: {
            if (root.muted || root.volumeLevel === 0) return "\uf6a9"
            if (root.volumeLevel < 0.5) return "\uf027"
            return "\uf028"
        }
        font.family: Theme.fontFamily
        font.pixelSize: 14
        color: "#ffffff"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: popup.visible = !popup.visible
    }

    PopupWindow {
        id: popup
        anchor.window: root.QsWindow.window
        anchor.rect.x: root.mapToItem(null, 0, 0).x - 60
        anchor.rect.y: root.mapToItem(null, 0, 0).y + 30

        implicitWidth: 160
        implicitHeight: 60
        visible: false
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "#1a1a1a"
            radius: 8
            border.color: "#333333"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: root.muted ? "Muted" : Math.round(root.volumeLevel * 100) + "%"
                font.family: Theme.fontFamily
                font.pixelSize: 14
                color: "#ffffff"
            }
        }
    }
}
