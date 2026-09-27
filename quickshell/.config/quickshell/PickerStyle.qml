pragma Singleton
import QtQuick

QtObject {
    // Window
    readonly property color windowColor: Qt.rgba(0, 0, 0, 0.7)
    readonly property int windowRadius: 12
    readonly property color borderColor: Qt.rgba(1, 1, 1, 0.1)
    readonly property int borderWidth: 1
    readonly property int windowMargins: 16

    // Search field (wofi #input: padding: 10px 12px)
    readonly property int fieldHeight: 46
    readonly property int fieldPaddingV: 10
    readonly property int fieldPaddingH: 12
    readonly property color fieldBg: Qt.rgba(1, 1, 1, 0.04)
    readonly property color fieldBorder: Qt.rgba(1, 1, 1, 0.08)
    readonly property color placeholderColor: Qt.rgba(1, 1, 1, 0.4)
    readonly property int fieldRadius: 8

    // List / Grid (wofi #entry: padding: 8px 10px, margin-bottom: 4px)
    readonly property color highlightColor: Qt.rgba(1, 1, 1, 0.12)
    readonly property color highlightBorder: Qt.rgba(1, 1, 1, 0.08)
    readonly property int itemHeight: 50
    readonly property int itemSpacing: 4
    readonly property int itemRadius: 8
    readonly property int itemPaddingH: 10
    readonly property int iconMarginRight: 12

    // Text
    readonly property string fontFamily: "Cascadia Mono"
    readonly property int fontSize: 16
    readonly property int itemFontSize: 15
    readonly property color textColor: "#ffffff"
}
