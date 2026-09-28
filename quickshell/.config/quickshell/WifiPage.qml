import QtQuick
import QtQuick.Controls

// Control Center detail page: Wi-Fi
Item {
    id: page

    signal back()

    // network whose password box is open (set by clicking a secured, unknown network)
    property string promptSsid: ""

    function isSecured(s) { return s.length > 0 && s !== "--" }

    implicitHeight: header.height + 10 + listCol.implicitHeight

    onVisibleChanged: if (!visible) promptSsid = ""

    CCHeader {
        id: header
        width: parent.width
        title: "Wi-Fi"
        checked: NetworkState.wifiEnabled
        onBack: page.back()
        onSwitched: NetworkState.toggleWifi()
    }

    Flickable {
        anchors.top: header.bottom
        anchors.topMargin: 10
        anchors.bottom: parent.bottom
        width: parent.width
        contentHeight: listCol.implicitHeight
        clip: true

        Column {
            id: listCol
            width: parent.width
            spacing: 10

            Rectangle {
                width: parent.width
                height: 1
                color: PickerStyle.dividerColor
            }

            // ---- Current connection ----
            Item {
                visible: NetworkState.connected
                width: parent.width
                height: visible ? connText.height : 0

                Text {
                    id: connText
                    anchors.left: parent.left
                    text: "Connected: " + NetworkState.currentSSID
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
                        onClicked: NetworkState.disconnectCurrent()
                    }
                }
            }

            Rectangle {
                visible: NetworkState.connected
                width: parent.width
                height: 1
                color: PickerStyle.dividerColor
            }

            // ---- Error from the last connect attempt ----
            Text {
                visible: NetworkState.connectError !== ""
                width: parent.width
                text: NetworkState.connectError
                wrapMode: Text.WordWrap
                font.family: Theme.textFontFamily
                font.weight: Theme.textFontWeight
                font.pixelSize: 11
                color: "#FF453A"
            }

            // ---- Scan / connect status ----
            Text {
                text: NetworkState.connectingSsid !== "" ? "Connecting to " + NetworkState.connectingSsid + "..."
                    : (NetworkState.scanning ? "Scanning..." : "Available Networks")
                font.family: Theme.textFontFamily
                font.weight: Theme.textFontWeight
                font.pixelSize: 11
                color: "#9a9a9a"
            }

            Repeater {
                model: NetworkState.networkList

                delegate: Column {
                    id: entry

                    required property var modelData

                    readonly property bool secured: page.isSecured(modelData.security)
                    readonly property bool prompting: page.promptSsid === modelData.ssid
                        || NetworkState.passwordRequestSsid === modelData.ssid

                    function submit() {
                        const pw = pwField.text
                        if (pw.length === 0) return
                        NetworkState.passwordRequestSsid = ""
                        page.promptSsid = ""
                        NetworkState.connectTo(modelData.ssid, pw)
                    }

                    width: listCol.width
                    spacing: 6

                    Rectangle {
                        width: parent.width
                        height: 30
                        radius: 8
                        color: modelData.ssid === NetworkState.currentSSID
                            ? PickerStyle.highlightColor
                            : (hoverArea.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6

                            // fixed-size icon slot: same width for every row, glyph centred in it
                            Item {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 14
                                height: 16

                                Text {
                                    anchors.centerIn: parent
                                    text: entry.secured ? "\uf023" : "\uf09c"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    color: "#ffffff"
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.ssid + " (" + modelData.signal + "%)"
                                font.family: Theme.textFontFamily
                                font.weight: Theme.textFontWeight
                                font.pixelSize: 12
                                color: "#ffffff"
                                elide: Text.ElideRight
                                width: listCol.width - 60
                            }
                        }

                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.ssid === NetworkState.currentSSID) return
                                if (NetworkState.connectingSsid !== "") return

                                if (entry.secured && !NetworkState.isKnown(modelData.ssid)) {
                                    // new secured network: ask for the password first
                                    page.promptSsid = entry.prompting ? "" : modelData.ssid
                                } else {
                                    NetworkState.connectTo(modelData.ssid, "")
                                }
                            }
                        }
                    }

                    // ---- Password box ----
                    Row {
                        visible: entry.prompting
                        width: parent.width
                        spacing: 6

                        TextField {
                            id: pwField
                            width: parent.width - joinBtn.width - parent.spacing
                            height: 32
                            echoMode: TextInput.Password
                            placeholderText: "Password"
                            leftPadding: 10
                            rightPadding: 10
                            color: PickerStyle.textColor
                            placeholderTextColor: PickerStyle.placeholderColor
                            font.family: PickerStyle.fontFamily
                            font.weight: PickerStyle.fontWeight
                            font.pixelSize: 13

                            background: Rectangle {
                                radius: 8
                                color: PickerStyle.fieldBg
                                border.color: PickerStyle.fieldBorder
                                border.width: 1
                            }

                            onVisibleChanged: {
                                if (visible) forceActiveFocus()
                                else text = ""
                            }
                            onAccepted: entry.submit()
                            Keys.onEscapePressed: {
                                NetworkState.passwordRequestSsid = ""
                                page.promptSsid = ""
                            }
                        }

                        Rectangle {
                            id: joinBtn
                            width: 56
                            height: 32
                            radius: 8
                            color: "#0A84FF"
                            opacity: pwField.text.length > 0 ? 1 : 0.5

                            Text {
                                anchors.centerIn: parent
                                text: "Join"
                                font.family: Theme.textFontFamily
                                font.weight: Font.DemiBold
                                font.pixelSize: 12
                                color: "#ffffff"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: entry.submit()
                            }
                        }
                    }
                }
            }
        }
    }
}
