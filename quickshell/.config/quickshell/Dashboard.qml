import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: root
    width: 32
    height: 32

    property alias iconText: icon.text
    property string username: ""
    property string hostname: ""
    property string uptime: ""

    Text {
        id: icon
        anchors.centerIn: parent
        text: "\uf303"
        font.family: Theme.fontFamily
        font.pixelSize: 16
        color: "white"
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
                infoProc.running = true
            }
        }
    }

    Process {
        id: infoProc
        command: ["sh", "-c", "whoami; hostname; uptime -p"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n")
                root.username = lines[0] || ""
                root.hostname = lines[1] || ""
                root.uptime = lines[2] || ""
            }
        }
    }

    Process {
        id: lockProc
        command: ["hyprlock"]
    }

    Process {
        id: logoutProc
        command: ["hyprctl", "dispatch", "exit"]
    }

    Process {
        id: rebootProc
        command: ["systemctl", "reboot"]
    }

    Process {
        id: shutdownProc
        command: ["systemctl", "poweroff"]
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
        }
        margins {
            top: 40
            left: 10
        }

        implicitWidth: 220
        implicitHeight: contentCol.implicitHeight + 20

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.6)
            radius: 8
            border.color: "#333333"
            border.width: 1

            Column {
                id: contentCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                // ---- User info ----
                Text {
                    text: root.username + "@" + root.hostname
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    color: "#ffffff"
                }

                Text {
                    text: root.uptime
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: "#8a8a8a"
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#333333"
                }

                // ---- Power actions ----
                Repeater {
                    model: [
                        { label: "Lock", icon: "\uf023", action: lockProc },
                        { label: "Logout", icon: "\uf2f5", action: logoutProc },
                        { label: "Reboot", icon: "\uf2f1", action: rebootProc },
                        { label: "Shutdown", icon: "\uf011", action: shutdownProc }
                    ]

                    delegate: Rectangle {
                        required property var modelData

                        width: contentCol.width
                        height: 32
                        radius: 4
                        color: hoverArea.containsMouse ? "#333333" : "transparent"

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                text: modelData.icon
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                color: "#ffffff"
                            }

                            Text {
                                text: modelData.label
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                color: "#ffffff"
                            }
                        }

                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                popup.visible = false
                                modelData.action.running = true
                            }
                        }
                    }
                }
            }
        }
    }
}
