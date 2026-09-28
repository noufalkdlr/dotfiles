import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

Scope {
    id: root

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        imageSupported: true
        persistenceSupported: false

        onNotification: (notification) => {
            notification.tracked = true
        }
    }

    PanelWindow {
        id: toastWin
        visible: server.trackedNotifications.values.length > 0
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.namespace: "quickshell-popup"
        WlrLayershell.layer: WlrLayer.Overlay

        anchors {
            top: true
            right: true
        }
        margins {
            top: Theme.popupTopMargin
            right: 10
        }

        implicitWidth: 350
        implicitHeight: toastColumn.implicitHeight

        Column {
            id: toastColumn
            width: parent.width
            spacing: 10

            Repeater {
                model: server.trackedNotifications.values

                delegate: GlassPanel {
                    required property var modelData

                    readonly property bool critical: modelData.urgency === NotificationUrgency.Critical

                    width: toastColumn.width
                    height: Math.max(96, contentCol.implicitHeight + 30)
                    radius: 22
                    transformOrigin: Item.TopRight

                    // glass border; only critical notifications get a coloured edge
                    border.color: critical ? "#ff7b63" : PickerStyle.borderColor
                    border.width: critical ? 2 : PickerStyle.borderWidth

                    Timer {
                        running: modelData.expireTimeout > 0 || modelData.urgency !== NotificationUrgency.Critical
                        interval: modelData.expireTimeout > 0 ? modelData.expireTimeout : 5000
                        onTriggered: modelData.dismiss()
                    }

                    Column {
                        id: contentCol
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 6

                        Item {
                            width: parent.width
                            height: appNameText.height

                            Text {
                                id: appNameText
                                anchors.left: parent.left
                                text: modelData.appName || "Notification"
                                font.family: Theme.textFontFamily
                                font.weight: Theme.textFontWeight
                                font.pixelSize: 11
                                color: PickerStyle.placeholderColor
                            }

                            Text {
                                anchors.right: parent.right
                                anchors.verticalCenter: appNameText.verticalCenter
                                text: "\uf00d"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                color: PickerStyle.placeholderColor

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: modelData.dismiss()
                                }
                            }
                        }

                        Text {
                            width: parent.width
                            text: modelData.summary
                            font.family: Theme.textFontFamily
                            font.weight: Theme.textFontWeight
                            font.pixelSize: 15
                            font.bold: true
                            color: PickerStyle.textColor
                            wrapMode: Text.WordWrap
                        }

                        Text {
                            visible: modelData.body.length > 0
                            width: parent.width
                            text: modelData.body
                            font.family: Theme.textFontFamily
                            font.weight: Theme.textFontWeight
                            font.pixelSize: 13
                            color: PickerStyle.textColor
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        z: -1
                        onClicked: modelData.dismiss()
                    }
                }
            }
        }
    }
}
