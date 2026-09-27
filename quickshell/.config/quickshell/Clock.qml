import QtQuick

Item {
    width: childrenRect.width
    height: childrenRect.height

    property string time: ""

    Text {
        text: time
        color: "white"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
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
}
