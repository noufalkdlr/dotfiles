import QtQuick
import QtQuick.Controls
import Quickshell
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
        onClicked: popup.visible = !popup.visible
    }

    PopupWindow {
        id: popup
        anchor.item: root
        anchor.rect.x: 10
        anchor.rect.y: root.height + 20
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left

        implicitWidth: 240
        implicitHeight: contentCol.implicitHeight + 20
        visible: false
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "#1a1a1a"
            radius: 8
            border.color: "#333333"
            border.width: 1

            Column {
                id: contentCol
                anchors.fill: parent
                anchors.margins: 10
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
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        color: "#ffffff"
                    }
                }

                // ---- Slider ----
                Slider {
                    id: volSlider
                    width: parent.width
                    from: 0
                    to: 1
                    value: root.volumeLevel

                    onMoved: {
                        if (root.sink?.ready && root.sink?.audio) {
                            root.sink.audio.muted = false
                            root.sink.audio.volume = value
                        }
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
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: "#8a8a8a"
                }

                Repeater {
                    model: Pipewire.nodes.values.filter(n => n.isSink && n.audio && !n.isStream)

                    delegate: Rectangle {
                        required property PwNode modelData

                        width: contentCol.width
                        height: 30
                        radius: 4
                        color: modelData.id === root.sink?.id ? "#333333" : "transparent"

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.description || modelData.name
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            color: "#ffffff"
                            elide: Text.ElideRight
                            width: parent.width - 16
                        }

                        MouseArea {
                            anchors.fill: parent
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
