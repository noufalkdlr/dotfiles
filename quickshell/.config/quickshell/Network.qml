import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: root

    property bool connected: false
    property bool wifiEnabled: true
    property string currentSSID: ""
    property var networkList: []
    property bool scanning: false

    width: icon.width
    height: icon.height

    Text {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        text: root.wifiEnabled ? (root.connected ? "\uf1eb" : "\uf6ab") : "\uf6ac"
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
                scanProc.running = true
            }
        }
    }

    // ---- Status check ----
    Process {
        id: checkProc
        command: ["sh", "-c", "nmcli -t -f WIFI radio; nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes'"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n")
                root.wifiEnabled = lines[0] === "enabled"
                if (lines.length > 1 && lines[1]) {
                    root.connected = true
                    root.currentSSID = lines[1].split(":")[1] || ""
                } else {
                    root.connected = false
                    root.currentSSID = ""
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: checkProc.running = true
    }

    // ---- WiFi scan ----
    Process {
        id: scanProc
        command: ["sh", "-c", "nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list --rescan yes"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n").filter(l => l.length > 0)
                const seen = {}
                const list = []
                for (const line of lines) {
                    const parts = line.split(":")
                    const ssid = parts[0]
                    if (!ssid || seen[ssid]) continue
                    seen[ssid] = true
                    list.push({ ssid: ssid, signal: parts[1] || "0", security: parts[2] || "" })
                }
                root.networkList = list
                root.scanning = false
            }
        }

        onRunningChanged: if (running) root.scanning = true
    }

    // ---- Toggle WiFi ----
    Process {
        id: toggleProc
        command: ["nmcli", "radio", "wifi", root.wifiEnabled ? "off" : "on"]
    }

    // ---- Connect ----
    Process {
        id: connectProc
        property string targetSsid: ""
        property string targetPassword: ""
        command: targetPassword.length > 0
            ? ["nmcli", "dev", "wifi", "connect", targetSsid, "password", targetPassword]
            : ["nmcli", "dev", "wifi", "connect", targetSsid]

        stdout: StdioCollector {
            onStreamFinished: {
                checkProc.running = true
                scanProc.running = true
            }
        }
    }

    // ---- Disconnect ----
    Process {
        id: disconnectProc
        command: ["sh", "-c", "nmcli con down id \"" + root.currentSSID + "\""]

        stdout: StdioCollector {
            onStreamFinished: {
                checkProc.running = true
            }
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

        GlassPanel {
            anchors {
                top: parent.top
                right: parent.right
                topMargin: Theme.popupTopMargin
                rightMargin: 10
            }
            width: 280
            height: Math.min(contentCol.implicitHeight + 24, 420)
            transformOrigin: Item.TopRight
            autoShow: false
            shown: popup.visible

            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            Flickable {
                anchors.fill: parent
                anchors.margins: 12
                contentHeight: contentCol.implicitHeight
                clip: true

                Column {
                    id: contentCol
                    width: parent.width
                    spacing: 10

                    // ---- Header: WiFi toggle ----
                    Item {
                        width: parent.width
                        height: wifiSwitch.height

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Wi-Fi"
                            font.family: Theme.textFontFamily
                            font.weight: Font.DemiBold
                            font.pixelSize: 13
                            color: "#ffffff"
                        }

                        Switch {
                            id: wifiSwitch
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            checked: root.wifiEnabled
                            onToggled: toggleProc.running = true

                            indicator: Rectangle {
                                implicitWidth: 36
                                implicitHeight: 20
                                x: wifiSwitch.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 10
                                color: wifiSwitch.checked ? "#0A84FF" : Qt.rgba(1, 1, 1, 0.15)

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }

                                Rectangle {
                                    x: wifiSwitch.checked ? parent.width - width - 2 : 2
                                    y: 2
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: "#ffffff"

                                    Behavior on x {
                                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: PickerStyle.dividerColor
                    }

                    // ---- Current connection ----
                    Item {
                        visible: root.connected
                        width: parent.width
                        height: visible ? connText.height : 0

                        Text {
                            id: connText
                            anchors.left: parent.left
                            text: "Connected: " + root.currentSSID
                            font.family: Theme.textFontFamily
                            font.weight: Theme.textFontWeight
                            font.pixelSize: 12
                            color: "#30D158"
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: connText.verticalCenter
                            text: "Disconnect"
                            font.family: Theme.textFontFamily
                            font.weight: Theme.textFontWeight
                            font.pixelSize: 12
                            color: "#FF453A"

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: disconnectProc.running = true
                            }
                        }
                    }

                    Rectangle {
                        visible: root.connected
                        width: parent.width
                        height: 1
                        color: PickerStyle.dividerColor
                    }

                    // ---- Scan status / list ----
                    Text {
                        text: root.scanning ? "Scanning..." : "Available Networks"
                        font.family: Theme.textFontFamily
                        font.weight: Theme.textFontWeight
                        font.pixelSize: 11
                        color: "#9a9a9a"
                    }

                    Repeater {
                        model: root.networkList

                        delegate: Rectangle {
                            required property var modelData

                            width: contentCol.width
                            height: 30
                            radius: 8
                            color: modelData.ssid === root.currentSSID
                                ? PickerStyle.highlightColor
                                : (hoverArea.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 6

                                Text {
                                    text: modelData.security.length > 0 ? "\uf023" : "\uf09c"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    color: "#ffffff"
                                }

                                Text {
                                    text: modelData.ssid + " (" + modelData.signal + "%)"
                                    font.family: Theme.textFontFamily
                                    font.weight: Theme.textFontWeight
                                    font.pixelSize: 12
                                    color: "#ffffff"
                                    elide: Text.ElideRight
                                    width: contentCol.width - 60
                                }
                            }

                            MouseArea {
                                id: hoverArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    connectProc.targetSsid = modelData.ssid
                                    connectProc.targetPassword = ""
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
