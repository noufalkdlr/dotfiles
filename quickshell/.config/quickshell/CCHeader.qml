import QtQuick
import QtQuick.Controls

// Header of a Control Center detail page: back button, title, optional switch.
Item {
    id: hdr

    property string title: ""
    property bool showSwitch: true
    property bool checked: false

    signal back()
    signal switched()

    height: 30

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Rectangle {
            width: 26
            height: 26
            radius: 13
            color: backHover.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)

            Text {
                anchors.centerIn: parent
                text: "\uf053"
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: "#ffffff"
            }

            MouseArea {
                id: backHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: hdr.back()
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: hdr.title
            font.family: Theme.textFontFamily
            font.weight: Font.DemiBold
            font.pixelSize: 14
            color: "#ffffff"
        }
    }

    Switch {
        id: sw
        visible: hdr.showSwitch
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        checked: hdr.checked
        onToggled: hdr.switched()

        indicator: Rectangle {
            implicitWidth: 36
            implicitHeight: 20
            x: sw.leftPadding
            y: parent.height / 2 - height / 2
            radius: 10
            color: sw.checked ? "#0A84FF" : Qt.rgba(1, 1, 1, 0.15)

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Rectangle {
                x: sw.checked ? parent.width - width - 2 : 2
                y: 2
                width: 16
                height: 16
                radius: 8
                color: "#ffffff"

                Behavior on x {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
            }
        }
    }
}
