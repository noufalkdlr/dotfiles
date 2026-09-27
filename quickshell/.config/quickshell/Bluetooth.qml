import QtQuick
import Quickshell.Io

Item {
    id: root

    property bool powered: false

    width: icon.width
    height: icon.height

    Text {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        text: root.powered ? "\uf293" : "\uf294"
        font.family: Theme.fontFamily
        font.pixelSize: 14
        color: "#ffffff"
    }

    Process {
        id: checkProc
        command: ["bluetoothctl", "show"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.powered = this.text.includes("Powered: yes")
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
