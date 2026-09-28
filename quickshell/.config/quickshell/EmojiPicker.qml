import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    property bool visible: false
    property var allEmojis: []
    property var filtered: []
    property string query: ""

    FileView {
        id: emojiFile
        path: Qt.resolvedUrl("./data/emojis.json")
        blockLoading: true
    }

    Component.onCompleted: {
        try {
            root.allEmojis = JSON.parse(emojiFile.text())
            root.filtered = root.allEmojis
        } catch (e) {
            console.log("Failed to parse emojis.json:", e)
        }
    }

    function toggle() {
        root.visible = !root.visible
        if (root.visible) {
            root.query = ""
            root.filtered = root.allEmojis
        }
    }

    function doFilter(q) {
        root.query = q
        if (q.length === 0) {
            root.filtered = root.allEmojis
        } else {
            const lower = q.toLowerCase()
            root.filtered = root.allEmojis.filter(e => e.text.toLowerCase().includes(lower))
        }
    }

    function selectEmoji(char) {
        copyProc.emojiChar = char
        copyProc.running = true
        root.visible = false
    }

    Process {
        id: copyProc
        property string emojiChar: ""
        command: ["sh", "-c", "printf '%s' " + JSON.stringify(emojiChar) + " | wl-copy"]
    }

    IpcHandler {
        target: "emojiPicker"

        function toggle() {
            root.toggle()
        }
    }

    LazyLoader {
        active: root.visible

        PanelWindow {
            id: pickerWin
            color: "transparent"

            exclusionMode: ExclusionMode.Ignore

            WlrLayershell.namespace: "quickshell-popup"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            Component.onCompleted: {
                searchField.forceActiveFocus()
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.visible = false
            }

            GlassPanel {
                anchors.centerIn: parent
                width: 400
                height: 420

                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: PickerStyle.windowMargins
                    spacing: 8

                    TextField {
                        id: searchField
                        width: parent.width
                        height: PickerStyle.fieldHeight
                        placeholderText: "Search emoji..."
                        leftPadding: PickerStyle.fieldPaddingLeft
                        rightPadding: PickerStyle.fieldPaddingH
                        color: PickerStyle.textColor
                        placeholderTextColor: PickerStyle.placeholderColor
                        font.family: PickerStyle.fontFamily
                        font.weight: PickerStyle.fontWeight
                        font.pixelSize: PickerStyle.fontSize

                        background: Rectangle {
                            color: PickerStyle.fieldBg
                            radius: PickerStyle.fieldRadius
                            border.color: PickerStyle.fieldBorder
                            border.width: 1

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                text: "\uf002"
                                font.family: Theme.fontFamily
                                font.pixelSize: 14
                                color: PickerStyle.placeholderColor
                            }
                        }

                        onTextChanged: {
                            root.doFilter(text)
                            grid.currentIndex = 0
                        }

                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Escape) {
                                root.visible = false
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (root.filtered.length > 0 && grid.currentIndex >= 0) {
                                    root.selectEmoji(root.filtered[grid.currentIndex].emoji)
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Down || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_N)) {
                                grid.currentIndex = Math.min(grid.currentIndex + grid.columns, root.filtered.length - 1)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_P)) {
                                grid.currentIndex = Math.max(grid.currentIndex - grid.columns, 0)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Left || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_H)) {
                                grid.currentIndex = Math.max(grid.currentIndex - 1, 0)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Right || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_L)) {
                                grid.currentIndex = Math.min(grid.currentIndex + 1, root.filtered.length - 1)
                                event.accepted = true
                            } else if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_J) {
                                grid.currentIndex = Math.min(grid.currentIndex + grid.columns, root.filtered.length - 1)
                                event.accepted = true
                            } else if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_K) {
                                grid.currentIndex = Math.max(grid.currentIndex - grid.columns, 0)
                                event.accepted = true
                            }
                        }
                    }

                    GridView {
                        id: grid
                        width: parent.width
                        height: parent.height - searchField.height - 8
                        clip: true

                        readonly property int columns: 8
                        cellWidth: width / columns
                        cellHeight: 46

                        model: root.filtered
                        currentIndex: 0
                        highlightFollowsCurrentItem: true

                        highlight: Rectangle {
                            color: PickerStyle.highlightColor
                            radius: PickerStyle.itemRadius
                            border.color: PickerStyle.highlightBorder
                            border.width: 1
                        }

                        delegate: Item {
                            required property var modelData
                            required property int index

                            width: grid.cellWidth
                            height: grid.cellHeight

                            Text {
                                anchors.centerIn: parent
                                text: modelData.emoji
                                font.pixelSize: 20
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: grid.currentIndex = index
                                onClicked: root.selectEmoji(modelData.emoji)

                                ToolTip.visible: containsMouse
                                ToolTip.text: modelData.text.split(" ")[0] + " " + modelData.text.split(" ")[1]
                            }
                        }
                    }
                }
            }
        }
    }
}
