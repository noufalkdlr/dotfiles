import QtQuick
import Quickshell.Io

Item {
    id: root

    property bool connected: false

    width: icon.width
    height: icon.height

    Text {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        text: root.connected ? "\uf1eb" : "\uf6ab"
        font.family: Theme.fontFamily
        font.pixelSize: 14
        color: "#ffffff"
    }

    Process {
        id: checkProc
        command: ["nmcli", "-t", "-f", "STATE", "general"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.connected = this.text.trim() === "connected"
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: checkProc.running = true
    }
}
