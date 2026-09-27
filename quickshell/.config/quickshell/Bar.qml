import Quickshell
import QtQuick

Scope {
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                required property var modelData
                screen: modelData
                color: "transparent"

                anchors {
                    top: true
                    left: true
                    right: true
                }
                implicitHeight: 30

                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(0, 0, 0, 0.5)

                    // ---- LEFT ----
                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Dashboard {
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Workspaces {
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // ---- CENTER ----
                    Row {
                        anchors.centerIn: parent

                        Clock {}
                    }

                    // ---- RIGHT ----
                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16

                        Network {
                            anchors.verticalCenter: parent.verticalCenter
                          }
                        Bluetooth {
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Volume {
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
