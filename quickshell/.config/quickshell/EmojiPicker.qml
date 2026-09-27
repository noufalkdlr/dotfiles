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
        path: Qt.resolvedUrl("data/emojis.json")

        onLoaded: {
            try {
                root.allEmojis = JSON.parse(text())
                root.filtered = root.allEmojis
            } catch (e) {
                console.log("Failed to parse emojis.json:", e)
            }
        }
    }

    function toggle() {
        root.visible = !root.visible
        if (root.visible) {
            root.query = ""
            root.filtered = root.allEmojis
            searchField.text = ""
            searchField.forceActiveFocus()
        }
    }

    function doFilter(q) {
        root.query = q
        if (q.length === 0) {
            root.filtered = root.allEmojis
            return
        }
        const lower = q.toLowerCase()
        root.filtered = root.allEmojis.filter(e => e.text.toLowerCase().includes(lower))
    }

    function selectEmoji(char) {
        copyProc.emojiChar = char
        copyProc.running = true
        root.visible = false
    }

    Process {
        id: copyProc
        property string emojiChar: ""
        command: ["sh", "-c", "printf '%s' \"$1\" | wl-copy", "--", emojiChar]
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
            }
            margins {
                top: 40
            }

            implicitWidth: 400
            implicitHeight: 420

            MouseArea {
                anchors.fill: parent
                onClicked: root.visible = false
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.75)
                radius: 8
                border.color: "#333333"
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    TextField {
                        id: searchField
                        width: parent.width
                        placeholderText: "Search emoji..."
                        color: "#ffffff"
                        font.family: Theme.fontFamily
                        font.pixelSize: 13

                        background: Rectangle {
                            color: "#1a1a1a"
                            radius: 6
                            border.color: "#333333"
                        }

                        onTextChanged: root.doFilter(text)

                        Keys.onEscapePressed: root.visible = false
                    }

                    GridView {
                        id: grid
                        width: parent.width
                        height: parent.height - searchField.height - 8
                        cellWidth: 44
                        cellHeight: 44
                        clip: true

                        model: root.filtered

                        delegate: Rectangle {
                            required property var modelData

                            width: 40
                            height: 40
                            radius: 6
                            color: hoverArea.containsMouse ? "#333333" : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.emoji
                                font.pixelSize: 20
                            }

                            MouseArea {
                                id: hoverArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
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
