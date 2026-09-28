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
                implicitHeight: Theme.barHeight

                Rectangle {
                    anchors.fill: parent
                    color: Theme.barColor

                    // thin bottom hairline
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: Theme.barBorder
                    }

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

                        ControlCenter {
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
