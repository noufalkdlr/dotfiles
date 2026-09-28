import QtQuick
import QtQuick.Controls
import Quickshell.Services.Pipewire

// Control Center detail page: Sound (output devices + microphone)
Item {
    id: page

    signal back()

    implicitHeight: header.height + 10 + listCol.implicitHeight

    CCHeader {
        id: header
        width: parent.width
        title: "Sound"
        showSwitch: false
        onBack: page.back()
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

            // ================= OUTPUT =================
            Text {
                text: "Output Devices"
                font.family: Theme.textFontFamily
                font.weight: Theme.textFontWeight
                font.pixelSize: 11
                color: "#9a9a9a"
            }

            Repeater {
                model: AudioState.outputs

                delegate: Rectangle {
                    required property PwNode modelData

                    width: listCol.width
                    height: 30
                    radius: 8
                    color: modelData.id === AudioState.sink?.id
                        ? PickerStyle.highlightColor
                        : (outHover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.description || modelData.name
                        font.family: Theme.textFontFamily
                        font.weight: Theme.textFontWeight
                        font.pixelSize: 12
                        color: "#ffffff"
                        elide: Text.ElideRight
                        width: parent.width - 16
                    }

                    MouseArea {
                        id: outHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: AudioState.selectOutput(modelData)
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: PickerStyle.dividerColor
            }

            // ================= INPUT (MICROPHONE) =================
            Text {
                text: "Input"
                font.family: Theme.textFontFamily
                font.weight: Theme.textFontWeight
                font.pixelSize: 11
                color: "#9a9a9a"
            }

            // input volume (microphone icon = mute toggle)
            CCSlider {
                width: parent.width
                value: AudioState.inputLevel
                muted: AudioState.inputMuted
                icon: AudioState.inputIcon
                onMoved: (v) => AudioState.setInputVolume(v)
                onIconClicked: AudioState.toggleInputMute()
            }

            Text {
                text: "Input Devices"
                font.family: Theme.textFontFamily
                font.weight: Theme.textFontWeight
                font.pixelSize: 11
                color: "#9a9a9a"
            }

            Repeater {
                model: AudioState.inputs

                delegate: Rectangle {
                    required property PwNode modelData

                    width: listCol.width
                    height: 30
                    radius: 8
                    color: modelData.id === AudioState.source?.id
                        ? PickerStyle.highlightColor
                        : (inHover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.description || modelData.name
                        font.family: Theme.textFontFamily
                        font.weight: Theme.textFontWeight
                        font.pixelSize: 12
                        color: "#ffffff"
                        elide: Text.ElideRight
                        width: parent.width - 16
                    }

                    MouseArea {
                        id: inHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: AudioState.selectInput(modelData)
                    }
                }
            }
        }
    }
}
