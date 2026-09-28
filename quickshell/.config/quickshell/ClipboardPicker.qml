import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    property bool visible: false
    property var allItems: []
    property var filtered: []

    function toggle() {
        root.visible = !root.visible
        if (root.visible) {
            listProc.running = true
        }
    }

    function doFilter(q) {
        if (q.length === 0) {
            root.filtered = root.allItems
        } else {
            const lower = q.toLowerCase()
            root.filtered = root.allItems.filter(i => i.preview.toLowerCase().includes(lower))
        }
    }

    function selectItem(id) {
        copyProc.itemId = id
        copyProc.running = true
        root.visible = false
    }

    function deleteItem(id) {
        deleteProc.itemId = id
        deleteProc.running = true
    }

    // ---- List clipboard history ----
    Process {
        id: listProc
        command: ["cliphist", "list"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split("\n").filter(l => l.length > 0)
                const items = []
                for (const line of lines) {
                    const tabIndex = line.indexOf("\t")
                    if (tabIndex === -1) continue
                    const id = line.substring(0, tabIndex)
                    const preview = line.substring(tabIndex + 1)
                    items.push({ id: id, preview: preview })
                }
                root.allItems = items
                root.filtered = items
            }
        }
    }

    // ---- Copy selected item ----
    Process {
        id: copyProc
        property string itemId: ""
        command: ["sh", "-c", "printf '%s' " + JSON.stringify(itemId) + " | cliphist decode | wl-copy"]
    }

    // ---- Delete item from history ----
    Process {
        id: deleteProc
        property string itemId: ""
        command: ["sh", "-c", "printf '%s' " + JSON.stringify(itemId) + " | cliphist delete"]

        stdout: StdioCollector {
            onStreamFinished: listProc.running = true
        }
    }

    IpcHandler {
        target: "clipboardPicker"

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
                width: 370
                height: 475

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
                        placeholderText: "Search clipboard..."
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
                            listView.currentIndex = 0
                        }

                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Escape) {
                                root.visible = false
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (root.filtered.length > 0 && listView.currentIndex >= 0) {
                                    root.selectItem(root.filtered[listView.currentIndex].id)
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Down || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_N)) {
                                listView.currentIndex = Math.min(listView.currentIndex + 1, root.filtered.length - 1)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_P)) {
                                listView.currentIndex = Math.max(listView.currentIndex - 1, 0)
                                event.accepted = true
                            }
                        }
                    }

                    ListView {
                        id: listView
                        width: parent.width
                        height: parent.height - searchField.height - 8
                        clip: true
                        currentIndex: 0
                        highlightFollowsCurrentItem: true
                        highlightMoveDuration: 120
                        spacing: PickerStyle.itemSpacing

                        highlight: Rectangle {
                            color: PickerStyle.highlightColor
                            radius: PickerStyle.itemRadius
                            border.color: PickerStyle.highlightBorder
                            border.width: 1
                        }

                        model: root.filtered

                        delegate: Item {
                            required property var modelData
                            required property int index

                            width: listView.width
                            height: PickerStyle.itemHeight

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: PickerStyle.itemPaddingH
                                anchors.right: deleteBtn.left
                                anchors.rightMargin: 6
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: modelData.preview
                                    font.family: PickerStyle.fontFamily
                                    font.pixelSize: PickerStyle.itemFontSize
                                    font.weight: PickerStyle.fontWeight
                                    color: PickerStyle.textColor
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            Text {
                                id: deleteBtn
                                anchors.right: parent.right
                                anchors.rightMargin: PickerStyle.itemPaddingH
                                anchors.verticalCenter: parent.verticalCenter
                                text: "\uf1f8"
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                color: PickerStyle.placeholderColor

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.deleteItem(modelData.id)
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                anchors.rightMargin: 26
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: listView.currentIndex = index
                                onClicked: root.selectItem(modelData.id)
                            }
                        }
                    }
                }
            }
        }
    }
}
