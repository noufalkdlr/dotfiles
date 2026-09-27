import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

Item {
    id: root

    width: childrenRect.width
    height: childrenRect.height

    property string time: ""

    Text {
        id: label
        text: time
        color: "white"
        font.family: Theme.textFontFamily
        font.weight: Theme.textFontWeight
        font.pixelSize: Theme.fontSize
    }

    MouseArea {
        anchors.fill: label
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

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            time = new Date().toLocaleTimeString(Qt.locale(), "hh:mm:ss")
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
                horizontalCenter: parent.horizontalCenter
                topMargin: 40
            }
            width: 280
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

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: calGrid.locale.standaloneMonthName(calGrid.month) + " " + calGrid.year
                    font.family: Theme.textFontFamily
                    font.weight: Font.DemiBold
                    font.pixelSize: 14
                    color: "#ffffff"
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#333333"
                }

                DayOfWeekRow {
                    width: parent.width
                    locale: calGrid.locale

                    delegate: Text {
                        required property var model
                        text: model.shortName
                        font.family: Theme.textFontFamily
                        font.weight: Theme.textFontWeight
                        font.pixelSize: 11
                        color: "#9a9a9a"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                MonthGrid {
                    id: calGrid
                    width: parent.width
                    month: new Date().getMonth()
                    year: new Date().getFullYear()
                    locale: Qt.locale()

                    delegate: Text {
                        required property var model
                        text: model.day
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        opacity: model.month === calGrid.month ? 1 : 0.3
                        font.family: Theme.textFontFamily
                        font.weight: model.today ? Font.DemiBold : Theme.textFontWeight
                        font.pixelSize: 12
                        color: "#ffffff"

                        Rectangle {
                            visible: model.today
                            anchors.centerIn: parent
                            width: 22
                            height: 22
                            radius: 11
                            color: "#0A84FF"
                            z: -1
                        }
                    }
                }
            }
        }
    }
}
