import QtQuick
import Quickshell
import Quickshell.Wayland

// macOS-style Control Center: one bar icon, one glass panel.
// Main page: Wi-Fi / Bluetooth rows + Sound slider.
// Click a round icon to toggle; click the text or chevron to open the detail page.
Item {
    id: root

    property string page: "main"   // "main" | "wifi" | "bluetooth" | "sound"

    readonly property real pageHeight: page === "wifi" ? wifiPage.implicitHeight
        : page === "bluetooth" ? btPage.implicitHeight
        : page === "sound" ? soundPage.implicitHeight
        : mainPage.implicitHeight

    width: icon.width
    height: icon.height

    function openPage(p) {
        root.page = p
        if (p === "wifi") NetworkState.scan()
        if (p === "bluetooth") BluetoothState.loadDevices()
    }

    Text {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        text: "\uf1de"
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
                root.page = "main"
                BluetoothState.loadDevices()
                popup.visible = true
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
            width: 330
            height: Math.min(root.pageHeight + 28, 480)
            transformOrigin: Item.TopRight
            autoShow: false
            shown: popup.visible

            Behavior on height {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            Item {
                anchors.fill: parent
                anchors.margins: 14
                clip: true

                // ================= MAIN PAGE =================
                Column {
                    id: mainPage
                    visible: root.page === "main"
                    width: parent.width
                    spacing: 10

                    // ---- Connectivity card ----
                    Rectangle {
                        width: parent.width
                        height: 113
                        radius: PickerStyle.cardRadius
                        color: PickerStyle.cardColor

                        Column {
                            anchors.fill: parent

                            CCRow {
                                width: parent.width
                                icon: NetworkState.wifiEnabled ? "\uf1eb" : "\uf6ac"
                                title: "Wi-Fi"
                                subtitle: !NetworkState.wifiEnabled ? "Off"
                                    : (NetworkState.connected ? NetworkState.currentSSID : "Not Connected")
                                active: NetworkState.wifiEnabled
                                onToggled: NetworkState.toggleWifi()
                                onOpened: root.openPage("wifi")
                            }

                            Rectangle {
                                x: 58
                                width: parent.width - 58 - 14
                                height: 1
                                color: PickerStyle.dividerColor
                            }

                            CCRow {
                                width: parent.width
                                icon: "\uf293"
                                title: "Bluetooth"
                                subtitle: !BluetoothState.powered ? "Off"
                                    : (BluetoothState.connectedName !== "" ? BluetoothState.connectedName : "On")
                                active: BluetoothState.powered
                                onToggled: BluetoothState.togglePower()
                                onOpened: root.openPage("bluetooth")
                            }
                        }
                    }

                    // ---- Sound card ----
                    Rectangle {
                        width: parent.width
                        height: 84
                        radius: PickerStyle.cardRadius
                        color: PickerStyle.cardColor

                        Text {
                            x: 14
                            y: 10
                            text: "Sound"
                            font.family: Theme.textFontFamily
                            font.weight: Font.DemiBold
                            font.pixelSize: 13
                            color: "#ffffff"
                        }

                        // current output -> opens the output list
                        Item {
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            y: 6
                            height: 22
                            width: outRow.implicitWidth + 14

                            Rectangle {
                                anchors.fill: parent
                                radius: 11
                                color: outHover.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : "transparent"
                            }

                            Row {
                                id: outRow
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: Math.min(implicitWidth, 160)
                                    text: AudioState.outputName
                                    font.family: Theme.textFontFamily
                                    font.weight: Theme.textFontWeight
                                    font.pixelSize: 11
                                    color: PickerStyle.placeholderColor
                                    elide: Text.ElideRight
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "\uf054"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    color: PickerStyle.placeholderColor
                                }
                            }

                            MouseArea {
                                id: outHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.openPage("sound")
                            }
                        }

                        // capsule volume slider (speaker icon = mute toggle)
                        Item {
                            x: 14
                            y: 44
                            width: parent.width - 28
                            height: 28

                            Rectangle {
                                anchors.fill: parent
                                radius: height / 2
                                color: Qt.rgba(1, 1, 1, 0.16)
                            }

                            Rectangle {
                                width: Math.max(parent.height, parent.width * (AudioState.muted ? 0 : AudioState.volumeLevel))
                                height: parent.height
                                radius: height / 2
                                color: AudioState.muted ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(1, 1, 1, 0.92)
                            }

                            Text {
                                width: parent.height
                                height: parent.height
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: AudioState.icon
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                color: "#3a3a3c"
                            }

                            MouseArea {
                                id: volMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                property bool dragging: false

                                function apply(mx) {
                                    AudioState.setVolume(Math.max(0, Math.min(1, mx / width)))
                                }

                                onPressed: (mouse) => {
                                    if (mouse.x < height) {
                                        AudioState.toggleMute()
                                        dragging = false
                                    } else {
                                        dragging = true
                                        apply(mouse.x)
                                    }
                                }
                                onPositionChanged: (mouse) => {
                                    if (dragging) apply(mouse.x)
                                }
                                onReleased: dragging = false
                            }
                        }
                    }
                }

                // ================= DETAIL PAGES =================
                WifiPage {
                    id: wifiPage
                    anchors.fill: parent
                    visible: root.page === "wifi"
                    onBack: root.page = "main"
                }

                BluetoothPage {
                    id: btPage
                    anchors.fill: parent
                    visible: root.page === "bluetooth"
                    onBack: root.page = "main"
                }

                SoundPage {
                    id: soundPage
                    anchors.fill: parent
                    visible: root.page === "sound"
                    onBack: root.page = "main"
                }
            }
        }
    }
}
