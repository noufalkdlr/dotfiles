import QtQuick

// Liquid-Glass style panel: translucent fill, thin border, soft top sheen,
// specular line on the top edge, spring-in animation.
// Children declared inside a GlassPanel go into the content area.
Rectangle {
    id: root

    default property alias content: contentItem.data
    property bool shown: false
    property bool autoShow: true   // pickers: animate in on creation; popups: bind `shown` themselves

    color: PickerStyle.windowColor
    radius: PickerStyle.windowRadius
    border.color: PickerStyle.borderColor
    border.width: PickerStyle.borderWidth

    opacity: shown ? 1 : 0
    scale: shown ? 1 : PickerStyle.openStartScale

    Behavior on scale {
        NumberAnimation {
            duration: PickerStyle.openDuration
            easing.type: Easing.OutBack
            easing.overshoot: 1.3
        }
    }
    Behavior on opacity {
        NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
    }

    Component.onCompleted: if (autoShow) shown = true

    // Soft sheen: light falling from the top
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        gradient: Gradient {
            GradientStop { position: 0.0; color: PickerStyle.sheenTop }
            GradientStop { position: 0.45; color: Qt.rgba(1, 1, 1, 0) }
        }
    }

    // Specular line along the top edge, fading out towards the corners
    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: 1
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: root.radius * 0.6
        anchors.rightMargin: root.radius * 0.6
        height: 1
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0) }
            GradientStop { position: 0.5; color: PickerStyle.specularColor }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0) }
        }
    }

    Item {
        id: contentItem
        anchors.fill: parent
    }
}
