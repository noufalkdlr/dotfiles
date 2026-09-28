pragma Singleton
import QtQuick

QtObject {
    readonly property string fontFamily: "CaskaydiaCove Nerd Font"
    readonly property string textFontFamily: "Noto Sans"
    readonly property int textFontWeight: Font.Medium
    readonly property int fontSize: 13

    // Bar (Tahoe-like: light glass tint, thin bottom hairline)
    // keep alpha > 0.2 so the Hyprland blur layerrule (ignore_alpha) still applies
    readonly property color barColor: Qt.rgba(0.08, 0.08, 0.09, 0.35)
    readonly property color barBorder: Qt.rgba(1, 1, 1, 0.08)
    readonly property int barHeight: 28
    readonly property int popupTopMargin: 36
}
