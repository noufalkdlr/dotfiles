import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: root

    property bool powered: false
    property var deviceList: []
    property bool scanning: false

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

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (popup.visible) {
                popup.visible = false
                PopupManager.closeIfActive(popup)
            } else {
                PopupManager.request(popup)
                popup.visible = true
                listProc.running = true
            }
        }
    }

    // ---- Status check ----
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

    // ---- Device list (paired + nearby) ----
    Process {
        id: listProc
        command: ["sh", "-c", "bluetoothctl devices | while read -r _ mac name; do connected=$(bluetoothctl info \"$mac\" | grep -q 'Connected: yes' && echo yes || echo no); echo \"$mac|$name|$connected\"; done"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n").filter(l => l.length > 0)
                const list = []
                for (const line of lines) {
                    const parts = line.split("|")
                    if (parts.length < 3) continue
                    list.push({ mac: parts[0], name: parts[1], connected: parts[2] === "yes" })
                }
                root.deviceList = list
                root.scanning = false
            }
        }

        onRunningChanged: if (running) root.scanning = true
    }

    // ---- Toggle power ----
    Process {
        id: toggleProc
        command: ["bluetoothctl", "power", root.powered ? "off" : "on"]

        stdout: StdioCollector {
            onStreamFinished: checkProc.running = true
        }
    }

    // ---- Connect / Disconnect ----
    Process {
        id: connectProc
        property string mac: ""
        property bool doConnect: true
        command: ["bluetoothctl", doConnect ? "connect" : "disconnect", mac]

        stdout: StdioCollector {
            onStreamFinished: listProc.running = true
        }
    }

    PanelWindow {
        id: popup
        visible: false
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore

        onVisibleChanged: {
            if (!visible) PopupManager.closeIfActive(popup)
        }

        WlrLayershell.namespace: "quickshell-popup"
        WlrLayershell.layer: WlrLayer.Overlay

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: popup.visible = false
        }

        Rectangle {
            anchors {
                top: parent.top
                right: parent.right
                topMargin: 40
                rightMargin: 10
            }
            width: 260
            height: Math.min(contentCol.implicitHeight + 20, 400)
            color: Qt.rgba(0, 0, 0, 0.6)
            radius: 8
            border.color: "#333333"
            border.width: 1

            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            Flickable {
                anchors.fill: parent
                anchors.margins: 10
                contentHeight: contentCol.implicitHeight
                clip: true

                Column {
                    id: contentCol
                    width: parent.width
                    spacing: 10

                    // ---- Header: Bluetooth toggle ----
                    Item {
                        width: parent.width
                        height: btSwitch.height

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Bluetooth"
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            color: "#ffffff"
                        }

                        Switch {
                            id: btSwitch
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: root.powered
                            onToggled: toggleProc.running = true
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#333333"
                    }

                    // ---- Device list ----
                    Text {
                        text: root.scanning ? "Loading..." : "Devices"
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: "#8a8a8a"
                    }

                    Repeater {
                        model: root.deviceList

                        delegate: Rectangle {
                            required property var modelData

                            width: contentCol.width
                            height: 32
                            radius: 4
                            color: modelData.connected ? "#333333" : "transparent"

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 6

                                Text {
                                    text: modelData.connected ? "\uf293" : "\uf294"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    color: "#ffffff"
                                }

                                Text {
                                    text: modelData.name
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    color: "#ffffff"
                                    elide: Text.ElideRight
                                    width: contentCol.width - 60
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    connectProc.mac = modelData.mac
                                    connectProc.doConnect = !modelData.connected
                                    connectProc.running = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
