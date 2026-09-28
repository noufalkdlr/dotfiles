pragma Singleton
import QtQuick

// Style tokens for the pickers (AppLauncher / ClipboardPicker / EmojiPicker).
// Modelled on macOS Tahoe 26 "Liquid Glass" Spotlight:
//   - very round corners, capsule search field
//   - translucent dark glass (blurred by the Hyprland layerrule for "quickshell-popup")
//   - thin specular edge on top, soft sheen
//   - translucent (not solid blue) selection, spring-in animation
QtObject {
    // Window (glass panel)
    readonly property color windowColor: Qt.rgba(0.11, 0.11, 0.12, 0.5)   // keep alpha > 0.2 (Hyprland ignore_alpha)
    readonly property int windowRadius: 26
    readonly property color borderColor: Qt.rgba(1, 1, 1, 0.12)
    readonly property int borderWidth: 1
    readonly property int windowMargins: 14
    readonly property color sheenTop: Qt.rgba(1, 1, 1, 0.07)             // soft light from above
    readonly property color specularColor: Qt.rgba(1, 1, 1, 0.35)         // bright top edge line

    // Open animation (spring)
    readonly property int openDuration: 320
    readonly property real openStartScale: 0.94

    // Search field (capsule)
    readonly property int fieldHeight: 42
    readonly property int fieldRadius: fieldHeight / 2
    readonly property int fieldPaddingH: 16
    readonly property int fieldPaddingLeft: 42                             // room for the search glyph
    readonly property color fieldBg: Qt.rgba(1, 1, 1, 0.09)
    readonly property color fieldBorder: Qt.rgba(1, 1, 1, 0.10)
    readonly property color placeholderColor: Qt.rgba(1, 1, 1, 0.45)

    // List / Grid — Tahoe uses a translucent rounded selection.
    // Want the accent-blue look instead? use "#0A84FF" here.
    readonly property color highlightColor: Qt.rgba(1, 1, 1, 0.15)
    readonly property color highlightBorder: "transparent"
    readonly property int itemHeight: 40
    readonly property int itemSpacing: 2
    readonly property int itemRadius: 12
    readonly property int itemPaddingH: 12
    readonly property int iconMarginRight: 12
    readonly property int iconSize: 30

    // Dividers inside popups
    readonly property color dividerColor: Qt.rgba(1, 1, 1, 0.10)

    // Cards (Control Center modules)
    readonly property color cardColor: Qt.rgba(1, 1, 1, 0.08)
    readonly property int cardRadius: 18

    // Text
    readonly property string fontFamily: "Noto Sans"
    readonly property int fontWeight: Font.Medium
    readonly property int fontSize: 15
    readonly property int itemFontSize: 13
    readonly property color textColor: "#ffffff"
}
