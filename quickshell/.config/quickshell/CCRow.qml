import QtQuick

// One Control Center row: round on/off button + title/subtitle + chevron.
// Click the round icon -> toggled(); click the text / chevron -> opened().
Item {
    id: row

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false

    signal toggled()
    signal opened()

    height: 56

    // round icon button
    Rectangle {
        id: circle
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        width: 34
        height: 34
        radius: 17
        color: row.active ? "#0A84FF" : Qt.rgba(1, 1, 1, 0.16)

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        Text {
            anchors.centerIn: parent
            text: row.icon
            font.family: Theme.fontFamily
            font.pixelSize: 15
            color: "#ffffff"
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: row.toggled()
        }
    }

    // text + chevron (opens the detail page)
    Item {
        anchors.left: circle.right
        anchors.leftMargin: 6
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.bottomMargin: 4
            radius: 12
            color: textHover.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
        }

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.right: chevron.left
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                width: parent.width
                text: row.title
                font.family: Theme.textFontFamily
                font.weight: Font.DemiBold
                font.pixelSize: 13
                color: "#ffffff"
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: row.subtitle
                font.family: Theme.textFontFamily
                font.weight: Theme.textFontWeight
                font.pixelSize: 11
                color: PickerStyle.placeholderColor
                elide: Text.ElideRight
            }
        }

        Text {
            id: chevron
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: "\uf054"
            font.family: Theme.fontFamily
            font.pixelSize: 11
            color: PickerStyle.placeholderColor
        }

        MouseArea {
            id: textHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.opened()
        }
    }
}
