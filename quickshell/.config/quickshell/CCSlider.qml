import QtQuick

// Capsule slider (macOS Control Center style).
// The icon at the left is a mute button; pressing / dragging anywhere else sets the value.
Item {
    id: s

    property real value: 0          // 0..1
    property bool muted: false
    property string icon: ""

    signal moved(real value)
    signal iconClicked()

    height: 28

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Qt.rgba(1, 1, 1, 0.16)
    }

    // filled part (never narrower than the icon circle)
    Rectangle {
        width: Math.max(parent.height, parent.width * (s.muted ? 0 : s.value))
        height: parent.height
        radius: height / 2
        color: s.muted ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(1, 1, 1, 0.92)
    }

    Text {
        width: parent.height
        height: parent.height
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: s.icon
        font.family: Theme.fontFamily
        font.pixelSize: 13
        color: "#3a3a3c"
    }

    MouseArea {
        id: area
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        property bool dragging: false

        function apply(mx) {
            s.moved(Math.max(0, Math.min(1, mx / width)))
        }

        onPressed: (mouse) => {
            if (mouse.x < height) {
                s.iconClicked()
                dragging = false
            } else {
                dragging = true
                apply(mouse.x)
            }
        }
        onPositionChanged: (mouse) => {
            if (dragging) apply(mouse.x)
        }
        onReleased: dragging = false
    }
}
