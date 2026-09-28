import QtQuick

// Small pill button used in Control Center forms. Set `enabled: false` to grey it out.
Rectangle {
    id: btn

    property string text: ""
    property bool primary: false

    signal clicked()

    implicitWidth: 64
    height: 32
    radius: 8
    color: primary ? "#0A84FF" : Qt.rgba(1, 1, 1, area.containsMouse ? 0.22 : 0.14)
    opacity: enabled ? 1 : 0.5

    Text {
        anchors.centerIn: parent
        text: btn.text
        font.family: Theme.textFontFamily
        font.weight: Font.DemiBold
        font.pixelSize: 12
        color: "#ffffff"
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        enabled: btn.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
