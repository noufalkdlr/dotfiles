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
            top: 40
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

                delegate: Rectangle {
                    required property var modelData

                    readonly property color urgencyBorder: {
                        if (modelData.urgency === NotificationUrgency.Critical) return "#ff7b63"
                        if (modelData.urgency === NotificationUrgency.Low) return "#242424"
                        return "#3584e4"
                    }

                    width: toastColumn.width
                    height: Math.max(110, contentCol.implicitHeight + 30)
                    color: Qt.rgba(0, 0, 0, 0.6)
                    radius: 12
                    border.color: urgencyBorder
                    border.width: 2

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
                                font.pixelSize: 11
                                color: "#8a8a8a"
                            }

                            Text {
                                anchors.right: parent.right
                                anchors.verticalCenter: appNameText.verticalCenter
                                text: "\uf00d"
                                font.family: Theme.fontFamily
                                font.pixelSize: 11
                                color: "#8a8a8a"

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
                            font.pixelSize: 15
                            font.bold: true
                            color: "#ffffff"
                            wrapMode: Text.WordWrap
                        }

                        Text {
                            visible: modelData.body.length > 0
                            width: parent.width
                            text: modelData.body
                            font.family: Theme.textFontFamily
                            font.pixelSize: 13
                            color: "#ffffff"
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
