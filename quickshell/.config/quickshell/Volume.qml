import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

Item {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volumeLevel: (sink?.audio?.volumes.length ?? 0) > 0 ? sink.audio.volumes[0] : 0

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    width: icon.width
    height: icon.height

    Text {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        text: {
            if (root.muted || root.volumeLevel === 0) return "\uf6a9"
            if (root.volumeLevel < 0.5) return "\uf027"
            return "\uf028"
        }
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

        Rectangle {
            anchors {
                top: parent.top
                right: parent.right
                topMargin: 40
                rightMargin: 10
            }
            width: 260
            height: contentCol.implicitHeight + 24
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
                anchors.margins: 12
                spacing: 10

                // ---- Mute + Percentage ----
                Row {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: root.muted ? "\uf6a9" : "\uf028"
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        color: "#ffffff"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.sink?.ready && root.sink?.audio) {
                                    root.sink.audio.muted = !root.sink.audio.muted
                                }
                            }
                        }
                    }

                    Text {
                        text: root.muted ? "Muted" : Math.round(root.volumeLevel * 100) + "%"
                        font.family: Theme.textFontFamily
                        font.weight: Font.DemiBold
                        font.pixelSize: 13
                        color: "#ffffff"
                    }
                }

                // ---- Slider ----
                Slider {
                    id: volSlider
                    width: parent.width
                    height: 20
                    from: 0
                    to: 1
                    value: root.volumeLevel

                    onMoved: {
                        if (root.sink?.ready && root.sink?.audio) {
                            root.sink.audio.muted = false
                            root.sink.audio.volume = value
                        }
                    }

                    background: Rectangle {
                        x: volSlider.leftPadding
                        y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                        width: volSlider.availableWidth
                        height: 4
                        radius: 2
                        color: Qt.rgba(1, 1, 1, 0.15)

                        Rectangle {
                            width: volSlider.visualPosition * parent.width
                            height: parent.height
                            radius: 2
                            color: "#0A84FF"
                        }
                    }

                    handle: Rectangle {
                        x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                        y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                        width: 14
                        height: 14
                        radius: 7
                        color: "#ffffff"
                        border.color: Qt.rgba(0, 0, 0, 0.2)
                        border.width: 0.5
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#333333"
                }

                // ---- Output Devices ----
                Text {
                    text: "Output Devices"
                    font.family: Theme.textFontFamily
                    font.weight: Theme.textFontWeight
                    font.pixelSize: 11
                    color: "#9a9a9a"
                }

                Repeater {
                    model: Pipewire.nodes.values.filter(n => n.isSink && n.audio && !n.isStream)

                    delegate: Rectangle {
                        required property PwNode modelData

                        width: contentCol.width
                        height: 30
                        radius: 6
                        color: modelData.id === root.sink?.id
                            ? "#0A84FF"
                            : (hoverArea.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent")

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
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Pipewire.preferredDefaultAudioSink = modelData
                            }
                        }
                    }
                }
            }
        }
    }
}
