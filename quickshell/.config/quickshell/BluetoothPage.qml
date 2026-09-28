import QtQuick
import QtQuick.Controls

// Control Center detail page: Bluetooth
Item {
    id: page

    signal back()

    // battery glyph for a percentage (Nerd Font / Font Awesome battery-full ... battery-empty)
    function batteryIcon(p) {
        if (p > 87) return "\uf240"
        if (p > 62) return "\uf241"
        if (p > 37) return "\uf242"
        if (p > 12) return "\uf243"
        return "\uf244"
    }

    implicitHeight: header.height + 10 + listCol.implicitHeight

    CCHeader {
        id: header
        width: parent.width
        title: "Bluetooth"
        checked: BluetoothState.powered
        onBack: page.back()
        onSwitched: BluetoothState.togglePower()
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

            // ---- Device list ----
            Text {
                text: BluetoothState.scanning ? "Loading..." : "Devices"
                font.family: Theme.textFontFamily
                font.weight: Theme.textFontWeight
                font.pixelSize: 11
                color: "#9a9a9a"
            }

            Repeater {
                model: BluetoothState.deviceList

                delegate: Rectangle {
                    required property var modelData

                    // only connected devices that report a battery level show it
                    readonly property bool hasBattery: modelData.connected && modelData.battery >= 0

                    width: listCol.width
                    height: 30
                    radius: 8
                    color: modelData.connected
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
                                text: modelData.connected ? "\uf293" : "\uf294"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                color: "#ffffff"
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.name
                            font.family: Theme.textFontFamily
                            font.weight: Theme.textFontWeight
                            font.pixelSize: 12
                            color: "#ffffff"
                            elide: Text.ElideRight
                            width: listCol.width - 60 - (hasBattery ? 52 : 0)
                        }
                    }

                    // battery level on the right
                    Row {
                        visible: hasBattery
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: page.batteryIcon(modelData.battery)
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            color: modelData.battery <= 15 ? "#FF453A" : PickerStyle.placeholderColor
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.battery + "%"
                            font.family: Theme.textFontFamily
                            font.weight: Theme.textFontWeight
                            font.pixelSize: 11
                            color: modelData.battery <= 15 ? "#FF453A" : PickerStyle.placeholderColor
                        }
                    }

                    MouseArea {
                        id: hoverArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: BluetoothState.setConnected(modelData.mac, !modelData.connected)
                    }
                }
            }
        }
    }
}
