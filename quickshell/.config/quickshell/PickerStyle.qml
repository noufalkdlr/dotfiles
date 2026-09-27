pragma Singleton
import QtQuick

QtObject {
    // Window
    readonly property color windowColor: Qt.rgba(0, 0, 0, 0.7)
    readonly property int windowRadius: 11
    readonly property color borderColor: Qt.rgba(1, 1, 1, 0.1)
    readonly property int borderWidth: 1
    readonly property int windowMargins: 12

    // Search field
    readonly property int fieldHeight: 34
    readonly property int fieldPaddingV: 8
    readonly property int fieldPaddingH: 12
    readonly property color fieldBg: Qt.rgba(1, 1, 1, 0.06)
    readonly property color fieldBorder: Qt.rgba(1, 1, 1, 0.08)
    readonly property color placeholderColor: Qt.rgba(1, 1, 1, 0.4)
    readonly property int fieldRadius: 8

    // List / Grid — macOS uses solid blue for selection
    readonly property color highlightColor: "#0A84FF"
    readonly property color highlightBorder: "#0A84FF"
    readonly property int itemHeight: 30
    readonly property int itemSpacing: 2
    readonly property int itemRadius: 6
    readonly property int itemPaddingH: 10
    readonly property int iconMarginRight: 10

    // Text
    readonly property string fontFamily: "Noto Sans"
    readonly property int fontWeight: Font.Medium
    readonly property int fontSize: 14
    readonly property int itemFontSize: 13
    readonly property color textColor: "#ffffff"
}
