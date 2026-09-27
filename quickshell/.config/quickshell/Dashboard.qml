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
                left: parent.left
                topMargin: 40
                leftMargin: 10
            }
            width: 240
            height: contentCol.implicitHeight + 16
            color: Qt.rgba(0, 0, 0, 0.6)
            radius: 11
            border.color: "#333333"
            border.width: 1

            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            Column {
                id: contentCol
                anchors.fill: parent
                anchors.margins: 6
                spacing: 2

                // ---- User info header ----
                Column {
                    width: parent.width
                    spacing: 1
                    topPadding: 4
                    bottomPadding: 8
                    leftPadding: 10

                    Text {
                        text: root.username + "@" + root.hostname
                        font.family: Theme.textFontFamily
                        font.weight: Font.DemiBold
                        font.pixelSize: 13
                        color: "#ffffff"
                    }

                    Text {
                        text: root.uptime
                        font.family: Theme.textFontFamily
                        font.pixelSize: 11
                        color: "#9a9a9a"
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#333333"
                }

                Item { width: 1; height: 4 }

                // ---- Power actions ----
                Repeater {
                    model: [
                        { label: "Lock Screen", icon: "\uf023", action: lockProc },
                        { label: "Log Out", icon: "\uf2f5", action: logoutProc },
                        { label: "Restart", icon: "\uf2f1", action: rebootProc },
                        { label: "Shut Down", icon: "\uf011", action: shutdownProc }
                    ]

                    delegate: Rectangle {
                        required property var modelData

                        width: contentCol.width
                        height: 28
                        radius: 6
                        color: hoverArea.containsMouse ? "#0A84FF" : "transparent"

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            Text {
                                text: modelData.icon
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                color: "#ffffff"
                                width: 16
                            }

                            Text {
                                text: modelData.label
                                font.family: Theme.textFontFamily
                                font.pixelSize: 13
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
