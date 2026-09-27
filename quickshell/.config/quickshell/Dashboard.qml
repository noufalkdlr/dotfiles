import QtQuick
import "."

Item {
    id: dashboard
    width: 32
    height: 32

    property alias iconText: icon.text

    Text {
        id: icon
        anchors.centerIn: parent
        text: "\uf303"   // arch linux glyph (nerd font)
        font.family: Theme.fontFamily
        font.pixelSize: 16
        color: "white"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            console.log("dashboard clicked")
            // ഇവിടെ പിന്നീട് menu/popup logic ചേർക്കാം
        }
    }
}
