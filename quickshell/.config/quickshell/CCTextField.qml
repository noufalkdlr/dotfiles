import QtQuick
import QtQuick.Controls

// Text field used in Control Center forms (Wi-Fi password, hidden network name ...).
TextField {
    height: 32
    leftPadding: 10
    rightPadding: 10
    color: PickerStyle.textColor
    placeholderTextColor: PickerStyle.placeholderColor
    font.family: PickerStyle.fontFamily
    font.weight: PickerStyle.fontWeight
    font.pixelSize: 13

    background: Rectangle {
        radius: 8
        color: PickerStyle.fieldBg
        border.color: PickerStyle.fieldBorder
        border.width: 1
    }
}
